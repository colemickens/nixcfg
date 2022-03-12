{ config, pkgs, ... }:

let
  moneroDepositAddr = "4542ZWwmtfda86Lix9QZf28W1VkW6o4qkSQXXBe2JPMxD2fQL6mJ9Kob4y9iVMbUjmDYWYtGT4gbzS9WzrZuwinR99t3AV3";
in {
  config = {
    systemd.services.xmrig = {
      description = "xmrig";
      path = with pkgs; [ ];
      serviceConfig = {
        Type = "simple";
        StartLimitInterval = "60s";
        StartLimitBurst = 3;
        ExecStartPre = [
          "-${pkgs.xmrig}/bin/xmrig "
        ];
        ExecStart = "${pkgs.xmrig}/bin/xmrig -o pool.hashvault.pro:3333 -u ${moneroDepositAddr} -p x ";
        Restart = "on-failure";
      };
      wantedBy = [ "default.target" ];
    };
  };
}
