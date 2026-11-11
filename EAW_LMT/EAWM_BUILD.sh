#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.1 2025"
# "By Alexey Skywalker "
# "================================================================================"

cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" || exit 1

source Utilities.sh

TOOL=("PROCESSOR.sh" "file_arrays.sh" "Utilities.sh" "yvaw-build.exe" "build.cfg" "basemegafiles.xml")
script_dir=$PWD
STEAM="${PWD%%/steamapps/*}/steamapps"
MOD_NAME=$(basename "$(dirname "$script_dir")")

INITIAL_CHECK()
{
    echo "CHECKING REQUIREMENTS:"
    if command -v wine &> /dev/null; then
        echo "Wine is installed: $(wine --version)"
    else
        echo "WARNING: Wine is not installed."
        echo "Please install it from the terminal using the for package management system command of your system:"
        echo "Examples:"
        echo "      Debian distros: sudo apt install wine"
        echo "      Arch distros: sudo pacman -S wine"
        echo "      Fedora distros: sudo dnf install wine"
        echo "IMPORTANT:"
        echo "      Please check what command is used by your system"
        echo "      Flatpak version of wine won´t work"
        echo "      After installing wine, run winecfg in a terminal and let it do its work"
        echo "Afterwards open a new terminal in your home folder, then"
        echo "run ls ~/.wine/drive_c/windows/mono/ , you should see mono2.0 or similar, mono is REQUIRED to run this program"
        read -p "Press Enter to close this window..."
        exit
    fi

    if ! command -v rsync &> /dev/null; then
        echo "WARNING: rsync is not installed and is required."
        echo "Please install it from the terminal using the for package management system command of your system:"
        echo "Examples:"
        echo "      Debian distros: sudo apt install rsync"
        echo "      Arch distros: sudo pacman -S rsync"
        echo "      Fedora distros: sudo dnf install rsync"
        echo "IMPORTANT: Please check what command is used by your system"
        read -p "Press Enter to close this window..."
        exit 1
    fi
    echo "rsync is installed"

	echo "CHECKING TOOLS"

    DATA_FOLDER=$(find ../ -maxdepth 1 -type d -iname "data")
    if [ ! -d "$DATA_FOLDER" ]; then
        echo "WARNING: Data Folder not preset, Aborting. Please relocate the pack tools folder next to the Data folder of a mod."
        read -p "Press Enter to close this window..."
        exit
    fi

    for element in "${TOOL[@]}"; do
        CHECK_FILE $element
    done
    echo -e "CHECK COMPLETE. PROCEEDING \n"
}

CHECK_FILE()
{
    TOOL_FILE=$1

    file_path="$script_dir/$TOOL_FILE"
    if [ ! -f "$file_path" ]; then
        echo "WARNING: $TOOL_FILE is not present, Aborting. Please place $TOOL_FILE next to this script file."
        if [ $TOOL_FILE == "yvaw-build.exe" ]; then
            echo "If you did´t download yvaw-build.exe. Please go to WEBSITE."
        fi
        read -p "Press Enter to close this window..."
       exit
    fi

    echo "$TOOL_FILE is present"
}

LOG_FILE="$STEAM/eaw_lmt_logs/$MOD_NAME.log"
mkdir -p "$(dirname "$LOG_FILE")"

if [[ -z "$LOGGING_ACTIVE" ]]; then
    export LOGGING_ACTIVE=1
    exec > >(tee "$LOG_FILE") 2>&1
fi


echo "================================================================================"
echo "EAW Linux ModTool v1.0.1 2025"
echo "By Alexey Skywalker "
echo "================================================================================"
sleep 0.5
INITIAL_CHECK
echo -e "PROCESSING "$MOD_NAME" MOD FOLDER"
STAGED_MOD_DIR=$(mktemp -d "$STEAM/eaw_lmt_stage.XXXXXX") || exit 1
trap 'rm -rf "$STAGED_MOD_DIR"' EXIT
if ! STAGE_MOD_COPY "$DATA_FOLDER" "$STAGED_MOD_DIR"; then
    echo "ERROR: Failed to stage the mod. See $LOG_FILE for details."
    exit 1
fi
mkdir -p "$STAGED_MOD_DIR/EAW_LMT"
if ! cp -a "${TOOL[@]}" "$STAGED_MOD_DIR/EAW_LMT/"; then
    echo "ERROR: Failed to stage the tool. See $LOG_FILE for details."
    exit 1
fi
sleep 0.5
if ! (cd "$STAGED_MOD_DIR/EAW_LMT" && bash PROCESSOR.sh "$MOD_NAME" "$STAGED_MOD_DIR/DATA"); then
    echo "================================================================================"
    echo "PACKING FAILED, the mod in Mods/$MOD_NAME is incomplete. See $LOG_FILE for details."
    echo "================================================================================"
    read -p "Press Enter to close this window..."
    exit 1
fi

echo -e "\n"
echo "================================================================================"
echo "ALL OPERATIONS EXECUTED SUCCESFULLY, REMEMBER TO SET YOUR LAUNCH OPTIONS TO:"
echo "MODPATH=Mods/$MOD_NAME"
echo "If you want a separate launcher for the mod, add this before MODPATH:"
echo "STEAM_COMPAT_DATA_PATH="$STEAM/compatdata/32470" %command%"
echo "================================================================================"
read -p "Press Enter to finish the program..."