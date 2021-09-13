https://rr-developer.github.io/LUKS-on-Raspberry-Pi/

TARGET="/dev/disk/by-id/usb-WD_My_Passport_260F_575837324441305052353944-0:0"

cryptsetup \
  --type luks2 \
  --cipher xchacha20,aes-adiantum-plain64 \
  --hash sha256 \
  --iter-time 5000 \
  -–key-size 256 \
  --pbkdf argon2id \
    luksFormat $TARGET
