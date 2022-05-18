

  # "boot-"*)
  #   "${commbox}"
  #   dev="$(echo $cmd | cut -d '-' -f2-)"
  #   script="$(SKIP_CACHIX=1 "${rb}" "${BLDR:-"${BLDR_A64}"}" "localhost" "${nixcfg}#phones.${dev}.flash-boot" "${@}")"
  #   FASTBOOT_SLOT="${FASTBOOT_SLOT:-"a"}" sh "${script}" "reboot"
  #   ;;
