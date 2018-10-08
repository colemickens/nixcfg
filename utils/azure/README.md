# Blah

# TODO

1. split out the azure bit into "./upload-store.sh /var/lib/nixcache" to sync our store to azure
   (could make it trivial to add new sources, just implement recursive blob list, or even just two dirs)

2. figure out how to unify the ./build-upload-all.sh which points to a single nix expr, with
   ./build-upload-xeep.sh that does the whole thing for one machine with `NIX_PATH` specifically


