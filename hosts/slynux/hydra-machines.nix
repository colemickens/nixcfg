
{
  localhost = {
    hostName = "localhost";
    systems = [ "x86_64-linux" "i686-linux" ];
    mandatoryFeatures = [];
    supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
    speedFactor = 1;
    maxJobs = 4;
  };
  a64community = { 
    hostName = "aarch64.nixos.community";
    sshHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1VVHo1aTl1NUgyRkhOQW1aSnlvSmZJR3lVbS9IZkdoZnduYzE0MkwzZHMK";
    sshUser = "colemickens";
    systems = [ "aarch64-linux" ];
    supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
    speedFactor = 1;
    maxJobs = 4;
  };
  rpifour1 = {
    hostName = "rpifour1.ts.r10e.tech";
    sshUser = "cole";
    # ❯ echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOocMaAv2g1YK6SBFUYl4azZ0dGRid07D9CN8TQ2CCAa" | base64 -w0
    sshHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9vY01hQXYyZzFZSzZTQkZVWWw0YXpaMGRHUmlkMDdEOUNOOFRRMkNDQWEK";
    systems = [ "aarch64-linux" ];
    mandatoryFeatures = [];
    supportedFeatures = [];
    speedFactor = 1;
    maxJobs = 4;
  };
}