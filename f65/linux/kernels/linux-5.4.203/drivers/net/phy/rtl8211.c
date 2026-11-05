/*
 * Author: leizhikun@tp-link.com.hk
 * Date:   2023.09
 */

#define RTL8211F_PROCFS_DBG 1  /* can be replaced by: mii_mgr or mii_mgr_cl45 */
// #define RTL8211F_PRINTK_DBG 1

#ifdef RTL8211F_PRINTK_DBG
#define RTL8211F_TRACE(...) printk(__VA_ARGS__);
#else
#define RTL8211F_TRACE
#endif

#include <linux/if.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/phy.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#ifdef RTL8211F_PROCFS_DBG
#include <linux/proc_fs.h>
#endif /* RTL8211F_PROCFS_DBG */

#define ETH_SGMII_ADDRESS_OFFSET	0x48

#define ETH_SGMII_GIGE_MSB		24
#define ETH_SGMII_GIGE_LSB		24
#define ETH_SGMII_GIGE_MASK		0x01000000
#define ETH_SGMII_GIGE_GET(x)		(((x) & ETH_SGMII_GIGE_MASK) >> ETH_SGMII_GIGE_LSB)
#define ETH_SGMII_GIGE_SET(x)		(((x) << ETH_SGMII_GIGE_LSB) & ETH_SGMII_GIGE_MASK)

#define ETH_SGMII_CLK_SEL_MSB		25
#define ETH_SGMII_CLK_SEL_LSB		25
#define ETH_SGMII_CLK_SEL_MASK		0x02000000
#define ETH_SGMII_CLK_SEL_GET(x)	(((x) & ETH_SGMII_CLK_SEL_MASK) >> ETH_SGMII_CLK_SEL_LSB)
#define ETH_SGMII_CLK_SEL_SET(x)	(((x) << ETH_SGMII_CLK_SEL_LSB) & ETH_SGMII_CLK_SEL_MASK)

#define ETH_SGMII_PHASE0_COUNT_MSB	7
#define ETH_SGMII_PHASE0_COUNT_LSB	0
#define ETH_SGMII_PHASE0_COUNT_MASK	0x000000ff
#define ETH_SGMII_PHASE0_COUNT_GET(x)	(((x) & ETH_SGMII_PHASE0_COUNT_MASK) >> ETH_SGMII_PHASE0_COUNT_LSB)
#define ETH_SGMII_PHASE0_COUNT_SET(x)	(((x) << ETH_SGMII_PHASE0_COUNT_LSB) & ETH_SGMII_PHASE0_COUNT_MASK)

#define ETH_SGMII_PHASE1_COUNT_MSB	15
#define ETH_SGMII_PHASE1_COUNT_LSB	8
#define ETH_SGMII_PHASE1_COUNT_MASK	0x0000ff00
#define ETH_SGMII_PHASE1_COUNT_GET(x)	(((x) & ETH_SGMII_PHASE1_COUNT_MASK) >> ETH_SGMII_PHASE1_COUNT_LSB)
#define ETH_SGMII_PHASE1_COUNT_SET(x)	(((x) << ETH_SGMII_PHASE1_COUNT_LSB) & ETH_SGMII_PHASE1_COUNT_MASK)

#define RTL8211F_INSR				0x1d

#define RTL821x_INER				0x12
#define RTL8211F_INER_LINK_STATUS		BIT(4)

#define RTL8211F_LED1_LINK_10			BIT(5)

#define RTL8211F_TX_DELAY			BIT(8)

#define RTL821x_EXT_PAGE_SELECT			0x1e
#define RTL821x_PAGE_SELECT			0x1f

#define RTL8211F_PHY_ID_MASK		0xffffffff
#define RTL8211F_PHY_ID 			0x1cc916

#define RTL8211F_PHY_ADDR 			0x4

/* MII register */

#define RTL8211F_PHY_INER		0x12		//PG a42
#define RTL8211F_PHY_PHYCR1		0x18		//PG a43
#define RTL8211F_PHY_PHYCR2		0x19		//PG a43
#define RTL8211F_PHY_PHYSR		0x1a		//PG a43
#define RTL8211F_PHY_INSR		0x1d		//PG a43
#define RTL8211F_PHY_PHYSCR		0x14		//PG a46
#define RTL8211F_PHY_MIICR		0x15		//PG d08
#define RTL8211F_PHY_PAGSR		0x1F
#define RTL8211F_PHY_LCR		0x10		//PG d04

#define RTL8211_REG_DEFAULT_PAGE	0xa42
#define RTL8211_REG_PHYSR_PAGE		0xa43
#define RTL8211_REG_LCR_PAGE		0xd04


#define RTL8211_STATUS_LINK_MASK	0x0004
#define RTL8211_STATUS_DUPLEX_MASK	0x0008
#define RTL8211_STATUS_SPEED_MASK	0x2040
#define RTL8211_STATUS_FULL_DUPLEX	0x2000

