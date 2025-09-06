#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.1 2025"
# "By Alexey Skywalker "
# "================================================================================"

source file_arrays.sh

CAPITAL()
{
    find ../ -depth -type d | while IFS= read -r dir; do
        base=$(basename "$dir")
        parent=$(dirname "$dir")
        newname=$(uppercase_folder "$base")

        if [[ "$base" != "$newname" ]]; then
            mv -v "$dir" "$parent/$newname"
        fi
    done
}

uppercase_folder() {
    local name="$1"
    echo "${name^^}"
}

LOWERCASE()
{
    local name="$1"
    echo "${name,,}"
}

VANILLA_CHECK()
{
	ORIGIN=$1
	DEST=$2
	MOD_NAME=$3

    echo "Copying TEXTURES, it will take a bit"
    mkdir -p "TEMP/DATA/ART/"
    rsync -a --progress --exclude='ICONS' "$ORIGIN/ART/TEXTURES" "TEMP/DATA/ART/"
    echo "TEXTURES copied"
    echo "Checking for Vanilla files in TEXTURES, it will take a bit"
    #TEXTURE FOLDER  
    CHECK_REPEATED_FILE TEXTURES "TEMP/DATA/ART/TEXTURES" "$DEST" "$MOD_NAME" 0 

    echo "All Vanilla files moved to $F_DEST"
}

CHECK_REPEATED_FILE()
{
    ARRAY=$1[@]
    LIST=("${!ARRAY}")
    SEARCH_DIR=$2
    DEST=$3
    MOD_NAME=$4
    MODE=$5
    CURRENT=0
    TOTAL=0
    echo "Copying $ARRAY Folder"
    for filename in "${LIST[@]}" 
    do
        file_path=$(find "$SEARCH_DIR" -type f -iname "$filename" | sort | head -n 1)
        TOTAL=$((TOTAL + 1))
        if [[ -n "$file_path" ]]; then        
            CURRENT=$((CURRENT + 1))
            file_dirname=$(dirname "$file_path")
            final_dir="${file_dirname#TEMP/}"
            final_dir="${final_dir#../}"
            NEW_DEST="$DEST/$MOD_NAME/$final_dir"
            mkdir -p "$NEW_DEST" 
            if [[ "$MODE" == "1" ]]; then
                cp "$file_path" "$NEW_DEST/"
            else
                mv "$file_path" "$NEW_DEST/"
            fi
        fi
    done
    echo "$ARRAY: $CURRENT/$TOTAL"
}

COPY_CONTENT()
{
    SOURCE_DIR=$1
    DEST_BASE=$2
    SUBDIR_NAME=$3
    MODE=$4
    BUILD_FILE=$5
    F_DEST=$6

    MAX_FILES=1200             
    MAX_SIZE=1500000000  
    
    echo "Processing files from ${SOURCE_DIR}"

    SOURCE_DIR=$(realpath "$SOURCE_DIR")

    # CHECKING IF IT IS WORTH TO PACK IN THE FIRST PLACE
    if [[ "$MODE" == "1" ]]; then
        echo "Using recursive mode: including subdirectories"
        mapfile -t REL_PATHS < <(cd "$SOURCE_DIR" && find . -type f | sort -V)
        TOTAL_FILES=${#REL_PATHS[@]}
    else
        mapfile -t REL_PATHS < <(cd "$SOURCE_DIR" && find . -maxdepth 1 -type f | sort -V)
        TOTAL_FILES=${#REL_PATHS[@]}
    fi

    if (( TOTAL_FILES == 0 )); then
      echo "No files found in the source directory."
      return 1
    elif (( TOTAL_FILES < 250)); then
      echo "Low number of files in directory, copying folder instead"
      rsync -a --progress "$SOURCE_DIR" "$F_DEST"
      return 1
    fi

    FOLDER_INDEX=1
    FILE_COUNT=0
    FOLDER_SIZE=0
    TARGET="$DEST_BASE/folder_$FOLDER_INDEX/$SUBDIR_NAME"
    mkdir -p "$TARGET"
    echo "Copying cfg"
    cp "$BUILD_FILE" "$DEST_BASE/folder_$FOLDER_INDEX/build.cfg"

    for file in "$SOURCE_DIR"/*; do
        # get size of file in bytes
        size=$(stat -c%s "$file")

        # check if adding this file would exceed limits
        if [ $((FILE_COUNT + 1)) -gt $MAX_FILES ] || [ $((FOLDER_SIZE + size)) -gt $MAX_SIZE ]; then
            echo "Finalized $TARGET with $FILE_COUNT files, $(numfmt --to=iec $FOLDER_SIZE)"
            # start new folder
            FOLDER_INDEX=$((FOLDER_INDEX+1))
            FILE_COUNT=0
            FOLDER_SIZE=0
            TARGET_ROOT="folder_${FOLDER_INDEX}"
            TARGET="$DEST_BASE/$TARGET_ROOT/$SUBDIR_NAME"
            mkdir -p "$TARGET"
            cp "$BUILD_FILE" "$DEST_BASE/folder_$FOLDER_INDEX/build.cfg"
        fi

        cp "$file" "$TARGET/"
        FILE_COUNT=$((FILE_COUNT+1))
        FOLDER_SIZE=$((FOLDER_SIZE+size))
    done

    echo "Done. Files copied into ${DEST_BASE}/folder_1 through ${DEST_BASE}/folder_${FOLDER_INDEX}."
    for (( i=1; i<=FOLDER_INDEX; i++ )); do
      DEST_ROOT="$DEST_BASE/folder_${i}"
      Pack_func "$DEST_ROOT"
    done
}

Pack_func()
{
    SOURCE=$1
    echo "Running Yvaw-build.exe for ${SOURCE}"
    wine cmd /c ".\\yvaw-build.exe cook" "$SOURCE" "$SOURCE"
}

MOVE_MEGS() {
    SOURCE_DIR="TEMP/"
    TARGET_DIR=$1

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Source directory not found: $SOURCE_DIR"
        return 1
    fi

    find "$SOURCE_DIR" -type f -name '*.meg' | while read -r filepath; do
        filename=$(basename "$filepath")
        base="${filename%.*}"
        ext="${filename##*.}"
        dest="$TARGET_DIR/$filename"
        count=1

        while [[ -e "$dest" ]]; do
            dest="$TARGET_DIR/${base}_$count.$ext"
            ((count++))
        done

        mv "$filepath" "$dest"
    done

    echo -e "\n"
    echo "DONE. ALL .MEG FILES MOVED TO: $TARGET_DIR"
}

EDIT_MEGA()
{
    MAIN_XML=$1
    MODED_XML=$2
    BASE_XML=$3
    DEST=$4

    FIRST_PART=""

    if [ -f "$MAIN_XML" ]; then
        FIRST_PART="$MAIN_XML"
    else
        FIRST_PART="$BASE_XML"
    fi

    new_lines=$(mktemp)
    awk '/<Mega_Files>/,/<\/Mega_Files>/' "$MODED_XML" | grep "<File>" > "$new_lines"

    # Temporary output
    temp_file=$(mktemp)

    awk '
        FNR==NR { new_lines[NR] = $0; next }
        /<\/Mega_Files>/ {
            for (i = 1; i <= length(new_lines); i++) {
                print "\t" new_lines[i]
            }
        }
        { print }
    ' "$new_lines" "$FIRST_PART" > "$temp_file"

    mv "$temp_file" "$DEST/megafiles.xml"

    echo "megafiles.xml created successfully."
}