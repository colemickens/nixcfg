{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [ firecracker firectl ];
}
