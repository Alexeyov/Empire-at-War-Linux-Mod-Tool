#!/bin/bash

# "================================================================================"
# "EAW Linux ModTool v1.0.1 2025"
# "By Alexey Skywalker "
# "================================================================================"

source file_arrays.sh

MODS_DIR()
{
    echo "${PWD%%/steamapps/*}/steamapps/common/Star Wars Empire at War/corruption/Mods"
}

PRINT_LAUNCH_OPTIONS()
{
    local mod_name=$1
    local base_mod=$2
    local base_launch_options

    if [[ -z "$base_mod" ]]; then
        echo "MODPATH=Mods/$mod_name"
    else
        base_launch_options="$(MODS_DIR)/$base_mod/launch_options.txt"
        echo "MODPATH=Mods/$mod_name $(cat "$base_launch_options")"
    fi
}

STAGE_MOD_COPY()
{
    local mod_data_dir=$1
    local staged_mod_dir=$2

    echo "Staging a copy of the mod so the Steam Workshop files stay untouched"
    if ! cp -al "$mod_data_dir" "$staged_mod_dir/" 2> /dev/null; then
        echo "Hard links unavailable, copying the mod instead"
        find "$staged_mod_dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + || return 1
        cp -a "$mod_data_dir" "$staged_mod_dir/" || return 1
    fi
    CAPITAL "$staged_mod_dir"
    NORMALIZE_MEGAFILES_XML_NAME "$staged_mod_dir/DATA"
}

CAPITAL()
{
    local root_dir=$1

    find "$root_dir" -mindepth 1 -depth -type d | while IFS= read -r dir; do
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

NORMALIZE_MEGAFILES_XML_NAME()
{
    local data_dir=$1
    local megafiles_xml

    megafiles_xml=$(find "$data_dir" -maxdepth 1 -type f -iname "megafiles.xml")
    if [[ -n "$megafiles_xml" && "$megafiles_xml" != "$data_dir/megafiles.xml" ]]; then
        mv -v "$megafiles_xml" "$data_dir/megafiles.xml"
    fi
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
    ARRAY="$1[@]"
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
    BUILD_FILE=$4
    F_DEST=$5

    MAX_FILES=1200             
    MAX_SIZE=1500000000  
    
    echo "Processing files from ${SOURCE_DIR}"

    SOURCE_DIR=$(realpath "$SOURCE_DIR")

    mapfile -t REL_PATHS < <(cd "$SOURCE_DIR" && find . -type f | sort -V)
    TOTAL_FILES=${#REL_PATHS[@]}

    if (( TOTAL_FILES == 0 )); then
      echo "No files found in the source directory."
      return 1
    elif (( TOTAL_FILES < 250)); then
      echo "Low number of files in directory, copying folder instead"
      rsync -a --progress "$SOURCE_DIR" "$F_DEST/ART/"
      return 1
    fi

    FOLDER_INDEX=1
    FILE_COUNT=0
    FOLDER_SIZE=0
    TARGET="$DEST_BASE/folder_$FOLDER_INDEX/$SUBDIR_NAME"
    mkdir -p "$TARGET"
    echo "Copying cfg"
    cp "$BUILD_FILE" "$DEST_BASE/folder_$FOLDER_INDEX/build.cfg"

    for rel_path in "${REL_PATHS[@]}"; do
        file="$SOURCE_DIR/$rel_path"
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

        mkdir -p "$TARGET/${rel_path%/*}"
        cp "$file" "$TARGET/$rel_path"
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
    wine cmd /c ".\\yvaw-build.exe cook" "$SOURCE" "$SOURCE" || ABORT_PACKING "yvaw-build.exe failed for $SOURCE."
    REQUIRE_MEG_BUILT_IN "$SOURCE"
}

ABORT_PACKING()
{
    echo "ERROR: $1"
    echo "A 'Could not load Mono' error above means Wine Mono is missing or broken."
    exit 1
}

REQUIRE_MEG_BUILT_IN()
{
    local build_dir=$1

    if ! compgen -G "$build_dir/DATA/*.meg" > /dev/null; then
        ABORT_PACKING "yvaw-build.exe produced no .meg in $build_dir."
    fi
}

MOVE_MEGS() {
    SOURCE_DIR="TEMP/"
    TARGET_DIR=$1
    local meg_prefix=$2

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Source directory not found: $SOURCE_DIR"
        return 1
    fi

    find "$SOURCE_DIR" -type f -name '*.meg' | while read -r filepath; do
        filename="$meg_prefix$(basename "$filepath")"
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

LIST_PACKED_MEGS_AS_XML()
{
    local mod_data_dir=$1
    local meg_prefix=$2

    find "$mod_data_dir" -maxdepth 1 -type f -iname "${meg_prefix}*.meg" -printf '%f\n' \
        | sort -V \
        | awk '{ print "  <File>Data\\" $0 "</File>" }'
}

PRINT_INHERITED_MANIFEST()
{
    local mod_xml=$1
    local template_xml=$2
    local base_mod_xml=$3

    if [[ -f "$mod_xml" && -n "$base_mod_xml" ]]; then
        PRINT_WITH_BASE_MOD_MEGS_BEFORE_OWN_MEGS "$mod_xml" "$base_mod_xml"
    elif [[ -f "$mod_xml" ]]; then
        cat "$mod_xml"
    elif [[ -n "$base_mod_xml" ]]; then
        cat "$base_mod_xml"
    else
        cat "$template_xml"
    fi
}

PRINT_WITH_BASE_MOD_MEGS_BEFORE_OWN_MEGS()
{
    local mod_xml=$1
    local base_mod_xml=$2

    awk -v mod_xml="$mod_xml" -v base_mod_xml="$base_mod_xml" '
        function entry_key(line,    key) {
            key = tolower(line)
            gsub(/[ \t\r]/, "", key)
            return key
        }
        BEGIN {
            while ((getline line < mod_xml) > 0) {
                if (line ~ /<File>/) in_mod[entry_key(line)] = 1
            }
            while ((getline line < base_mod_xml) > 0) {
                if (line !~ /<File>/) continue
                in_base[entry_key(line)] = 1
                if (!(entry_key(line) in in_mod)) missing_from_mod[++missing_count] = line
            }
        }
        !inserted && ((/<File>/ && !(entry_key($0) in in_base)) || /<\/Mega_Files>/) {
            for (i = 1; i <= missing_count; i++) {
                print missing_from_mod[i]
            }
            inserted = 1
        }
        { print }
    ' "$mod_xml"
}

EDIT_MEGA()
{
    local inherited_xml=$1
    local meg_prefix=$2
    local mod_data_dir=$3
    local packed_megs_xml
    local merged_xml

    packed_megs_xml=$(mktemp)
    LIST_PACKED_MEGS_AS_XML "$mod_data_dir" "$meg_prefix" > "$packed_megs_xml"

    merged_xml=$(mktemp)

    awk -v packed_megs="$packed_megs_xml" '
        /<\/Mega_Files>/ {
            while ((getline meg < packed_megs) > 0) {
                print meg
            }
        }
        { print }
    ' "$inherited_xml" > "$merged_xml"

    mv "$merged_xml" "$mod_data_dir/megafiles.xml"
    echo "megafiles.xml created successfully with $(wc -l < "$packed_megs_xml") packed megs."
    rm "$packed_megs_xml"
}