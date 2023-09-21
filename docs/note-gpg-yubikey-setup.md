## prep

let-env GNUPGHOME=/tmp/_GNUPG
cp /mnt/data/t5/DATA/SAMMY/gpg_backup/.gnupg /tmp/_GNUPG
cp ~/.local/share/gnupg/gpg-agent.conf /tmp/_GNUPG/gpg-agent.conf

## start (card setup)
````
gpg --card-edit
admin
kdf-setup
passwd # 1 - change the pin
passwd # 3 - change the admin pin
name # set the surname/given-name
lang # set preferred name
url # set to 'https://github.com/colemickens.asc'
sex
login # set to 'cole' (?)
````

## start (card keytocard) 

```
gpg --edit-key 8A94ED58A476A13AE0D6E85E9758078DE5308308
key 1 # select the signing key
keytocard

key 1 # de-select the signing key
key 2
keytocard

key 2
key 3
keytocard
```

## relearn new key
```
gpg-connect-agent "scd serialno" "learn --force" /bye
```


## notes/warnings:

admin pin is the same as the regular pin
