#!/bin/bash

usage() {
    echo "Usage: $0 [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE and print matching lines."
    echo
    echo "Options:"
    echo "  -n,  Show line numbers."
    echo "  -v,  Invert the sense of matching."
    echo "  --help  Display this help message and exit."
    exit 1
}

ShowLineNumbers=false
InvertMatch=false

# Process each character in the option
process_option() {
    local opts="$1"
    for ((i=0; i<${#opts}; i++)); do
        case "${opts:$i:1}" in
            n)
                ShowLineNumbers=true
                ;;
            v)
                InvertMatch=true
                ;;
            *)
                echo "Error: Invalid Option: -${opts:$i:1}"
                usage
                ;;
        esac
    done
}

# Modify option parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        -[nv]*)
            # Handle combined options like -vn, -nv
            process_option "${1#-}"
            shift
            ;;
        -n)
            ShowLineNumbers=true
            shift
            ;;
        -v)
            InvertMatch=true
            shift
            ;;
        --help)
            usage
            ;;
        -*)
            echo "Error: Invalid Option: $1"
            usage
            ;;
        *)
            if [[ -z "$pattern" ]]; then
                pattern="$1"
            else
                file="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$pattern" || -z "$file" ]]; then
    echo "Error: Missing PATTERN or FILE."
    usage
fi

if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file"
    exit 1
fi        

line_number=0
while IFS= read -r line; do
    ((line_number++))
    
    # Use grep with -E for case-insensitive match
    if [[ $InvertMatch == false ]] && echo "$line" | grep -qiE "$pattern"; then
        if [[ $ShowLineNumbers == true ]]; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    elif [[ $InvertMatch == true ]] && ! echo "$line" | grep -qiE "$pattern"; then
        if [[ $ShowLineNumbers == true ]]; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"