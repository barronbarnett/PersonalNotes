# Configuring GnuPGP to Merge With the Yubi Key
The [Yubikey instruction](https://support.yubico.com/support/solutions/articles/15000006420-using-your-yubikey-with-openpgp) on the subject are fairly solid, however they fall down when you are attempting to have multiple Yubi Keys all tied to the same master key.

I found [this guide](https://www.esev.com/blog/post/2015-01-pgp-ssh-key-on-yubikey-neo/) from 2015 which was some what accurate but is now outdated in a few things.

This guide is written specifically from the perspective of working in an OSX environment. However the only real difference should be the method of installing the tools.

# A note on keys
PGP is designed so you can have master and sub keys. Much like intermediate certificate authorities.  The benefit here is you have a master key that you keep on secure storage in a secure place, and sub keys exist on your YubiKey. So in the event of loss or theft you only need to revoke the subkey while the master key can then be used to issue a new key.

To simplify thing though. We use the same encryption secret on all keys, otherwise we would have to pair the message to the correct key. Additionally if you lose a key you would no longer be able to unlock those messages so having a second key as a backup fails in this use case.

# Install the tools

Install the YubiKey managment tools

> ~$ brew install ykman
> ~$ brew cask install gpg-suite
> ~$ brew install gnupg pinentry-mac

# Lets generate a master key
We are going to work with a clean GPG environment to ensure safety of any other keys that are in the environment given the probability of needing to delete and recreate keys.

> ~$ mv .gnupg .gnupg.orig  
> ~$ ln -s ```$secure_storage_location``` .gnupg  
> ~$ echo "cert-digest-algo SHA512" >> .gnupg/gpg.conf  
> ~$ echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" >> .gnupg/gpg.conf  

Now that we have the basics of the above we need to generate the master key itself.

Note you want the actions for the master key to be Sign, Certify, and Encrypt. Toggle these options as necessary to get this arragement.

<pre>
~$ gpg --expert --full-gen-key  
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  

Please select what kind of key you want:  
   (1) RSA and RSA (default)  
   (2) DSA and Elgamal  
   (3) DSA (sign only)  
   (4) RSA (sign only)  
   (7) DSA (set your own capabilities)  
   (8) RSA (set your own capabilities)  
   (9) ECC and ECC  
  (10) ECC (sign only)  
  (11) ECC (set your own capabilities)  
  (13) Existing key  

Your selection? <mark>8</mark>  
 
Possible actions for a RSA key: Sign Certify Encrypt Authenticate  
Current allowed actions: <b><i>Sign Certify Encrypt</b></i>  
 
   (S) Toggle the sign capability  
   (E) Toggle the encrypt capability  
   (A) Toggle the authenticate capability  
   (Q) Finished  
 
Your selection? <mark>q</mark>  
RSA keys may be between 1024 and 4096 bits long.  
What keysize do you want? (2048) <mark>2048</mark>  
Requested keysize is 2048 bits  
Please specify how long the key should be valid.  
     0   = key does not expire  
    <n>  = key expires in n days  
    <n>w = key expires in n weeks  
    <n>m = key expires in n months  
    <n>y = key expires in n years  
Key is valid for? (0) <mark>0</mark>  
Key does not expire at all  
Is this correct? (y/N) <mark>y</mark>
 
GnuPG needs to construct a user ID to identify your key.  
 
Real name: <mark>Testing</mark>  
Email address: <mark>testing@notreal.com</mark>  
Comment:  
You selected this USER-ID:  
    "Testing <testing@notreal.com>"  
 
Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? <mark>O</mark>  
We need to generate a lot of random bytes. It is a good idea to perform  
some other action (type on the keyboard, move the mouse, utilize the  
disks) during the prime generation; this gives the random number  
generator a better chance to gain enough entropy.  
gpg: key 87811D9FDE4D5E88 marked as ultimately trusted  
gpg: revocation certificate stored as > /.gnupg/openpgp-revocs.d/9B065520B72349E9C501C6C487811D9FDE4D5E88.rev'  
public and secret key created and signed.  
 
pub   rsa2048 2019-02-02 [SCE]  
      9B065520B72349E9C501C6C487811D9FDE4D5E88  
uid                      Testing <testing@notreal.com>  
</pre>

Note the Unique Key ID returned above, _87811D9FDE4D5E88 in this example_, we will be using it a lot in the following commands.

If you need to find it again, execute:
```
gpg --list-secret-keys --keyid-format LONG 
sec   rsa2048/87811D9FDE4D5E88 2019-02-02 [SCE]
      9B065520B72349E9C501C6C487811D9FDE4D5E88
uid                 [ultimate] Testing <testing@notreal.com>
```

## Generating they encryption subkey
Once this is done we need to generate an encryption sub key that will be shared between the two YubiKeys.  You need to create offline so you can copy it to each.  Otherwise if you lose a key you will not be able to fall to the backup key to recover the data.

Each key though will have it's own signature and authentication keys.

<pre>
~$ gpg --edit-key 87811D9FDE4D5E88    
gpg: WARNING: unsafe permissions on homedir '/Users/barronb/.gnupg'  
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.  
This is free software: you are free to change and redistribute it.  
There is NO WARRANTY, to the extent permitted by law.  
  
Secret key is available.  
  
sec  rsa2048/87811D9FDE4D5E88  
     created: 2019-02-02  expires: never       usage: SCE   
     trust: ultimate      validity: ultimate  
[ultimate] (1). Testing <testing@notreal.com>  
 
gpg> <mark>addkey</mark>  
Please select what kind of key you want:  
   (3) DSA (sign only)  
   (4) RSA (sign only)  
   (5) Elgamal (encrypt only)  
   (6) RSA (encrypt only)  
Your selection? <mark>6</mark>  
RSA keys may be between 1024 and 4096 bits long.  
What keysize do you want? (2048) <mark>2048</mark>  
Requested keysize is 2048 bits  
Please specify how long the key should be valid.  
         0 = key does not expire  
      <n>  = key expires in n days  
      <n>w = key expires in n weeks  
      <n>m = key expires in n months  
      <n>y = key expires in n years  
Key is valid for? (0) <mark>0</mark>
Key does not expire at all  
Is this correct? (y/N) <mark>y</mark>  
Really create? (y/N) <mark>y</mark>
We need to generate a lot of random bytes. It is a good idea to perform  
some other action (type on the keyboard, move the mouse, utilize the  
disks) during the prime generation; this gives the random number  
generator a better chance to gain enough entropy.  
  
sec  rsa2048/87811D9FDE4D5E88  
     created: 2019-02-02  expires: never       usage: SCE
     trust: ultimate      validity: ultimate  
ssb  rsa2048/5D02606A54E9CAED  
     created: 2019-02-03  expires: never       usage: E
[ultimate] (1). Testing <testing@notreal.com>  
  
gpg> <mark>save</mark>  
</pre>

## Exporting the Keys so we have a backup. 
We want to export the secret keys so we can report them cleanly after moving them to the YubiKey.

```
~$ gpg -a --export-secret-keys testing@notreal.com > 87811D9FDE4D5E88_5D02606A54E9CAED_private.asc
~$ gpg -a --export testing@notreal.com > 87811D9FDE4D5E88_5D02606A54E9CAED_public_preyubi.asc
~$ gpg --export-ownertrust > 87811D9FDE4D5E88_5D02606A54E9CAED_ownertrust-gpg.txt
```

We now have a copy of our secret keys we can now continue with programming the YubiKeys.

## Configuring the YubiKeys

When programming any key other than the first one, run the following commands.
```
~$ gpg --delete-secret-key 87811D9FDE4D5E88
~$ gpg --import < 87811D9FDE4D5E88_5D02606A54E9CAED_private.asc 
```

Now to program the YubiKey:

<pre>
~$ gpg --edit-key 87811D9FDE4D5E88

# First, create the signing key
gpg> <mark>addcardkey</mark>

 Signature key ....: [none]
 Encryption key....: [none]
 Authentication key: [none]

Please select the type of key to generate:
   (1) Signature key
   (2) Encryption key
   (3) Authentication key
Your selection? <mark>1</mark>

Please specify how long the key should be valid.
         0 = key does not expire
        = key expires in n days
      w = key expires in n weeks
      m = key expires in n months
      y = key expires in n years
Key is valid for? (0) <mark>0</mark>
Key does not expire at all  
Is this correct? (y/N) <mark>y</mark>
Really create? (y/N) <mark>y</mark> 
                      
...
# Do the same for the authentication key
gpg> <mark>addcardkey</mark>

 Signature key ....: AAAA BBBB CCCC DDDD EEEE  FFFF 1111 2222 3333 4444
 Encryption key....: [none]
 Authentication key: [none]

Please select the type of key to generate:
   (1) Signature key
   (2) Encryption key
   (3) Authentication key
Your selection? <mark>3</mark>
                 
Please specify how long the key should be valid.
         0 = key does not expire
        = key expires in n days
      w = key expires in n weeks
      m = key expires in n months
      y = key expires in n years
Key is valid for? (0) <mark>0</mark>
Key does not expire at all
Is this correct? (y/N) <mark>y</mark>
Really create? (y/N) <mark>y</mark>  
                      
...
</pre>
Now we need to grab the private encryption key and move to the card. First select the key then move it.

<pre>
gpg> <mark>toggle</mark>
           
sec  rsa2048/87811D9FDE4D5E88
     created: 2019-02-02  expires: never       usage: SCE 
     trust: ultimate      validity: ultimate
ssb  rsa2048/5D02606A54E9CAED
     created: 2019-02-03  expires: never       usage: E   
[ultimate] (1). Testing <testing@notreal.com>

gpg> <mark>key 1</mark>
          
sec  rsa2048/87811D9FDE4D5E88
     created: 2019-02-02  expires: never       usage: SCE 
     trust: ultimate      validity: ultimate
ssb* rsa2048/5D02606A54E9CAED
     created: 2019-02-03  expires: never       usage: E   
[ultimate] (1). Testing <testing@notreal.com>

gpg> <mark>keytocard</mark>
 Signature key ....: AAAA BBBB CCCC DDDD EEEE  FFFF 1111 2222 3333 4444
 Encryption key....: [none]
 Authentication key: AAAA BBBB CCCC DDDD EEEE  FFFF 1111 2222 3333 4444

Please select where to store the key:
   (2) Encryption key
Your selection? <mark>2</mark>

...

gpg> <mark>save</mark>
</pre>

## Final Copies

First put your preferred keyserver information into the keys.
<pre>
~$ <mark>gpg --edit-key 87811D9FDE4D5E88</mark>

gpg> <mark>keyserver</mark>
Enter your preferred keyserver URL: <mark><i>your server url</i></mark>

gpg> <mark>showpref</mark>
[ultimate] (1). Testing <testing@notreal.com>
     Cipher: AES256, AES192, AES, CAST5, 3DES
     Digest: SHA512, SHA384, SHA256, SHA224, SHA1
     Compression: ZLIB, BZIP2, ZIP, Uncompressed
     Features: MDC, Keyserver no-modify
     Preferred keyserver: <i>your server url</i>
</pre>


Do a final copy of the public keys now that all of the YubiKeys have been added as subkeys.

``` ~$ gpg -a --export testing@notreal.com > testing_notreal_public.asc ```

Upload the output file so it is accessible via the URL specified above.

## Clean out the master keys and finalize the YubiKey config
Delete the symlink ```~$ rm .gnupg```
Move the files back ```~$ mv .gnupg.orig .gnupg```

Now lets do the final config on the card.

<pre>
~$ <mark>gpg --card-edit</mark>

...

gpg/card> <mark>admin</mark>
Admin commands are allowed

gpg/card> <mark>passwd</mark>
gpg: OpenPGP card no. D2760001240102010006095808000000 detected

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? <mark>1</mark>
PIN changed.

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? <mark>3</mark>
PIN changed.

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? <mark>q</mark>

gpg/card> <mark>url</mark>
URL to retrieve public key: <mark><i>your server url</i></mark>

gpg/card> <mark>fetch</mark>
gpg: requesting key from '<i>your server url</i>'
gpg: key 87811D9FDE4D5E88: "Testing <testing@notreal.com>" 1 new signature
gpg: Total number processed: 1
gpg:         new signatures: 1

gpg/card> <mark>quit</mark>
</pre>

## Configure the GPG agent so we can use it for SSH.

First we need to edit .gnupg/gpg-agent.conf

``` 
enable-ssh-support
write-env-file
use-standard-socket
default-cache-ttl 600
max-cache-ttl 7200
debug-level advanced
log-file ~/.gnupg/gpg-agent.log
```

Now we need to edit .bash_profile to start gpg-agent.

``` BASH
gpgconf --launch gpg-agent
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh
```
Extract your public key to upload via
``` BASH
ssh-add -L
```

Lastly there is a [script](restart_gpg.sh) to run in the event the agent isn't behaving correctly.
