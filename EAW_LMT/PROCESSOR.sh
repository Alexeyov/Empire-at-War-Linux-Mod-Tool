#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.1 2025"
# "By Alexey Skywalker "
# "================================================================================"

source file_arrays.sh
source Utilities.sh

MOD_NAME=$1
MOD_DATA=$2
BASE_MOD=$3
PACKED_MEG_PREFIX="${MOD_NAME//[^[:alnum:]]/_}_"
DEST=""
CFG="./build.cfg"
MEGA_BASE="./basemegafiles.xml"

SETUP()
{
    echo "SETTING VALUES"
    shopt -s nocaseglob
    shopt -s nocasematch

    DEST="$(MODS_DIR)/"
    F_DEST=$DEST/$MOD_NAME/DATA
    RESOLVE_BASE_MOD_MEGAFILES

    mkdir -p "$F_DEST"
    mkdir -p "TEMP/DATA/"
    echo "Mod folder created with name $MOD_NAME at $F_DEST"
    echo "Temporary folder created"
    echo -e "\n"
}

RESOLVE_BASE_MOD_MEGAFILES()
{
    BASE_MOD_MEGAFILES=""
    if [[ -z "$BASE_MOD" ]]; then
        return
    fi

    BASE_MOD_MEGAFILES="$DEST$BASE_MOD/DATA/megafiles.xml"
    if [[ ! -f "$BASE_MOD_MEGAFILES" ]]; then
        echo "ERROR: $BASE_MOD_MEGAFILES not found. Pack the base mod with this tool first."
        exit 1
    fi
    if [[ ! -f "$DEST$BASE_MOD/launch_options.txt" ]]; then
        echo "ERROR: $BASE_MOD has no launch options. Pack the base mod with this version first."
        exit 1
    fi
    echo "Base mod megs will be read from $BASE_MOD_MEGAFILES"
}

#SCRIPT STARTS
SETUP
sleep 1.0
VANILLA_CHECK "$MOD_DATA" "$DEST" "$MOD_NAME"
echo "Copying over miscellaneous files"
rsync -a --progress --exclude='ART/MODELS' --exclude='ART/TEXTURES' --exclude='megafiles.xml' "$MOD_DATA/" "$F_DEST"
rsync -a --include='*.jpg' --include='*.png' --include="*/" --exclude='*' "$MOD_DATA/ART/TEXTURES" "$F_DEST/ART"
echo "Packing Files"
COPY_CONTENT "TEMP/DATA/ART/TEXTURES" "TEMP/TEXTURES" "DATA/ART/TEXTURES" $CFG "$F_DEST"
COPY_CONTENT "$MOD_DATA/ART/MODELS" "TEMP/MODELS" "DATA/ART/MODELS" $CFG "$F_DEST"

MOVE_MEGS "$F_DEST" "$PACKED_MEG_PREFIX"

INHERITED_MANIFEST=$(mktemp)
PRINT_INHERITED_MANIFEST "$MOD_DATA/megafiles.xml" "$MEGA_BASE" "$BASE_MOD_MEGAFILES" > "$INHERITED_MANIFEST"
EDIT_MEGA "$INHERITED_MANIFEST" "$PACKED_MEG_PREFIX" "$F_DEST"
rm "$INHERITED_MANIFEST"
PRINT_LAUNCH_OPTIONS "$MOD_NAME" "$BASE_MOD" > "$DEST$MOD_NAME/launch_options.txt"
rm -r ./TEMP
rm -r ./_log
echo -e "\n"
echo "ALL OPERATIONS FOR $MOD_NAME EXECUTED SUCCESFULLY"