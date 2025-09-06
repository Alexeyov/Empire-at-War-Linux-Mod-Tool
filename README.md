# Empire At War Linux ModTool
This repository is home to the EAW_LMT tool to pack eaw mods fast and fix/improve perfomance issues particular to linux, as well as other troubleshooting tips to improve the Empire at War experience on linux distros

# Index

- [Requirements](#requirements)
- [Using EAW_LMT](#using-eaw_lmt)
- [Troubleshooting](#troubleshooting)
- [EAW Game font](#eaw-game-font)
- [Other EAW tips](#other-eaw-tips)
- [Linux Concepts](#linux-concepts)
  - [State of EAW on Linux](#state-of-eaw-on-linux)
  - [Steam Location](#steam-location)
  - [Compatdata and Saves location](#compatdata-and-saves-location)
  - [Different Linux OS](#different-linux-os)
  - [Installing from terminal](#installing-from-terminal)
- [Credits](#credits)

# Introduction
The EAW_LMT is a tool created to fix the performance problems of EAW present in Linux (mainly a particular stuttering). This is achieved by automating a tedious process to pack mod files into .megs. While there can be stuttering present in specific instances on mods, on linux the problem multiplies by showing up in most areas.

The reason for this stuttering is due to how mods have their files setup up. While the base game have everything packed into .megs, most mods have all their files loose (main reason is make it easy for development purposes, specially with submods). There are 2 folders in particular that create all the problems (Textures and Models) These folders can have thousands of files and be multiple GBs in size all at the same level (meaning the files are not distributed in subfolders, unlike the rest of the files). This create stress to Proton, which have to keep up with the big number of file operations call for these folders.

The workaround is to replicate the base game by packing the files back into several megs. However because doing so is quite tedious, I created this tool that automates the whole process.

What does the tool do?
 * It creates a new folder under /steamapps/common/Star Wars Empire at War/corruption/Mods/modname, making this a local mod is required to avoid steam workshop messing with it (local mod is a mod that is within the mods folder of EAW, instead of the usual workshop folder of Steam)
 * It copies most mod files to the new location
 * The content of Textures* and Models gets moved to a TEMP folder where it is processed and packed into .megs
 * The megs then get moved to the mods location
 * After that you will launch the new mod by setting ```MODPATH=Mods/modname``` in the steam launcher settings of EAW
 * ```modname``` will be the same id number as it is shown in the workshop

*(In the case of Textures, some files that share the same name of base game files need to be loose, this however do not impact performance)

[Back to Index](#index)

# Requirements
If you are not familiar with Linux distros at all, you may need to check on some of the info on [Linux Concepts](#linux-concepts) when installing the requirements. I recommend you to check it before continuing.

* Need to run the base game and Foc at least one (activate proton in the compatibility tab on the game properties on Steam)
* An EAW mod already downloaded by the Steam Workshop (duh)
* Rsync
  * Rsync is a tool for copying/moving/transfer files with extra options and features
  * Check if you have it by open a terminal and type ``` rsync --version ```
* Wine
  * Wine is the compatibility layer to run windows apps on Linux which Proton is based on
  * Check if you have it by open a terminal and type ``` wine --version ```
  * The Flatpak version of Wine WON´T work for this.
  * Proton from steam doesn't count, you need wine on its own (important to note that in order to play games on steam with Proton you don't need Wine, you just need Wine so a specific tool to pack the files in .megs can run) 

To install them, on a terminal anywhere: 
| DEBIAN                                                | ARCH                                 | FEDORA                               | 
| --------------------------------------------------- | -------------------------------------------- | -------------------------------------------- | 
| sudo apt install rsync    |   sudo pacman -S rsync  | sudo dnf install rsync |
| sudo apt install wine    |   sudo pacman -S wine  | sudo dnf install wine |

* Wine Mono
  * If you ran ```winecfg``` on a terminal at least once after installing wine, you should have it
  * Check if you have it by navigating to  ```personalfolder/.wine/drive_c/windows/mono/ ``` you should see mono 2.0 or similar
  * Or faster by copy pasting this on an terminal open from your username folder ``` ls ~/.wine/drive_c/windows/mono/ ```

After running winecfg, you should see this window, you can close it once you see it

![winecfg](https://github.com/user-attachments/assets/17212ab3-0602-486e-ab50-08801a806a32)

If after running winecfg, mono doesn´t show after doing ``` ls ~/.wine/drive_c/windows/mono/ ```, either:
  * Reinstall wine and run ```winecfg``` again.
  * After installing wine, do ```wine --version``` on a terminal, then go to https://dl.winehq.org/wine/wine-mono/ to download the .msi file for your wine version.
      * Install this file by running the following command on a terminal located in the same location as the file: ```wine msiexec -i  wine-mono-10.1.0-x86.msi``` (replace wine-mono-10.1.0-x86.msi with the file name you may have)

[Back to Index](#index)

# Using EAW_LMT
* This tool is only needed for the big mods, submods usually don´t have the amount of texture/model files that would bring the game down on Proton.
* Once downloaded from [releases](https://github.com/Alexeyov/Empire-at-War-Linux-Mod-Tool/releases), extract the content anywhere.
* Check the location of the EAW mod you want to process, EAW mods are located in ```/steamapps/workshop/content/32470```
* Copy or move the ```EAW_LMT``` folder next to the Data folder of the EAW mod (the folder, not the files)
* Inside the ```EAW_LMT``` folder you will see a ```EAWM_BUILD.sh``` file, either:
  * Open a terminal in that location (usually right clicking in the file explorer should show the option) and type: ```bash EAWM_BUILD.sh```
  * Change the permission of the file to be allowed to be run as a programm and double click on it (select to run in a terminal if the option shows up)
* Wait and let it do it's thing.
* Either because it completes all operations or something went wrong, you will see the following ```Press Enter to finish the program...```
* If everythign was fine, you now has a local mod and you will need to set your launch options with ```MODPATH=Mods/``` instead of ```STEAMMOD=``` This local mod is located at ```/steamapps/common/Star Wars Empire at War/corruption/Mods``` within the steam folder
# Troubleshooting
* Most problems will be related to some requirement that wasn't fullfiled
* For any problem a ```EAWM_log.txt``` file should show up in the same location, if the problem is not clear, feel free to open an issue on this git uploading the log.

[Back to Index](#index)
# EAW Game font
In the process of researching the reason of modded EAW's poor perfomance I was able to create a fix to the game's font not loading properly.
There is an odd interaction where Proton returns the correct font back to the game, but does it by giving back the family-name value of the font, while the game is waiting for the type-name. 
A copy of a "tweaked" version of the font can be found [here](https://www.dropbox.com/scl/fi/cn94vw9mjuq0rt6s95z3z/EaW-Font-Proton.zip?rlkey=sxbg6dio45en9a2vox1dhwt3d&st=cn13oylc&dl=0)
In order to make the game load the new font, do the following:
* Extract the fonts
* Check what proton version you are using for EAW
* Go to the path directory of that proton version. Proton folders are located in the same steam folder as your games in ```steamapps/common```
  *  Unless you are using a custom one in which case is probably in ```compatibilitytools.d``` on the base Steam folder   
* Inside the proton folder, paste the fonts at ```files/share/fonts```

[Back to Index](#index)

# Other EAW tips
## Custom launcher for mods

![EawMods](https://github.com/user-attachments/assets/50acc8f8-02d1-4908-a7d9-8370bcaf4491)

In order to add a custom launcher on steam for EAW mods. After you add StarWarsG.exe as a non steam game, you need to do the following:

In the settings of that new shorcut, check the compatibility tab:
![CheckCompat2](https://github.com/user-attachments/assets/74c1c931-5867-4de0-b702-9b4cdb1c18c0)

In the shorcut tab, in the launch options, you need to add the following BEFORE ```Modpath=Mods/mod```

DEBIAN
```STEAM_COMPAT_DATA_PATH="$HOME/.steam/debian-installation/steamapps/compatdata/32470" %command% Modpath=Mods/mod```
ARCH & FEDORA
```STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/32470" %command% Modpath=Mods/mod```

For other distros I recommend to manualy search for the location in your file explorer, and once you are at ```compatdata/32470```, copy the path and past it

![LaunchOpt](https://github.com/user-attachments/assets/79a1e4b9-b4dc-4f24-aff9-699f4b46691f)

[Back to Index](#index)


# Linux Concepts
Some concept clarification in order to follow the instructions easier. 

## State of EAW on Linux
Eaw base game and the Foc expansion (steam version) are 100% compatible with Proton on any Linux OS, however as of writing this (05-September-2025) I am not aware of any version of proton (From Steam or Custom ones), dedicated gaming linux app, Linux OS, nor any version of the Linux kernel, that allows playing modded EAW out of the box. So for the time being this tool is needed to play modded on Linux.

## Steam location
Usually in your personal folder ```home/username``` there is a hidden folder ./steam, your file explorer should have an option by just right clicking to show hidden files(otherwise just check the settings). From inside there should be a direct link to the steam contents where you will find ```steamapps``` and inside ```common``` where the game and most proton versions are located, and the ```workshop``` folder which leads to downloaded mods.

## Compatdata and Saves location
Inside ```steamapps``` there is the ```compatdata``` folder, this folder have a bunch of id folders, which have the same steamid as your games, 32470 being the id for EAW. These replicate the folder hierarchy of windows, and have files needed in order to run your games properly. 

EAW saves should be at ```32470/pfx/drive_c/users/steamuser/Saved Games/Petroglyph/Empire At War - Forces of Corruption/Save ```

## Different Linux OS

You probably have downloaded Pop OS, Manjaro, Linux mint, Cachyos, or even SteamOS (maybe looking for making eaw mods run better on the steam deck). Most distros downloaded are forks or variations of a couple main OS, usually Debian, Arch, Fedora. 

This is important to know, because most instructions for installing some prerequisite will mention how to do it for these base OS, however exceptions like Bazzite may apply. In any case be prepared to search the web for the equivalent way for your system on how to do things.

This chart is not up to date, if your OS is not present here, check the main website/wiki of your system to see which system is based on, and what commands apply.

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

Known Exceptions:
  -Bazzite: sudo rpm-ostree install 

Installing rsync for example on Linux Mint:
```sudo apt install rsync```  
[Back to Index](#index)

# Credits

[Lukas Grünwald](https://github.com/gruenwaldlk/eaw-build) For creating the Eaw-build tool(yvaw-build.exe)

OldPalSteve Testing and Feedback
