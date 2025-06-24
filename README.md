# EAW_LMT
This repository is home to both the EAW_LMT tool to pack eaw mods fast to fix perfomance issues particular to linux, as well as other troubleshooting tips to improve the Empire at War experience on linux distros

# Index

- [Linux Concepts](#linux-concepts)
- [Requirements](#requirements)
- [Using EAW_LMT](#using-eaw_lmt)
- [Troubleshooting](#troubleshooting)
- [EAW Game font](#eaw-game-font)

# Linux Concepts
While the use of the EAW_LMT tool is simple, the requirements and setup before using it makes the needs to clarifiy a couple concepts in order to follow the instructions correctly. 

## Debian and Arch based/fork distros

You probably have downloaded Pop OS, Manjaro, Linux mint, Cachyos, or even SteamOS (maybe looking for making eaw mods run better on the steam deck). Most distros downloaded are forks or variations of a couple main OS, these are for the most part Debian, Arch, Fedora. 

This is important to know because most instructtions regarding installing some prerequisite will mention how to do it for Debian an Arch (if you have a OS that is not a fork of these 2, you are welcome to open an issue, though searching the web for the equivalent way for your system should be faster) 

This chart is not up to date, if your OS is not present here, check the main website/wiki of your system to see which system is based on.

## Tested Games

| DEBIAN                                                | ARCH                                 | FEDORA                               | 
| --------------------------------------------------- | -------------------------------------------- | -------------------------------------------- | 
| Ubuntu      |   SteamOS    | Bazzite |
| Kubuntu      | Manjaro | Nobara |
| Linux Mint   | Garuda  |  |
| PopOS     |CachyOS  |  |
| Elementary OS                |  |  |
| Drauger OS               |  |  |
|                  |  |  |
|                 |  |  |
|                 |  |  |

![linux-distro-family-chart-with-distros-based-derivatives-i-v0-0h0jbzn8ca2d1-3766210537](https://github.com/user-attachments/assets/f5331e28-45ed-4b9d-80fb-26fab04c6fc9)





# Requirements
* An EAW mod already downloaded by the Steam Workshop
* Rsync
 * Check if you have it by open a terminal and type ``` rsync --version ```
 * If nothing shows or rsync shows as not installed, install with

| DEBIAN                                                | ARCH                                 | FEDORA                               | 
| --------------------------------------------------- | -------------------------------------------- | -------------------------------------------- | 
| sudo apt install rsync      |   sudo pacman -S rsync    | sudo dnf install rsync |
* Wine
* Wine Mono







# Using EAW_LMT
* Once downloaded, extract the content anywhere.
* Check the location of the EAW mod you want to process, EAW mods are located in /steamapps/workshop/content/32470
* Copy or move the EAW_LMT folder next to the Data folder of the EAW mod (the folder, not the files)
* Inside the EAW_LMT folder you will see a EAWM_BUILD.sh file, either:
  * Open a terminal in that location (usually right clicking in the file explorer should show the option) and type: bash EAWM_build.sh
  * Change the permission of the file to be allowed to be run as a programm and double click on it (select to run in a terminal if the option shows up)
* Wait and let it do its thing.
* Either because it completes all operations or something went wrong, you will see the following "Press Enter to close this window..."
* If everythign was fine, you now has a local mod and you will need to set your launch options with MODPATH=Mods/ instead of STEAMMOD=
# Troubleshooting
* Most problems will be related to some requirement that wasn't fullfiled
* For any problem a EAWM_log.txt file should show up in the same location, if the problem is not clear, feel free to open an issue uploading the log.


# EAW Game font
There is an odd interacction where Proton returns the correct font back to the game, but does it by giving back the family-name value of the font, while the game is waiting for the type-name. 
A copy of a "tweaked" version of the font can be found here
In order to make the game load the new font, do the following:
* Extract the fonts
* Check what proton version you are using for EAW
* Go to the path directory of that proton version. Proton folders are located in the same steam folder as your games in steamapps/common.
  *  Unless you are using a custom one in which case is probably in compatibilitytools.d on the base Steam folder   
* Inside the proton folder, paste the fonts at files/share/fonts
