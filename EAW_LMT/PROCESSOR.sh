#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.1 2025"
# "By Alexey Skywalker "
# "================================================================================"

source file_arrays.sh
source Utilities.sh

MOD_NAME=$1
DEST=""
CFG="./build.cfg"
MEGA_MOD="./modmegafiles.xml"
MEGA_BASE="./basemegafiles.xml"

SETUP()
{
    echo "SETTING VALUES"
    shopt -s nocaseglob
    shopt -s nocasematch

    STEAMAPPS_PATH="${PWD%%/steamapps/*}/steamapps"
    DEST="$STEAMAPPS_PATH/common/Star Wars Empire at War/corruption/Mods/"
    F_DEST=$DEST/$MOD_NAME/DATA

    mkdir -p "$F_DEST"
    mkdir -p "TEMP/DATA/"
    echo "Mod folder created with name $MOD_NAME at $F_DEST"
    echo "Temporary folder created"
    echo -e "\n"
}

#SCRIPT STARTS
SETUP
sleep 1.0
VANILLA_CHECK "../DATA" "$DEST" "$MOD_NAME"
echo "Copying over miscellaneous files"
rsync -a --progress --exclude='ART/MODELS' --exclude='ART/TEXTURES' --exclude='megafiles.xml' "../DATA/" "$F_DEST"
rsync -a --include='*.jpg' --include='*.png' --include="*/" --exclude='*' "../DATA/ART/TEXTURES" "$F_DEST/ART"
echo "Packing Files"
COPY_CONTENT "TEMP/DATA/ART/TEXTURES" "TEMP/TEXTURES" "DATA/ART/TEXTURES" 0 $CFG "$F_DEST"
COPY_CONTENT "../DATA/ART/MODELS" "TEMP/MODELS" "DATA/ART/MODELS" 0 $CFG "$F_DEST"

MOVE_MEGS "$F_DEST"

EDIT_MEGA "../DATA/megafiles.xml" "$MEGA_MOD" "$MEGA_BASE" "$F_DEST"
rm -r ./TEMP
rm -r ./_log
echo -e "\n"
echo "ALL OPERATIONS FOR $MOD_NAME EXECUTED SUCCESFULLY"