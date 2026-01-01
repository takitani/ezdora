#!/usr/bin/env bash
set -euo pipefail

# pw-keepalive - Password Manager Session Keepalive Daemon
# Keeps 1Password CLI sessions alive by pinging periodically

export PATH="$HOME/.local/bin:$PATH"

INSTALL_PATH="$HOME/.local/bin/pw-keepalive"

if [[ -f "$INSTALL_PATH" ]]; then
  echo "[ezdora][pw-keepalive] Already installed. Skipping."
  exit 0
fi

echo "[ezdora][pw-keepalive] Installing password manager keepalive daemon..."

# Ensure target directory exists
mkdir -p "$HOME/.local/bin"

# Create the keepalive script
cat > "$INSTALL_PATH" << 'KEEPALIVE_SCRIPT'
#!/usr/bin/env bash
# Password Manager Keepalive Daemon
# Keeps 1Password session alive by pinging every 20 minutes
# Bitwarden doesn't need keepalive (session doesn't auto-expire)

PIDFILE="$HOME/.pw-keepalive.pid"
LOGFILE="$HOME/.pw-keepalive.log"
INTERVAL=1200  # 20 minutes in seconds

log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOGFILE"
}

get_op_account() {
    # Try to get account from config file first
    if [[ -f "$HOME/.ezdora-config" ]]; then
        local account=$(grep -oP '^OP_ACCOUNT="\K[^"]+' "$HOME/.ezdora-config" 2>/dev/null)
        [[ -n "$account" ]] && echo "$account" && return
    fi
    # Fallback: get first configured account from op CLI
    op account list --format=json 2>/dev/null | jq -r '.[0].shorthand // empty' 2>/dev/null
}

keepalive_loop() {
    log "Keepalive daemon started (PID $$)"
    local account=$(get_op_account)

    if [[ -z "$account" ]]; then
        log "ERROR: No 1Password account found. Configure OP_ACCOUNT in ~/.ezdora-config"
        exit 1
    fi

    log "Using 1Password account: $account"

    while true; do
        # 1Password keepalive
        if [[ -f "$HOME/.op_session" ]]; then
            session=$(cat "$HOME/.op_session")
            # Use dynamically detected account
            if eval "OP_SESSION_${account}=\"\$session\" op whoami --account \"\$account\"" &>/dev/null; then
                log "1Password: session extended"
            else
                log "1Password: session expired (run 'ops' to renew)"
            fi
        fi

        sleep $INTERVAL
    done
}

case "${1:-}" in
    start)
        if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "Keepalive already running (PID $(cat "$PIDFILE"))"
            exit 0
        fi

        # Start daemon in background
        nohup "$0" daemon >> "$LOGFILE" 2>&1 &
        echo $! > "$PIDFILE"
        echo "Keepalive started (PID $!)"
        echo "  Log: $LOGFILE"
        ;;

    stop)
        if [[ -f "$PIDFILE" ]]; then
            pid=$(cat "$PIDFILE")
            if kill "$pid" 2>/dev/null; then
                rm -f "$PIDFILE"
                echo "Keepalive stopped"
            else
                rm -f "$PIDFILE"
                echo "Keepalive was not running"
            fi
        else
            echo "Keepalive is not running"
        fi
        ;;

    status)
        if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "Keepalive running (PID $(cat "$PIDFILE"))"
            echo "  Last 3 logs:"
            tail -3 "$LOGFILE" 2>/dev/null | sed 's/^/  /'
        else
            echo "Keepalive not running"
        fi
        ;;

    daemon)
        # Internal: run the keepalive loop
        keepalive_loop
        ;;

    *)
        echo "Usage: pw-keepalive {start|stop|status}"
        exit 1
        ;;
esac
KEEPALIVE_SCRIPT

chmod +x "$INSTALL_PATH"

# Verify installation
if [[ -x "$INSTALL_PATH" ]]; then
  echo "[ezdora][pw-keepalive] Installed successfully"
else
  echo "[ezdora][pw-keepalive] ERROR: Installation failed"
  exit 1
fi

echo "[ezdora][pw-keepalive] Done."
echo "[ezdora][pw-keepalive] Usage:"
echo "  pw-keepalive start   # Start the daemon"
echo "  pw-keepalive stop    # Stop the daemon"
echo "  pw-keepalive status  # Check status"
