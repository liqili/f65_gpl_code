compile step:
make BOARD_TYPE=mtk7981_eap65x_common PID=eap WEB_PAGES_ID=VI_2.0 eap_prep
make BOARD_TYPE=mtk7981_eap65x_common PID=eap WEB_PAGES_ID=VI_2.0 eap_develop

eap_develop / eap_release now finish with eap_image, which writes the images to
images/eap/mtk7981_eap65x_common/:
  FestaF65v1_<ver>_[<date>-rel<n>]_up.bin           firmware upgrade file (web UI / CLI)
  FestaF65v1_<ver>_[<date>-rel<n>]_flash.bin        full NAND image with ECC (programmer)
  FestaF65v1_<ver>_[<date>-rel<n>]_flash_no_ecc.bin full NAND image without OOB

To repack images without recompiling:
make BOARD_TYPE=mtk7981_eap65x_common PID=eap WEB_PAGES_ID=VI_2.0 eap_skipbuild
