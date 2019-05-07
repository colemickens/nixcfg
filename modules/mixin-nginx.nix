{
  config = {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "default" = {
          default = true;
          root = "/media/data/Media";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };
}

# OLD, was it working? (without autoindex? intentional?)
#
# nginx.virtualHosts.xelpweb = {
#       listen = {
#         addr = "192.168.1.10";
#         port = 80;
#       };
#       locations = {
#         "/" = {
#           root = "/media/data/Media/tvshows";
#         };
#       };
#     };