#define RTL8211_STATUS_SPEED_1000_MASK	0x0040
#define RTL8211_STATUS_SPEED_100_MASK	0x2000
#define RTL8211_STATUS_SPEED_10_MASK	0x0000


#define RTL8211_STATUS_SPEED_1000MBS	0x2
#define RTL8211_STATUS_SPEED_100MBS		0x1
#define RTL8211_STATUS_SPEED_10MBS		0x0

/* MII register field */
#define RTL8211_CTRL_AUTONEGOTIATION_ENABLE          0x1000
#define RTL8211_CTRL_RESTART_AUTONEGOTIATION         0x0200
#define RTL8211_CTRL_FULL_DUPLEX                     0x0100
#define RTL8211_CONTROL_SPEED_MASK                   0x2040
#define RTL8211_CONTROL_100M                         0x2000
#define RTL8211_CONTROL_10M                          0x0
#define RTL8211_PHY_FIFO_RESET                       0x3
#define RTL8211_INTR_SPEED_CHANGE                    0x4000
#define RTL8211_INTR_DUPLEX_CHANGE                   0x2000
#define RTL8211_INTR_STATUS_LINK_DOWN                0x0800
#define RTL8211_INTR_STATUS_LINK_UP                  0x0400
#define RTL8211_INTR_DOWNSHIF                        0x0020
#define RTL8211_INTR_WOL                             0x0001
#define RTL8211_INTR_FAST_LINK_DOWN_STAT_10M         0x40
#define RTL8211_INTR_FAST_LINK_DOWN_STAT_100M        0x200
#define RTL8211_INTR_FAST_LINK_DOWN_STAT_1000M       0x240
#define RTL8211_COMMON_CTRL                          0x1040
#define RTL8211_10M_LOOPBACK                         0x4100
#define RTL8211_100M_LOOPBACK                        0x6100
#define RTL8211_1000M_LOOPBACK                       0x4140

/* MMD1 register */
#define RTL8211_PHY_MMD1_NUM                         0x1
#define RTL8211_PHY_MMD1_MSE_THRESH1                 0x1000
#define RTL8211_PHY_MMD1_MSE_THRESH2                 0x1001
#define RTL8211_PHY_MMD1_DAC                         0x8100
/* MMD1 register field */
#define RTL8211_PHY_MMD1_MSE_THRESH1_VAL             0xf1
#define RTL8211_PHY_MMD1_MSE_THRESH2_VAL             0x1f6

/* MMD3 register */
#define RTL8211_PHY_MMD3_NUM                         0x3
#define RTL8211_PHY_MMD3_AZ_CTRL1                    0x8008
#define RTL8211_PHY_MMD3_AZ_CTRL2                    0x8009
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL3            0x8074
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL4            0x8075
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL5            0x8076
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL6            0x8077
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL7            0x8078
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL9            0x807a
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL13           0x807e
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL14           0x807f

/* MMD3 register field */
#define RTL8211_PHY_MMD3_AZ_CTRL1_VAL                0x7880
#define RTL8211_PHY_MMD3_AZ_CTRL2_VAL                0xc8
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL3_VAL        0xc040
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL4_VAL        0xa060
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL5_VAL        0xc040
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL6_VAL        0xa060
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL7_VAL        0xc24c
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL9_VAL        0xc060
#define RTL8211_PHY_MMD3_CDT_THRESH_CTRL13_VAL       0xb060
#define RTL8211_PHY_MMD3_NEAR_ECHO_THRESH_VAL        0x90b0

/* debug register */
#define RTL8211_PHY_DEBUG_EDAC                       0x4380

/* debug port analog */
#define RTL8211_PHY_DEBUG_ANA_LDO_EFUSE              0x180
#define RTL8211_PHY_DEBUG_ANA_DAC_FILTER             0xa080

#define RTL8211_PHY_DEBUG_ANA_LDO_EFUSE_DEFAULT      0x50

#ifdef RTL8211F_PROCFS_DBG
static void rtl8211f_debug_proc_init(struct phy_device *phydev);
static void rtl8211f_debug_proc_exit(void);
#endif /* RTL8211F_PROCFS_DBG */

static int rtl8211f_probe(struct phy_device *pdev) { return 0; }

static void rtl8211f_remove(struct phy_device *pdev) {}

