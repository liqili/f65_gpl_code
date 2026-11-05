/* vi: set sw=4 ts=4: */
/*
 * Mostly stolen from: dhcpcd - DHCP client daemon
 * by Yoichi Hariguchi <yoichi@fore.com>
 *
 * Licensed under GPLv2, see file LICENSE in this source tree.
 */
#include <netinet/if_ether.h>
#include <net/if_arp.h>

#include "common.h"
#include "dhcpd.h"

struct arpMsg {
	/* Ethernet header */
	uint8_t  h_dest[6];     /* 00 destination ether addr */
	uint8_t  h_source[6];   /* 06 source ether addr */
	uint16_t h_proto;       /* 0c packet type ID field */

	/* ARP packet */
	uint16_t htype;         /* 0e hardware type (must be ARPHRD_ETHER) */
	uint16_t ptype;         /* 10 protocol type (must be ETH_P_IP) */
	uint8_t  hlen;          /* 12 hardware address length (must be 6) */
	uint8_t  plen;          /* 13 protocol address length (must be 4) */
	uint16_t operation;     /* 14 ARP opcode */
	uint8_t  sHaddr[6];     /* 16 sender's hardware address */
	uint8_t  sInaddr[4];    /* 1c sender's IP address */
	uint8_t  tHaddr[6];     /* 20 target's hardware address */
	uint8_t  tInaddr[4];    /* 26 target's IP address */
	uint8_t  pad[18];       /* 2a pad for min. ethernet payload (60 bytes) */
} PACKED;

enum {
	ARP_MSG_SIZE = 0x2a
};

#define CHECK_ARPING_MAX_TIMES  (5)
#define CHECK_ARPING_INTERVAL   (1000)
#define IS_BROADCAST_MAC(mac)   ((mac[0] & mac[1] & mac[2] & mac[3] & mac[4] & mac[5]) == 0xFF)

/* Returns 1 if no reply received */
/* is_for_check：
 * 1-check gateway arrived or not, at most send 5 arp requests if not received reply
 * 0-check ip is conflicting or not, only send 1 arp request 
 */
