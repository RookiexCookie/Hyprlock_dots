#!/bin/bash
city=Jamshedpur
cache_file="$HOME/.cache/wttr_cache.txt"

if [ ! -f "$cache_file" ]; then
        mkdir -p "$(dirname "$cache_file")" 
        touch "$cache_file"
fi

last_modified=$(stat -c %Y "$cache_file")
current_date=$(date +%s)
time_diff=$((current_date - last_modified))
expiry_time=86400
cached_data=$(<"$cache_file")

if [ $time_diff -lt $expiry_time ] && [ -n "$cached_data" ]; then
        echo "$cached_data"
        exit
fi

response=$(curl -s wttr.in/"$city"?format=%c+%t 2>/dev/null | sed 's/+/ /')
echo $response | tee "$cache_file"
