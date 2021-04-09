# GreyScript Library

Collection of scripts for [GreyHack](https://store.steampowered.com/app/605230/Grey_Hack/).

# Requirements

These scripts are using [Greybel](https://github.com/ayecue/greybel).

# Install

To make things a little bit more easy there's a installer file. First you have to build it though.
```
chmod +x build.sh
./build.sh
```
Now you copy the content of the installer file to Grey Hack and execute the installer.
```
build installer.src /usr/bin
installer
build /home/user-folder/scripts/script-file /usr/bin
```
This should create all necessary folders and files.

Note: It will automatically split files so you don't hit the word limit in Grey Hack.
