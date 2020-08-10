flakes
nfs
azure agent
azure uefi
azure modules
azure flake
sops-nix
sops
sops demo


how i use nix
- no huge nix-build... expressions
- no nixos-generators

Putting the Gaming PC to work as a nix builder when not in use netboot



# Protecting my secrets with Nix and Sops

# A Secret-Secured Netboot-ed Nix Remote Builder
 - we want to push to cachix
 - we dont want to use the disk in the machine
 - we want to keep secrets encrypted everywhere
 - we want the machine to default to netbooting and be available

(then the post about netboot + cachix key + yubikey ^)



# Automated UEFI Http Boot with RPI4 + Unifi

# configure the pi for net boot

# configure unifi to advertise pxe boot

# configure nix to serve http info


# what i use - continuous integration

- home rolled nix-flake driven hydra-clone "cyclops"
- SOPS rules everything around me


# singular.me
 ## nix
 # r10e.systems | technologies




# getting started with nix + sops + drone + niche
1. create gpg-key in one step
2. encrypt with gpg via gopass (or your existing backup mechanism)
3. this is now your CI key for drone
> example sample job 
>   load data from sops
>   nix-build -A hello | niche push demo.niche.r10e.org
4. test



# azure ideas
aci integration... everywhere? (could easily be drone remote docker runners?)