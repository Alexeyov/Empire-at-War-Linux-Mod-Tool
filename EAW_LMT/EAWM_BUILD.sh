#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.0 2025"
# "By Alexey Skywalker "
# "================================================================================"

source Utilities.sh

TOOL=("PROCESSOR.sh" "file_arrays.sh" "Utilities.sh" "yvaw-build.exe" "build.cfg" "megaMODfiles.xml")
MOD_NAME="EAWMOD"

INITIAL_CHECK()
{
    if command -v wine &> /dev/null; then
        echo "Wine is installed: $(wine --version)"
    else
        echo "Wine is not installed. Please install it using your package manager."
        echo "You can install it with:"
        echo "      Debian distros: sudo apt install wine"
        echo "      Arch distros: sudo pacman -S wine"
        echo "      Fedora distros: sudo dnf install wine"
        echo "IMPORTANT: After installing wine, run winecfg in a terminal and let it do its work"
        echo "Afterwards open a new terminal in your home folder, then"
        echo "run ls ~/.wine/drive_c/windows/mono/ , you should see mono2.0 or similar, mono is REQUIRED to run this program"
        read -p "Press Enter to close this window..."
        exit
    fi

    if ! command -v rsync &> /dev/null; then
        echo "WARNING: rsync is not installed and is required."
        echo "You can install it with:"
        echo "      Debian distros: sudo apt install rsync"
        echo "      Arch distros: sudo pacman -S rsync"
        echo "      Fedora distros: sudo dnf install rsync"
        read -p "Press Enter to close this window..."
        exit 1
    fi
    echo "rsync is installed"

	echo "CHECKING TOOLS"
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    STEAM="${PWD%%/steamapps/*}/steamapps"

    DATA_FOLDER=$(find ../ -maxdepth 1 -type d -iname "data")
    if [ ! -d "$DATA_FOLDER" ]; then
        echo "WARNING: Data Folder not preset, Aborting. Please relocate the pack tools folder next to the Data folder of a mod."
        read -p "Press Enter to close this window..."
        exit
    fi

    for element in "${TOOL[@]}"; do
        Cscript_dirHECK_FILE $element
    done
    MOD_NAME="$(basename "$(dirname "$script_dir")")"
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

LOG_FILE="EAWM_log.txt"

if [[ -z "$LOGGING_ACTIVE" ]]; then
    export LOGGING_ACTIVE=1
    exec > >(tee "$LOG_FILE") 2>&1
fi


echo "================================================================================"
echo "EAW Linux ModTool v1.0.0 2025"
echo "By Alexey Skywalker "
echo "================================================================================"
sleep 0.5
INITIAL_CHECK
echo -e "PROCESSING "$MOD_NAME" MOD FOLDER"
CAPITAL
mainmega=$(find ../DATA -type f -iname "megafiles.xml")
mainmega=$(basename "$mainmega")
lowermega=$(LOWERCASE "$mainmega")
mv -v "../DATA/$mainmega" "../DATA/$lowermega"
sleep 0.5
bash PROCESSOR.sh "$MOD_NAME"

echo -e "\n"
echo "================================================================================"
echo "ALL OPERATIONS EXECUTED SUCCESFULLY, REMEMBER TO SET YOUR LAUNCH OPTIONS TO:"
echo "MODPATH=Mods/$MOD_NAME"
echo "If you want a separate launcher for the mod, add this before MODPATH:"
echo "STEAM_COMPAT_DATA_PATH="$STEAM/compatdata/32470" %command%"
echo "================================================================================"
read -p "Press Enter to close this window..."