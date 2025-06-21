#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.0 2025"
# "By Alexey Skywalker "
# "================================================================================"

source file_arrays.sh
source Utilities.sh
script_dir=""
MOD_NAME=$1

DEST="To be assigned"
SIZE_LIMIT=1500000000
SIZE_BYTES=0

N_AUDIO=1
N_MODELS=1
N_TEXTURES=1
N_SCRIPTS=1
N_XML=1

CFG="./build.cfg"
MEGA="./megaMODfiles.xml"

SETUP()
{
    echo "SETTING VALUES"
    shopt -s nocaseglob
    shopt -s nocasematch
    STEAMAPPS_PATH="${PWD%%/steamapps/*}/steamapps"
    DEST="$STEAMAPPS_PATH/common/Star Wars Empire at War/corruption/Mods/"
    
    FOLDER_CHECK "../DATA/AUDIO" N_AUDIO $SIZE_LIMIT
    FOLDER_CHECK "../DATA/ART/MODELS" N_MODELS $SIZE_LIMIT
    FOLDER_CHECK "../DATA/ART/TEXTURES" N_TEXTURES $SIZE_LIMIT
    # FOLDER_CHECK "../DATA/SCRIPTS" N_SCRIPTS $SIZE_LIMIT
    # FOLDER_CHECK "../DATA/XML" N_XML $SIZE_LIMIT

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

rsync -a --progress --exclude='ART/MODELS' --exclude='ART/TEXTURES' --exclude='AUDIO/' --exclude='megafiles.xml' "../DATA/" "$F_DEST"
echo "Packing Files"
COPY_CONTENT "TEMP/DATA/ART/TEXTURES" "TEMP/TEXTURES" "DATA/ART/TEXTURES" $N_TEXTURES 0 $CFG "$F_DEST"
COPY_CONTENT "../DATA/AUDIO" "TEMP/AUDIO" "DATA/AUDIO" $N_AUDIO 1 $CFG "$F_DEST"
COPY_CONTENT "../DATA/ART/MODELS" "TEMP/MODELS" "DATA/ART/MODELS" $N_MODELS 0 $CFG "$F_DEST"
# COPY_CONTENT "../DATA/SCRIPTS" "TEMP/SCRIPTS" "DATA/SCRIPTS" $N_SCRIPTS 1 $CFG "$F_DEST"
# COPY_CONTENT "../DATA/XML" "TEMP/XML" "DATA/XML" $N_SCRIPTS 1 $CFG "$F_DEST"

MOVE_MEGS "$F_DEST"

EDIT_MEGA "../DATA/megafiles.xml" "$MEGA" "$F_DEST"
rm -r ./TEMP
echo -e "\n"
echo "ALL OPERATIONS FOR $MOD_NAME EXECUTED SUCCESFULLY"