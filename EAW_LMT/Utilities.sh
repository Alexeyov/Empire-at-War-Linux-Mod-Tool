#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.0 2025"
# "By Alexey Skywalker "
# "================================================================================"

source file_arrays.sh

CAPITAL()
{
    find ../ -depth -type d | while IFS= read -r dir; do
        base=$(basename "$dir")
        parent=$(dirname "$dir")
        newname=$(uppercase_folder "$base")

        # Skip if names are the same
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

FOLDER_CHECK()
{
    FOLDER=$1
    N_FOLDER=$2
    SIZE_LIMIT=$3
    SIZE_BYTES=$(du -sb "$FOLDER" | cut -f1)
    if [ "$SIZE_BYTES" -gt "$SIZE_LIMIT" ]; then
        number=$(((SIZE_BYTES/1000000000)+1))
        #eval "$N_FOLDER=$number"
    else
    	number="1"
        #eval "$N_FOLDER=1"
    fi

    eval "$N_FOLDER=$number"

    echo "Folder: $FOLDER will be packed in $number megs"
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
    
    #SCRIPTS FOLDER THE BUILD TOOL IS TOO UNRELIABLE FOR BOTH SCRIPTS AND XML, SO DONT BOTHER FOR THE MOMENT
    # CHECK_REPEATED_FILE LANDMODE "$ORIGIN/SCRIPTS/AI/LANDMODE" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE SPACEMODE "$ORIGIN/SCRIPTS/AI/SPACEMODE" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE AI "$ORIGIN/SCRIPTS/AI" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE EVALUATORS "$ORIGIN/SCRIPTS/EVALUATORS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE FREESTORE "$ORIGIN/SCRIPTS/FREESTORE" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE GAMEOBJECT "$ORIGIN/SCRIPTS/GAMEOBJECT" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE INTERVENTIONS "$ORIGIN/SCRIPTS/INTERVENTIONS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE LIBRARY "$ORIGIN/SCRIPTS/LIBRARY" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE MISCELLANEOUS "$ORIGIN/SCRIPTS/MISCELLANEOUS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE STORY "$ORIGIN/SCRIPTS/STORY" "$DEST" "$MOD_NAME" 1
    # #XML FOLDER 
    # CHECK_REPEATED_FILE GALACTICMARKUP "$ORIGIN/XML/AI/GALACTICMARKUP" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE GOALFUNCTIONS "$ORIGIN/XML/AI/GOALFUNCTIONS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE GOALS "$ORIGIN/XML/AI/GOALS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE HINTSETS "$ORIGIN/XML/AI/HINTSETS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE PERCEPTUALEQUATIONS "$ORIGIN/XML/AI/PERCEPTUALEQUATIONS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE PLAYERS "$ORIGIN/XML/AI/PLAYERS" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE TEMPLATES "$ORIGIN/XML/AI/TEMPLATES" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE ENUM "$ORIGIN/XML/ENUM" "$DEST" "$MOD_NAME" 1
    # CHECK_REPEATED_FILE XML "$ORIGIN/XML/" "$DEST" "$MOD_NAME" 1


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
            file_dirname=$(dirname $file_path)
            final_dir="${file_dirname#TEMP/}"
            final_dir="${final_dir#../}"
            NEW_DEST="$DEST/$MOD_NAME/$final_dir"
            mkdir -p "$NEW_DEST" 
           # echo "Found: $file_path /// Moving to corruption/Mods/$MOD_NAME/$file_dir"

            if [[ "$MODE" == "1" ]]; then
                cp "$file_path" "$NEW_DEST/"
            else
                mv "$file_path" "$NEW_DEST/"
            fi
         # else
         #    echo "Not found: $filename"
        fi
    done
    echo "$ARRAY: $CURRENT/$TOTAL"
}

COPY_CONTENT()
{
    SOURCE_DIR=$1
    DEST_BASE=$2
    SUBDIR_NAME=$3
    NUM_FOLDERS=$4
    MODE=$5
    BUILD_FILE=$6
    F_DEST=$7
    
    echo "Processing files from ${SOURCE_DIR}"

    
    SOURCE_DIR=$(realpath "$SOURCE_DIR")

    # Choose file search mode
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


    FILES_PER_FOLDER=$(( (TOTAL_FILES + NUM_FOLDERS - 1) / NUM_FOLDERS ))
    echo "Distributing $TOTAL_FILES files into $NUM_FOLDERS folders..."

    index=0
    for (( i=1; i<=NUM_FOLDERS; i++ )); do
        DEST_ROOT="${DEST_BASE}_${i}"
        DEST_DIR="${DEST_BASE}_${i}/${SUBDIR_NAME}"
        mkdir -p "$DEST_DIR"

        cp "$BUILD_FILE" "$DEST_ROOT/build.cfg"

        for (( j=0; j<FILES_PER_FOLDER && index<TOTAL_FILES; j++, index++ )); do
            REL_PATH="${REL_PATHS[$index]}"
            SRC_PATH="$SOURCE_DIR/$REL_PATH"
            DEST_PATH="$DEST_DIR/$REL_PATH"

            mkdir -p "$(dirname "$DEST_PATH")"
            cp "$SRC_PATH" "$DEST_PATH"
        done

    done

    echo "Done. Files copied into ${DEST_BASE}_1 through ${DEST_BASE}_${NUM_FOLDERS}."
    for (( i=1; i<=NUM_FOLDERS; i++ )); do
      DEST_ROOT="${DEST_BASE}_${i}"
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
        #echo "Moved: $filepath → $dest"
    done

    echo -e "\n"
    echo "DONE. ALL .MEG FILES MOVED TO: $TARGET_DIR"
}

EDIT_MEGA()
{
    MAIN_XML=$1
    MODED_XML=$2
    DEST=$3

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
    ' "$new_lines" "$MAIN_XML" > "$temp_file"


    mv "$temp_file" "$DEST/megafiles.xml"
    echo "megafiles.xml created successfully."
}