#!/bin/bash

ZAP_CONFIG="$HOME/.cd_keywords.sh"

# Ensure config file exists
if [ ! -f "$ZAP_CONFIG" ]; then
    echo 'declare -A cd_keywords=()' > "$ZAP_CONFIG"
fi

# Load existing cd_keywords array
load_keywords() {
    unset cd_keywords
    declare -gA cd_keywords

    # Parse only the array content manually to avoid side effects
    eval "$(awk '/^declare -A cd_keywords=/{found=1; next} found {if ($0 ~ /^\)/) exit; print}' "$ZAP_CONFIG" | sed 's/^[ \t]*\["\(.*\)"\][ \t]*="[ \t]*\(.*\)"[ \t]*$/cd_keywords["\1"]="\2"/')"
}

# Save cd_keywords array back to the config file
save_keywords() {
    {
        echo 'declare -A cd_keywords=('
        for key in "${!cd_keywords[@]}"; do
            printf '    ["%s"]="%s"\n' "$key" "${cd_keywords[$key]}"
        done | sort
        echo ')'
    } > "$ZAP_CONFIG"
}

# Main zap command
zap() {
    local subcommand="$1"
    shift

    case "$subcommand" in
        add)
            if [ $# -ne 2 ]; then
                echo "Usage: zap add <keyword> <path|.>"
                return 1
            fi
            local key="$1"
            local path="$2"
            [[ "$path" == "." || -z "$path" ]] && path="$(pwd)"
            load_keywords
            cd_keywords["$key"]="$path"
            save_keywords
            echo "Added: $key → $path"
            ;;
        rm)
            if [ $# -ne 1 ]; then
                echo "Usage: zap rm <keyword>"
                return 1
            fi
            local key="$1"
            load_keywords
            if [[ -n "${cd_keywords[$key]}" ]]; then
                unset cd_keywords["$key"]
                save_keywords
                echo "Removed: $key"
            else
                echo "Keyword '$key' not found."
            fi
            ;;
        ls)
            load_keywords
            for key in "${!cd_keywords[@]}"; do
                printf "%-20s → %s\n" "$key" "${cd_keywords[$key]}"
            done | sort
            ;;
        *)
            echo "Usage:"
            echo "  zap add <keyword> <path|.>"
            echo "  zap rm <keyword>"
            echo "  zap ls"
            ;;
    esac
}

# Override cd to support keyword navigation
cd() {
    if [[ -f "$ZAP_CONFIG" ]]; then
        source "$ZAP_CONFIG"
    fi

    local base_dir

    if [[ -n "${cd_keywords[$1]}" ]]; then
        base_dir="${cd_keywords[$1]}"
        shift
        for segment in "$@"; do
            base_dir="$base_dir/$segment"
        done
    else
        base_dir="$1"
        shift
    fi

    command cd "$base_dir"
}

# Tab completion for cd
_cd() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local keys=()

    # Extract keys from the config file manually
    while IFS= read -r line; do
        if [[ $line =~ \[\"([^\"]+)\"\] ]]; then
            keys+=("${BASH_REMATCH[1]}")
        fi
    done < <(awk '/^declare -A cd_keywords=/{found=1; next} found && /^\)/{exit} found' "$HOME/.cd_keywords.sh")

    COMPREPLY=($(compgen -W "${keys[*]}" -- "$cur"))
}

complete -o bashdefault -o default -o nospace -F _cd cd

