autoload -Uz colors && colors

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' (%b)'

precmd() {
    vcs_info
}

setopt PROMPT_SUBST

PROMPT=$'%F{blue}%~%f%F{green}${vcs_info_msg_0_}%f\n%F{magenta}>^.^<%f '

sshmgr() {
    local CONFIG_FILE="$HOME/.ssh/config"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        touch "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"
    fi

    local command="${1:-}"
    if [[ -n "$command" ]]; then
        shift
    fi

    _sshmgr_host_exists() {
        local target="$1"
        awk -v h="$target" '
            tolower($1) == "host" {
                for (i = 2; i <= NF; i++) {
                    if ($i == h) {
                        found = 1
                        exit
                    }
                }
            }
            END { exit(found ? 0 : 1) }
        ' "$CONFIG_FILE"
    }

    _sshmgr_block_for_host() {
        local target="$1"
        awk -v h="$target" '
            BEGIN { in_block = 0; matched = 0 }
            tolower($1) == "host" {
                in_block = 0
                for (i = 2; i <= NF; i++) {
                    if ($i == h) in_block = 1
                }
                if (in_block) matched = 1
            }
            in_block { print }
            END { exit(matched ? 0 : 1) }
        ' "$CONFIG_FILE"
    }

    case "$command" in
        list)
            echo "Available SSH Hosts:"
            awk 'tolower($1) == "host" {
                for (i = 2; i <= NF; i++) {
                    if ($i != "*") print "  - " $i
                }
            }' "$CONFIG_FILE"
            ;;

        show)
            local target="${1:-}"
            if [[ -z "$target" ]]; then
                echo "Error: Hostname required." >&2
                return 1
            fi

            if ! _sshmgr_block_for_host "$target"; then
                echo "Error: Host '$target' not found." >&2
                return 1
            fi
            ;;

        delete)
            local target="${1:-}"
            if [[ -z "$target" ]]; then
                echo "Error: Hostname required to delete." >&2
                return 1
            fi

            if ! _sshmgr_host_exists "$target"; then
                echo "Error: Host '$target' not found." >&2
                return 1
            fi

            local tmp_file
            tmp_file="$(mktemp)" || return 1

            awk -v h="$target" '
                BEGIN { in_block = 0; skip = 0 }
                tolower($1) == "host" {
                    in_block = 0
                    skip = 0
                    for (i = 2; i <= NF; i++) {
                        if ($i == h) {
                            skip = 1
                            in_block = 1
                        }
                    }
                    if (!skip) print
                    next
                }
                {
                    if (!skip) print
                }
            ' "$CONFIG_FILE" > "$tmp_file" && cat "$tmp_file" > "$CONFIG_FILE"

            rm -f "$tmp_file"
            chmod 600 "$CONFIG_FILE"
            echo "Successfully deleted host: $target"
            ;;

        add)
            local host="${1:-}" hostname="${2:-}" user="${3:-}" port="${4:-22}" identity="${5:-}"

            if [[ -z "$host" || -z "$hostname" || -z "$user" ]]; then
                echo "Error: Missing arguments." >&2
                echo "Usage: sshmgr add <host> <hostname/IP> <user> [port] [identity_file]" >&2
                return 1
            fi

            if _sshmgr_host_exists "$host"; then
                echo "Error: Host '$host' already exists. Use 'update' to modify." >&2
                return 1
            fi

            {
                printf '\n'
                printf 'Host %s\n' "$host"
                printf '    HostName %s\n' "$hostname"
                printf '    User %s\n' "$user"
                printf '    Port %s\n' "$port"
                if [[ -n "$identity" ]]; then
                    printf '    IdentityFile %s\n' "$identity"
                fi
            } >> "$CONFIG_FILE"

            chmod 600 "$CONFIG_FILE"
            echo "Successfully added host: $host"
            ;;

        update)
            local host="${1:-}"
            if [[ -z "$host" ]]; then
                echo "Error: Missing host name." >&2
                return 1
            fi

            if ! _sshmgr_host_exists "$host"; then
                echo "Error: Host '$host' does not exist." >&2
                return 1
            fi

            local hostname="${2:-}"
            local user="${3:-}"
            local port="${4:-22}"
            local identity="${5:-}"

            if [[ -z "$hostname" || -z "$user" ]]; then
                echo "Usage: sshmgr update <host> <hostname/IP> <user> [port] [identity_file]" >&2
                return 1
            fi

            sshmgr delete "$host" >/dev/null
            sshmgr add "$host" "$hostname" "$user" "$port" "$identity"
            echo "Successfully updated host: $host"
            ;;

        connect)
            local target="${1:-}"
            if [[ -z "$target" ]]; then
                echo "Error: Hostname required." >&2
                return 1
            fi

            echo "Connecting to $target..."
            ssh "$target"
            ;;

        -h|--help|help)
            cat <<'EOF'
SSH Manager (CRUD for ~/.ssh/config)

Usage:
  sshmgr                    # Interactive menu to connect
  sshmgr list               # List all available hosts
  sshmgr show <host>        # Show config details for a specific host
  sshmgr add <host> <IP> <user> [port] [identity_file]
  sshmgr update <host> <IP> <user> [port] [identity_file]
  sshmgr delete <host>      # Remove a host from config
  sshmgr connect <host>     # Connect to a host
EOF
            ;;

        "")
            echo "=== SSH Manager ==="

            local hosts
            hosts=($(awk 'tolower($1) == "host" {
                for (i = 2; i <= NF; i++) {
                    if ($i != "*") print $i
                }
            }' "$CONFIG_FILE"))

            if [[ ${#hosts[@]} -eq 0 ]]; then
                echo "No hosts found in $CONFIG_FILE."
                echo "Use 'sshmgr add ...' to create one."
                return 0
            fi

            local i=1
            for h in "${hosts[@]}"; do
                echo "${i}) ${h}"
                ((i++))
            done

            echo "-------------------"

            local choice
            read -r "?Select a number to connect (or 'q' to quit): " choice

            if [[ "$choice" == "q" || -z "$choice" ]]; then
                return 0
            fi

            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice > 0 && choice <= ${#hosts[@]} )); then
                local selected_host="${hosts[$choice]}"
                echo "Connecting to $selected_host..."
                ssh "$selected_host"
            else
                echo "Invalid selection." >&2
                return 1
            fi
            ;;

        *)
            echo "Unknown command: $command" >&2
            sshmgr help
            return 1
            ;;
    esac
}
