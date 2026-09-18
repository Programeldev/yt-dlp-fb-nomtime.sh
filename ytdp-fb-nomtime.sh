#!/bin/bash

error() {
	echo "$*" >&2
}

command="yt-dlp -f best --no-mtime"
output_name=""
url=""

while [[ -n "$1" ]]; do
	# Setting output file name for downloaded content
	if [[ ${1:0:2} == "-o" ]]; then
		if [[ -n "$output_name" ]]; then
			error "Error: The -o option has already been used once. Aborting..."
			exit 1
		elif [[ -z "${1:2}" ]]; then
			output_name="--output \"${2}\""
			shift 2
		else
			output_name="--output \"${1:2}\""
			shift
		fi
	# Get URL from clipboard (wayland only)
	elif [[ ${1:0:2} == "-c" ]]; then
		if ! command -v wl-paste >/dev/null; then
			error "Error: No 'wl-paste' command found. Can't take URL from clipboard. Aborting..."
			exit 1
		fi

		if [[ -n "$url" ]]; then
			error "Info: The -c option has already been used once. Ommiting..."
		elif [[ -z "$(wl-paste)" ]]; then
			error "Error: clipboard is empty. Aborting..."
			exit 1
		else
			url=" \"$(wl-paste)\" "
			echo "Clipboard: ${url}"
		fi
		shift
	elif [[ $# > 1 ]]; then
		error "Error: Too many arguments. Aborting..."
		exit 1
	else
	# If only one passed argument left, take them as a URL
	
		# Check if a URL is saved from clipboard
		if [[ -z "$url" ]]; then
			url="$1"
		else
			error "Error: URL was taken from clipboard. Aborting..."
			exit 1
		fi
		break
	fi
done

eval "yt-dlp -f\"b\" --no-mtime ${output_name} \"${url}\""