static int rtl8211f_config_init(struct phy_device *phydev)
{
	struct device *dev = &phydev->mdio.dev;
	u16 val = 0;
	int ret = 0;

	RTL8211F_TRACE("[%s] \n", __func__);

	genphy_soft_reset(phydev);

#if 1 /* specific code： MT7981 MAC0-SGMII0 <--> RTL8211FS-CG PHY */

	/* broadcast address(0) respond */
	val = phy_read_paged(phydev, RTL8211_REG_PHYSR_PAGE, RTL8211F_PHY_PHYCR1);
	RTL8211F_TRACE("[%s] page:0xa43 reg:24(0x18) val=0x%08x\n", __func__, val);
	phy_write_paged(phydev, RTL8211_REG_PHYSR_PAGE, RTL8211F_PHY_PHYCR1, val & ~(1 << 13)); // bit 13: broadcast address respond: close!
	val = phy_read_paged(phydev, RTL8211_REG_PHYSR_PAGE, RTL8211F_PHY_PHYCR1);
	RTL8211F_TRACE("[%s] page:0xa43 reg:24(0x18) val=0x%08x\n", __func__, val);

	/* sgmii close nway(force mode) */
	phy_write_paged(phydev, RTL8211_REG_PHYSR_PAGE, 27, 0xdc84); //Page 0xdc8 is serdes register which should be written through indirect access method
	phy_write_paged(phydev, RTL8211_REG_PHYSR_PAGE, 28, 0x7180); // SGMII nway: close!

	phy_write_paged(phydev, RTL8211_REG_PHYSR_PAGE, 27, 0xdc84); //Page 0xdc8 is serdes register which should be read through indirect access method
	val = phy_read_paged(phydev, RTL8211_REG_PHYSR_PAGE, 28);
	RTL8211F_TRACE("[%s] page:0xdc8 reg:18(0x12) val=0x%08x\n", __func__, val);

	/* eee */
	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV, 0);  // eee: close!

	/* flow control */
	val = phy_read_paged(phydev, RTL8211_REG_PHYSR_PAGE, RTL8211F_PHY_PHYSR);    // flow control: default bit6(Tx) bit7(Rx): open!
	RTL8211F_TRACE("[%s] page:0xa43 reg:26(0x1a) val=0x%08x\n", __func__, val);

	/* speed down(retry, two-pair) */
	val = phy_read_paged(phydev, 0xa44, 17);    // speed down: default 0x43c: open!
	RTL8211F_TRACE("[%s] page:0xa44 reg:17(0x11) val=0x%08x\n", __func__, val);

	/* led control */
	val = phy_read_paged(phydev, RTL8211_REG_LCR_PAGE, RTL8211F_PHY_LCR);
	phy_write_paged(phydev, RTL8211_REG_LCR_PAGE, RTL8211F_PHY_LCR, val | (RTL8211F_LED1_LINK_10)); // bit 5: LED1 Link Indication: 10Mbps: open!
	RTL8211F_TRACE("[%s] page:0xd04 reg:16(0x10) val=0x%08x\n", __func__, val);
#endif

#ifdef RTL8211F_PROCFS_DBG
	rtl8211f_debug_proc_init(phydev);
#endif /* RTL8211F_PROCFS_DBG */

	/* enable TX-delay for rgmii-{id,txid}, and disable it for rgmii and
	 * rgmii-rxid. The RX-delay can be enabled by the external RXDLY pin.
	 */
	switch (phydev->interface) {
		case PHY_INTERFACE_MODE_RGMII:
		case PHY_INTERFACE_MODE_RGMII_RXID:
			val = 0;
			break;
		case PHY_INTERFACE_MODE_RGMII_ID:
		case PHY_INTERFACE_MODE_RGMII_TXID:
			val = RTL8211F_TX_DELAY;
			break;
		default: /* the rest of the modes imply leaving delay as is. */
			return 0;
	}

	ret = phy_modify_paged_changed(phydev, 0xd08, 0x11, RTL8211F_TX_DELAY, val);
	if (ret < 0) {
		dev_err(dev, "Failed to update the TX delay register\n");
		return ret;
	} else if (ret) {
		dev_err(dev,
			"%s 2ns TX delay (and changing the value from pin-strapping RXD1 or the bootloader)\n",
			val ? "Enabling" : "Disabling");
	} else {
		dev_err(dev,
			"2ns TX delay was already %s (by pin-strapping RXD1 or bootloader configuration)\n",
			val ? "enabled" : "disabled");
	}

	return 0;
}

static int rtl8211f_ack_interrupt(struct phy_device *phydev)
{
	int err = 0;

	err = phy_read_paged(phydev, RTL8211_REG_PHYSR_PAGE, RTL8211F_INSR);

	return (err < 0) ? err : 0;
}

static int rtl8211f_config_intr(struct phy_device *phydev)
{
	u16 val = 0;

	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
		val = RTL8211F_INER_LINK_STATUS;
	else
		val = 0;

	return phy_write_paged(phydev, RTL8211_REG_DEFAULT_PAGE, RTL821x_INER, val);
}

