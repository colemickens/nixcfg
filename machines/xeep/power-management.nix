{ pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      #undervolt
    ];

    services.tlp.enable = true;
    services.tlp.settings = {
    #   #START_CHARGE_THRESH_BAT0=75
    #   #STOP_CHARGE_THRESH_BAT0=80
    #   CPU_SCALING_GOVERNOR_ON_BAT=powersave
       CPU_SCALING_GOVERNOR_ON_AC = "performance";
    #   ENERGY_PERF_POLICY_ON_BAT=powersave
    };
    powerManagement.enable = true;
    services.upower.enable = true; # fucking tired of it shutting down with hours of battery left

    #services.undervolt = {
    #  enable = true;
    #  coreOffset = "-100";
    #  gpuOffset = "-75";
    #  uncoreOffset = "-100";
    #  analogioOffset = "-100";
    #  temp = "97";
    #};

    # services.thermald.enable = false;

    # services.throttled = {
    #   enable = true;
    #   extraConfig = ''
    #     [GENERAL]
    #     # Enable or disable the script execution
    #     Enabled: True
    #     # SYSFS path for checking if the system is running on AC power
    #     Sysfs_Power_Path: /sys/class/power_supply/AC*/online

    #     ## Settings to apply while connected to Battery power
    #     [BATTERY]
    #     # Update the registers every this many seconds
    #     Update_Rate_s: 30
    #     # Max package power for time window #1
    #     PL1_Tdp_W: 29
    #     # Time window #1 duration
    #     PL1_Duration_s: 28
    #     # Max package power for time window #2
    #     PL2_Tdp_W: 44
    #     # Time window #2 duration
    #     PL2_Duration_S: 0.002
    #     # Max allowed temperature before throttling
    #     Trip_Temp_C: 85
    #     # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
    #     cTDP: 0

    #     ## Settings to apply while connected to AC power
    #     [AC]
    #     # Update the registers every this many seconds
    #     Update_Rate_s: 5
    #     # Max package power for time window #1
    #     PL1_Tdp_W: 44
    #     # Time window #1 duration
    #     PL1_Duration_s: 28
    #     # Max package power for time window #2
    #     PL2_Tdp_W: 44
    #     # Time window #2 duration
    #     PL2_Duration_S: 0.002
    #     # Max allowed temperature before throttling
    #     Trip_Temp_C: 97
    #     # Set HWP energy performance hints to 'performance' on high load (EXPERIMENTAL)
    #     HWP_Mode: False
    #     # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
    #     cTDP: 0

    #     [UNDERVOLT.BATTERY]
    #     # CPU core voltage offset (mV)
    #     CORE: -75
    #     # Integrated GPU voltage offset (mV)
    #     GPU: -75
    #     # CPU cache voltage offset (mV)
    #     CACHE: -75
    #     # System Agent voltage offset (mV)
    #     UNCORE: -75
    #     # Analog I/O voltage offset (mV)
    #     ANALOGIO: -75

    #     [UNDERVOLT.AC]
    #     # CPU core voltage offset (mV)
    #     CORE: 0
    #     # Integrated GPU voltage offset (mV)
    #     GPU: 0
    #     # CPU cache voltage offset (mV)
    #     CACHE: 0
    #     # System Agent voltage offset (mV)
    #     UNCORE: 0
    #     # Analog I/O voltage offset (mV)
    #     ANALOGIO: 0

    #     # [ICCMAX.AC]
    #     # # CPU core max current (A)
    #     # CORE:
    #     # # Integrated GPU max current (A)
    #     # GPU:
    #     # # CPU cache max current (A)
    #     # CACHE:

    #     # [ICCMAX.BATTERY]
    #     # # CPU core max current (A)
    #     # CORE:
    #     # # Integrated GPU max current (A)
    #     # GPU:
    #     # # CPU cache max current (A)
    #     # CACHE:
    #   '';
    # };
  };
}
