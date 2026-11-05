/* file : hw_info.h
* brief :
*    1. Collect hardware information
*    2. Gets hardware information
*
* author ZhangKun <zhangkun@tp-link.com.hk>
* version 1.0.0
* date 13 Dec 2023
*
*/
#ifndef __HW_INFO_H
#define __HW_INFO_H
/***************************************************************************/
/*                                  DEFINES                                */
/***************************************************************************/
/*
* Maximum number of hardware information that can be stored.
*/
#define MAX_DEV_INFO 128
/*
* unsigned long Indicates the number of bytes.
*/
#define INFO_SIZE sizeof(unsigned long)
/***************************************************************************/
/*                                   TYPES                                 */
/***************************************************************************/
/*
* A hardware message corresponds to a unique tag.
*/
struct hw_info_map_node
{
    int tag;
    unsigned long dev_info;
};
/*
* The tag information of the hardware information.
* CPU_INFOx : Indicates CPU related hardware information.
* CCLK_INFOx : Indicates CCLK related hardware information.
* DDR_INFOx : Indicates DDR related hardware information.
* FLASH_INFOx : Indicates FLASH related hardware information.
*/
enum dev_info_type
{
    CPU_INFO1 = 1,
    CPU_INFO2,
    CPU_INFO3,
    CPU_INFO4,
    CCLK_INFO1,
    CCLK_INFO2,
    CCLK_INFO3,
    CCLK_INFO4,
    DDR_INFO1,
    DDR_INFO2,
    DDR_INFO3,
    DDR_INFO4,
    FLASH_INFO1,
    FLASH_INFO2,
    FLASH_INFO3,
    FLASH_INFO4
};
/***************************************************************************/
/*                              PUBLIC_FUNCTIONS                           */
/***************************************************************************/
/*To convert character array information into standard hardware information format.*/
unsigned long tran_to_info(const char *src_info);
/*To collect hardware information.*/
void put_hw_info(const unsigned long src_info, int tag);
/*To get hardware information.*/
int get_hw_info(unsigned long *dev_info, int tag);
#endif
