# declarative hydra

this is about as declarative as it gets with hydra (at least as far as I've seen publicly)

this uses (via flakes): 
- hydra's hydra-dev module
- my own hydra-auto module for idempotent admin/project setup

this auto-configures:
- hydra queue runner's ssh key
- nice-looking hydra machine config (instead of needing to manually know how to form a machine line)
- the restrict-eval patch that everyone seems to need (???)
- 

you might want:
- hydra-machine-txt-builder.nix (Unless you've already written this, you might find it handy...)
