# EAW_LMT
This repository is home to both the EAW_LMT tool to pack eaw mods fast to fix perfomance issues particular to linux, as well as other troubleshooting tips to improve the Empire at War experience on linux distros

# Index
- [Linux Concepts](#linux-concepts)
- [Requirements](#requirements)
- [Using EAW_LMT](#using-eaw_lmt)
- [Troubleshooting](#troubleshooting)
- [EAW Game font](#eaw-game-font)

# Linux Concepts
Some concept clarification in order to follow the instructions easier. 

## Steam location
Usually in your personal folder ```home/username``` there is a hidden folder ./steam, your file explorer should have an option by just right clicking to show hidden files(otherwise just check the settings). From inside there should be a direct link to the steam contents where you will find ```steamapps``` and inside ```common``` where the game and most proton versions are located, and the ```workshop``` folder which leads to downloaded mods.

## Compatdata and Saves location
Inside ```steamapps``` there is the ```compatdata``` folder, this folder have a bunch of id folders, which have the same id as your games. 32470 is the id for EAW. These replicate the folder hierarchy of windows, your saves should be at ```32470/pfx/drive_c/users/steamuser/Saved Games/Petroglyph/Empire At War - Forces of Corruption/Save ```

## Different Linux OS

You probably have downloaded Pop OS, Manjaro, Linux mint, Cachyos, or even SteamOS (maybe looking for making eaw mods run better on the steam deck). Most distros downloaded are forks or variations of a couple main OS, usually Debian, Arch, Fedora. 

This is important to know, because most instructions for installing some prerequisite will mention how to do it for these base OS (if you have a OS that is not a fork of any of these, you are welcome to open an issue, though searching the web for the equivalent way for your system will always be faster) 

This chart is not up to date, if your OS is not present here, check the main website/wiki of your system to see which system is based on, and what commands apply.

## Linux Distros

| DEBIAN                                                | ARCH                                 | FEDORA                               | 
| --------------------------------------------------- | -------------------------------------------- | -------------------------------------------- | 
| Ubuntu      |   SteamOS    | Bazzite |
| Kubuntu      | Manjaro | Nobara |
| Linux Mint   | Garuda  |  |
| PopOS     |CachyOS  |  |
| Elementary OS                |  |  |
| Drauger OS               |  |  |

## Installing from terminal
To Install new packages in general from terminal
| DEBIAN                                                | ARCH                                 | FEDORA                               | 
| --------------------------------------------------- | -------------------------------------------- | -------------------------------------------- | 
| sudo apt install     |   sudo pacman -S   | sudo dnf install |

Installing rsync for example on Linux Mint:
```sudo apt install rsync```  
[Back to Index](#index)
# Requirements
* An EAW mod already downloaded by the Steam Workshop
* Rsync
  * Check if you have it by open a terminal and type ``` rsync --version ```
* Wine 
  * Check if you have it by open a terminal and type ``` wine --version ```
  * Proton from steam doesn't count, you need wine on its own

To install them, on a terminal anywhere:
| DEBIAN                                                | ARCH                                 | FEDORA                               | 
| --------------------------------------------------- | -------------------------------------------- | -------------------------------------------- | 
| sudo apt install rsync    |   sudo pacman -S rsync  | sudo dnf install rsync |
| sudo apt install wine    |   sudo pacman -S wine  | sudo dnf install wine |


* Wine Mono
  * If you ran winecfg at least once after installing wine, you should have it
  * Check if you have it by open an terminal from your username folder and type ``` ls ~/.wine/drive_c/windows/mono/ ```

After running winecfg, you should see this window

![winecfg](https://github.com/user-attachments/assets/17212ab3-0602-486e-ab50-08801a806a32)

You can close it once you see it

If after running winecfg, mono doesn´t show, reinstall wine and run winecfg again.

[Back to Index](#index)

# Using EAW_LMT
* Once downloaded, extract the content anywhere.
* Check the location of the EAW mod you want to process, EAW mods are located in ```/steamapps/workshop/content/32470```
* Copy or move the ```EAW_LMT``` folder next to the Data folder of the EAW mod (the folder, not the files)
* Inside the ```EAW_LMT``` folder you will see a ```EAWM_BUILD.sh``` file, either:
  * Open a terminal in that location (usually right clicking in the file explorer should show the option) and type: ```bash EAWM_build.sh```
  * Change the permission of the file to be allowed to be run as a programm and double click on it (select to run in a terminal if the option shows up)
* Wait and let it do it's thing.
* Either because it completes all operations or something went wrong, you will see the following ```Press Enter to close this window...```
* If everythign was fine, you now has a local mod and you will need to set your launch options with ```MODPATH=Mods/``` instead of ```STEAMMOD=```
# Troubleshooting
* Most problems will be related to some requirement that wasn't fullfiled
* For any problem a ```EAWM_log.txt``` file should show up in the same location, if the problem is not clear, feel free to open an issue on this git uploading the log.

[Back to Index](#index)
# EAW Game font
There is an odd interacction where Proton returns the correct font back to the game, but does it by giving back the family-name value of the font, while the game is waiting for the type-name. 
A copy of a "tweaked" version of the font can be found [here](https://www.dropbox.com/scl/fi/cn94vw9mjuq0rt6s95z3z/EaW-Font-Proton.zip?rlkey=sxbg6dio45en9a2vox1dhwt3d&st=cn13oylc&dl=0)
In order to make the game load the new font, do the following:
* Extract the fonts
* Check what proton version you are using for EAW
* Go to the path directory of that proton version. Proton folders are located in the same steam folder as your games in ```steamapps/common```
  *  Unless you are using a custom one in which case is probably in ```compatibilitytools.d``` on the base Steam folder   
* Inside the proton folder, paste the fonts at ```files/share/fonts```
