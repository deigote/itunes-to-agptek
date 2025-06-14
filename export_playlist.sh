#!/bin/bash

playlist_xml="$1"
dest_dir_rel="$2"

if [[ -z "$playlist_xml" || -z "$dest_dir_rel" ]]; then
    echo "Uso: $0 <playlist.xml> <directorio_destino>"
    exit 1
fi
root_dir=MUSIC
dest_dir=$root_dir/"$dest_dir_rel"

mkdir -p "$dest_dir"
m3u_file="$dest_dir_rel.m3u"
> "$m3u_file"  # vacia el fichero si existe

track_ids=($(xmllint --xpath '//dict[key="Tracks"]/dict/key/text()' "$playlist_xml" 2>/dev/null))

i=1
for track_id in "${track_ids[@]}"; do
    track_dict=$(xmllint --xpath "//dict[key='Tracks']/dict/key[text()='$track_id']/following-sibling::dict[1]" "$playlist_xml" 2>/dev/null)
    [[ -z "$track_dict" ]] && continue

    tmpfile=$(mktemp)
    echo "$track_dict" > "$tmpfile"

    name=$(xmllint --xpath 'string(//key[text()="Name"]/following-sibling::string[1])' "$tmpfile" 2>/dev/null)
    artist=$(xmllint --xpath 'string(//key[text()="Artist"]/following-sibling::string[1])' "$tmpfile" 2>/dev/null)
    location=$(xmllint --xpath 'string(//key[text()="Location"]/following-sibling::string[1])' "$tmpfile" 2>/dev/null)
    rm "$tmpfile"

    [[ -z "$location" || -z "$name" || -z "$artist" ]] && continue

    filepath=$(printf '%b' "$(echo "$location" | sed -E 's|^file://||; s|%([0-9A-Fa-f]{2})|\\x\1|g')")

    if [[ ! -f "$filepath" ]]; then
        echo "No encontrado: $filepath"
        continue
    fi

    clean_name=$(echo "$name" | iconv -f UTF-8 -t ASCII//TRANSLIT | tr -cd '[:alnum:] _-')
    clean_artist=$(echo "$artist" | iconv -f UTF-8 -t ASCII//TRANSLIT | tr -cd '[:alnum:] _-')
    new_name=$(printf "%02d-%s_%s.m4a" "$i" "$clean_name" "$clean_artist" | tr ' ' '_')

    echo "Copiando: $filepath → $dest_dir/$new_name"
    cp "$filepath" "$dest_dir/$new_name"

    echo "$root_dir\\$dest_dir_rel\\$new_name" >> "$m3u_file"
    unix2dos "$m3u_file"

    ((i++))
done
