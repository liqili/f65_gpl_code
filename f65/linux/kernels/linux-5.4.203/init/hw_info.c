#include <linux/kernel.h>
#include <linux/string.h>
#include <linux/hw_info.h>
extern struct hw_info_map_node hw_info[MAX_DEV_INFO];
/*the number of collected hardware information*/
static int hw_info_size = 0;
/**
 * Convert character array information into standard hardware information format.
 * @param src_info raw information that needs to be processed
 * @return dev_info standard hardware information
 */
unsigned long tran_to_info(const char *src_info)
{
    unsigned long dev_info = 0;
    int i = 0;
    int len = 0;
    len = strlen(src_info);
    if (len <= INFO_SIZE){
        for (i = len; i >= 0; i--){
            dev_info <<= 8;
            dev_info ^= src_info[i];
        }
    } else {
        for (i = 1; i <= INFO_SIZE; i++){
            dev_info <<= 8;
            dev_info ^= src_info[len-i];
        }
    }
    return dev_info;
}
EXPORT_SYMBOL(tran_to_info);
/**
 * Collect hardware information.
 * @param src_info hardware information to be populated
 * @param tag tag corresponding to hardware information
 */
void put_hw_info(const unsigned long src_info, int tag)
{
    if (hw_info_size >= MAX_DEV_INFO){
        return;
    }
    hw_info_size++;
    hw_info[hw_info_size - 1].tag = tag;
    hw_info[hw_info_size - 1].dev_info = src_info;
    pr_info("%s:%d %s() src_info:0x%lx  tag:%d \r\n",
                __FILE__, __LINE__, __FUNCTION__, src_info, tag);
}
EXPORT_SYMBOL(put_hw_info);
/**
 * Get hardware information.
 * @param tag tag corresponding to hardware information
 * @param dev_info a variable filled with hardware information
 * @return 0:sucess -1:failed
 */
int get_hw_info(unsigned long *dev_info, int tag)
{
    int i = 0;
    for (i = 0; i < hw_info_size; ++i)
    {
        if(hw_info[i].tag == tag){
            *dev_info = hw_info[i].dev_info;
            goto done;
        }
    }
    return -1;
done:
    return 0;
}
EXPORT_SYMBOL(get_hw_info);