int FAST_FUNC arpping(uint32_t is_for_check,
		uint8_t *to_mac,
		uint32_t test_nip,
		const uint8_t *safe_mac,
		uint32_t from_ip,
		uint8_t *from_mac,
		const char *interface)
{
	int timeout_ms;
	struct pollfd pfd[1];
#define s (pfd[0].fd)           /* socket */
	int rv = 1;             /* "no reply received" yet */
	struct sockaddr addr;   /* for interface name */
	struct arpMsg arp;
	struct arpMsg arp_reply;
	int i = 0;
	int try_cnt = 1;
	int arp_intvl = 2000;

	s = socket(PF_PACKET, SOCK_PACKET, htons(ETH_P_ARP));
	if (s == -1) {
		bb_perror_msg(bb_msg_can_not_create_raw_socket);
		return -1;
	}

	if (setsockopt_broadcast(s) == -1) {
		bb_perror_msg("can't enable bcast on raw socket");
		goto ret;
	}

	/* send arp request */
	memset(&arp, 0, sizeof(arp));
    if (is_for_check)
    {
        try_cnt = CHECK_ARPING_MAX_TIMES;
        arp_intvl = CHECK_ARPING_INTERVAL;
        memcpy(arp.h_dest, to_mac, 6);                /* MAC DA */

        if (IS_BROADCAST_MAC(to_mac))
        {
            /* tHaddr is zero-filled */                     /* target hardware address */
        }
        else
        {
            memcpy(arp.tHaddr, to_mac, 6);                /* target hardware address */
        }
    }
    else
    {
        memset(arp.h_dest, 0xff, 6);                    /* MAC DA */
        /* tHaddr is zero-filled */                     /* target hardware address */
    }
	memcpy(arp.h_source, from_mac, 6);              /* MAC SA */
	arp.h_proto = htons(ETH_P_ARP);                 /* protocol type (Ethernet) */
	arp.htype = htons(ARPHRD_ETHER);                /* hardware type */
	arp.ptype = htons(ETH_P_IP);                    /* protocol type (ARP message) */
	arp.hlen = 6;                                   /* hardware address length */
	arp.plen = 4;                                   /* protocol address length */
	arp.operation = htons(ARPOP_REQUEST);           /* ARP op code */
	memcpy(arp.sHaddr, from_mac, 6);                /* source hardware address */
	memcpy(arp.sInaddr, &from_ip, sizeof(from_ip)); /* source IP address */
	memcpy(arp.tInaddr, &test_nip, sizeof(test_nip));/* target IP address */

	memset(&addr, 0, sizeof(addr));
	safe_strncpy(addr.sa_data, interface, sizeof(addr.sa_data));
	if (sendto(s, &arp, sizeof(arp), 0, &addr, sizeof(addr)) < 0) {
		// TODO: error message? caller didn't expect us to fail,
		// just returning 1 "no reply received" misleads it.
		goto ret;
	}

	/* wait for arp reply, and check it */
    for (i = 0; i < try_cnt; i++)
    {
        timeout_ms = arp_intvl;

        if(i != 0 )
        {
            /* not received reply firstly, send broadcast arp request */
            memset(arp.h_dest, 0xFF, 6);
            memset(arp.tHaddr, 0, 6);

            if (sendto(s, &arp, sizeof(arp), 0, &addr, sizeof(addr)) < 0) {
                // TODO: error message? caller didn't expect us to fail,
                // just returning 1 "no reply received" misleads it.
                goto ret;
            }
        }

    	do {
    		typedef uint32_t aliased_uint32_t FIX_ALIASING;
    		int r;
    		unsigned prevTime = monotonic_ms();

    		pfd[0].events = POLLIN;
    		r = safe_poll(pfd, 1, timeout_ms);
    		if (r < 0)
    			break;
    		if (r) {
    			r = safe_read(s, &arp_reply, sizeof(arp_reply));
    			if (r < 0)
    				break;

    			//log3("sHaddr %02x:%02x:%02x:%02x:%02x:%02x",
    			//	arp.sHaddr[0], arp.sHaddr[1], arp.sHaddr[2],
    			//	arp.sHaddr[3], arp.sHaddr[4], arp.sHaddr[5]);

    			if (r >= ARP_MSG_SIZE
    			 && arp_reply.operation == htons(ARPOP_REPLY)
    			 /* don't check it: Linux doesn't return proper tHaddr (fixed in 2.6.24?) */
    			 /* && memcmp(arp.tHaddr, from_mac, 6) == 0 */
    			 && *(aliased_uint32_t*)arp_reply.sInaddr == test_nip
    			) {
    			    if (is_for_check)
    			    {
                        if (memcmp(to_mac, arp_reply.sHaddr, 6) != 0)
                        {
                            memcpy(to_mac, arp_reply.sHaddr, 6);
                        }
                        rv = 0;
    			    }
                    else
                    {
                        /* if ARP source MAC matches safe_mac
                         * (which is client's MAC), then it's not a conflict
                         * (client simply already has this IP and replies to ARPs!)
                         */
                        if (!safe_mac || memcmp(safe_mac, arp_reply.sHaddr, 6) != 0)
                            rv = 0;
                        //else log2("sHaddr == safe_mac");
                    }

                    goto ret;
    			}
    		}
    		timeout_ms -= (unsigned)monotonic_ms() - prevTime + 1;

    		/* We used to check "timeout_ms > 0", but
    		 * this is more under/overflow-resistant
    		 * (people did see overflows here when system time jumps):
    		 */
    	} while ((unsigned)timeout_ms <= arp_intvl);
    }

 ret:
	close(s);
	log1("%srp reply received for this address", rv ? "No a" : "A");
	return rv;
}
