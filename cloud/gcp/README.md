Boots a machine in GCP, on the free tier, capable of 
downloading things and pushing them to my google drive acct.

./upload-image.sh && ./boot-vm.sh should work and in theory
are flexible enough to work for anyone with just a few env vars.

Usage in this repo:

```bash
./upload-image.sh ../../machines/gcpvm/default.nix
```
