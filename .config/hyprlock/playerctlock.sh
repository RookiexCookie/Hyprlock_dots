#!/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 --title | --arturl | --artist | --position | --length | --album | --source"
    exit 1
fi
getCover() {
       local tempfile="/tmp/tmp.xG2g4TRv4i"
       local path="/tmp/cover.png"

       if [[ "$url" != $(< "$tempfile") ]]; then
                curl "$url" -o "$path" 
                mogrify -format png "$path"  -resize "100x100^" -gravity center -extent 100x100 "$path"
                echo "$url" > "$tempfile"
       fi
       url="$path"
}

get_metadata() {
    key=$1
    playerctl metadata --format "{{ $key }}" 2>/dev/null
}
get_source_info() {
    trackid=$(get_metadata "mpris:trackid")
    if [[ "$trackid" == *"firefox"* ]]; then
        echo -e "󰈹"
    elif [[ "$trackid" == *"spotify"* ]]; then
        echo -e ""
    elif [[ "$trackid" == *"chromium"* ]]; then
        echo -e ""
    elif [[ "$trackid" == *"Youtube"* ]]; then
        echo -e ""
    elif [[ "$trackid" == *"vlc"* ]]; then
         echo -e "󰕭"
    else
        echo "🫨"  
    fi
}

get_position() {
    playerctl position 2>/dev/null
}

case "$1" in
    --title)
        player=$(playerctl metadata mpris:trackid)
        if [[ "$player" == *"firefox"* ]] || [[ "$player" == *"youtube"* ]]; then

            title=$(playerctl metadata xesam:title)

            if [ -z "$title" ]; then
                echo "Nothing's Playin"
            else
                clean_title=$(echo "$title" | sed -E 's/\([^)]*\)//g; s/\[[^]]*\]//g')
                clean_title=$(echo "$clean_title" | sed -E 's/\b(version|male|female|song|theme)\b//gi')
                clean_title=$(echo "$clean_title" | sed -E 's/\s*by\s*.*$//i')
                if [[ "$clean_title" == *-* ]]; then
                    song_title=$(echo "$clean_title" | sed -E 's/.*-\s*//')
                else
                    song_title="$clean_title"
                fi
                echo "${song_title:0:30}"
            fi
        else
            # Get the title metadata
            title=$(playerctl metadata xesam:title)

            if [ -z "$title" ]; then
                echo "Nothing's Playin"
            else
                clean_title=$(echo "$title" | sed -E 's/\([^)]*\)//g; s/\[[^]]*\]//g')
                clean_title=$(echo "$clean_title" | sed -E 's/\b(version|male|female|song|theme)\b//gi')
                clean_title=$(echo "$clean_title" | sed -E 's/\s*by\s*.*$//i')
                clean_title=$(echo "$clean_title" | sed -E 's/\s*[-–—]\s*(From|Live|Remastered)?\s*.*$//i')
                echo "${clean_title:0:29}"
            fi
        fi
        ;;
--arturl)
	url=$(get_metadata "mpris:artUrl")

	[[ -z "$url" ]] && exit 1
	if [[ "$url" == file://* ]]; then
		url=${url#file://}
	elif [[ "$url" == http://* ]] || [[ "$url" == https://* ]]; then
		getCover
	fi
    magick $url  -resize "100x100^" -gravity center -extent 100x100 $url
	echo "$url"
	;;
--artist)
    artist=$(get_metadata "xesam:artist")
    if [ -z "$artist" ]; then
        echo "Bro"
    else
        echo "${artist:0:30}" # Limit the output to 50 characters
    fi
    ;;
--position)
    position=$(get_position)
    length=$(get_metadata "mpris:length")
    if [ -z "$position" ] || [ -z "$length" ]; then
        echo "0:00/Infinity"
    else
        position_formatted=$(convert_position "$position")
        length_formatted=$(convert_length "$length")
        echo "$position_formatted/$length_formatted"
    fi
    ;;
--length)
    length=$(get_metadata "mpris:length")
    if [ -z "$length" ]; then
        echo "∞"
    else
        echo $(playerctl metadata --format "{{ duration(mpris:length) }}")
    fi
    ;;
--status)
    status=$(playerctl status 2>/dev/null)
    if [[ $status == "Playing" ]]; then
        echo ""
    elif [[ $status == "Paused" ]]; then
        echo ""
    else
        echo ""
    fi
    ;;
--album)
    album=$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null)
    if [[ -n $album ]]; then
        echo "$album"
    else
        status=$(playerctl status 2>/dev/null)
        if [[ -n $status ]]; then
            echo "Not album"
        else
            echo ""
        fi
    fi
    ;;
--source)
    get_source_info
    ;;
*)
    echo "Invalid option: $1"
    echo "Usage: $0 --title | --arturl | --artist | --position | --length | --album | --source" ; exit 1
    ;;
esac