static int rtl8211f_config_aneg(struct phy_device *phydev)
{
	u32 rddata = 0;
	RTL8211F_TRACE("[%s]\n", __func__);

	phydev->autoneg = AUTONEG_ENABLE;
	rddata = genphy_config_aneg(phydev);
	if (rddata < 0) {
		printk("%s, Error: 0x%x\n", __func__, rddata);
		return rddata;
	}

	return 0;
}

static int rtl821x_read_page(struct phy_device *phydev)
{
	return __phy_read(phydev, RTL821x_PAGE_SELECT);
}

static int rtl821x_write_page(struct phy_device *phydev, int page)
{
	return __phy_write(phydev, RTL821x_PAGE_SELECT, page);
}

static struct phy_driver rtl8211f_phy_drivers[] = {
	{
	.phy_id         = RTL8211F_PHY_ID,
	.name           = "RealTek 8211FS-CG PHY",
	.phy_id_mask    = RTL8211F_PHY_ID_MASK,
	.features       = PHY_GBIT_FEATURES,
	.probe          = rtl8211f_probe,
	.remove         = rtl8211f_remove,
	.config_init    = rtl8211f_config_init,
	.ack_interrupt  = rtl8211f_ack_interrupt,
	.config_intr    = rtl8211f_config_intr,
	.config_aneg    = rtl8211f_config_aneg,
	.suspend        = genphy_suspend,
	.resume         = genphy_resume,
	.read_page      = rtl821x_read_page,
	.write_page     = rtl821x_write_page,
	},
};

module_phy_driver(rtl8211f_phy_drivers);
MODULE_LICENSE("GPL");



#ifdef RTL8211F_PROCFS_DBG
static struct phy_device *l_phy = NULL;
static struct proc_dir_entry *l_proc_rtketh_dir = NULL, *l_proc_phyreg_dir = NULL;

static int dbg_phy_read(struct seq_file *seq, void *v)
{
	seq_puts(seq, "   <<not used yet>>\r\n");
	return 0;
}

static int dbg_phy_open(struct inode *inode, struct file *file)
{
	return single_open(file, dbg_phy_read, 0);
}

static ssize_t dbg_phy_write(struct file *file, const char __user *buffer,
			size_t count, loff_t *pos)
{
	char kbuf[128] = {0};
	int phyaddr = 0;
	int page = 0;
	int regnum = 0;
	int rw = 0;
	int val = 0;
	struct phy_device *phydev = NULL;

	if(!l_phy)
	{
		printk("phydev not init!");
		return count;
	}

	if (copy_from_user(kbuf, buffer, count > 128 ? 128 : count))
		return -EFAULT;
	kbuf[count] = '\0';
	sscanf(kbuf, "%d %x %x %d %x\n", &rw, &phyaddr, &page, &regnum, &val);

	phydev = mdiobus_get_phy(l_phy->mdio.bus, phyaddr);
	if(rw == 0 && page == 0)
	{
		printk("phyaddr=0x%x page=0x%x reg=%d va=0x%x (read)\n",
			phyaddr, page, regnum, phy_read(phydev, regnum));
	}
	else if (rw == 0 && page > 0)
	{
		printk("phyaddr=0x%x page=0x%x reg=%d va=0x%x (read)\n",
			phyaddr, page, regnum, phy_read_paged(phydev, page, regnum));
	}
	else if (rw == 1 && page == 0)
	{
		phy_write(phydev, (u32)regnum, (u16)val);
		printk("phyaddr=0x%x page=0x%x reg=%d va=0x%x (write)\n",
			phyaddr, page, regnum, val);
	}
	else if (rw == 1 && page > 0)
	{
		phy_write_paged(phydev, page, (u32)regnum, (u16)val);
		printk("phyaddr=0x%x page=0x%x reg=%d va=0x%x (write)\n",
			phyaddr, page, regnum, val);
	}
	else
	{
		printk("input err!!!\n");
	}

	return count;
}

static const struct file_operations dbg_phy_fops = {
	.owner = THIS_MODULE,
	.open = dbg_phy_open,
	.read = seq_read,
	.write  = dbg_phy_write,
	.llseek = seq_lseek,
	.release = single_release
};

static void rtl8211f_debug_proc_init(struct phy_device *phydev)
{
	l_phy = phydev;
	if(!l_proc_rtketh_dir) l_proc_rtketh_dir = proc_mkdir("rtketh", NULL);
	if(!l_proc_phyreg_dir) l_proc_phyreg_dir = proc_create("phyreg", 0, l_proc_rtketh_dir, &dbg_phy_fops);
}

static void rtl8211f_debug_proc_exit(void)
{
	l_phy = NULL;
	if(l_proc_phyreg_dir) remove_proc_entry("phyreg", l_proc_phyreg_dir);
	if(l_proc_rtketh_dir) remove_proc_entry("rtketh", l_proc_rtketh_dir);
}
#endif /* RTL8211F_PROCFS_DBG */
