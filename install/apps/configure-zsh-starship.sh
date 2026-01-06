#!/usr/bin/env bash
set -euo pipefail

# Configure locale for KDE (interface EN, formatting BR)
configure_kde_locale() {
  echo "[ezdora][locale] Configurando locale (interface EN, formatação BR)..."
  
  # Check if locale-gen exists (for systems that use it)
  if command -v locale-gen >/dev/null 2>&1; then
    # Create optimized locale.gen with only necessary locales
    if [ -f /etc/locale.gen ]; then
      sudo tee /etc/locale.gen > /dev/null << 'EOF'
# Locale configuration optimized by ezdora
# Only generate necessary locales to speed up locale-gen

# English (US)
en_US.UTF-8 UTF-8

# Portuguese (Brazil) 
pt_BR.UTF-8 UTF-8
EOF
      echo "[ezdora][locale] Gerando locales específicos (EN_US e PT_BR)..."
      sudo locale-gen en_US.UTF-8 pt_BR.UTF-8
    fi
  fi
  
  # Configure system locale: English interface, Brazilian formatting
  # IMPORTANT: LC_CTYPE=pt_BR.UTF-8 is CRITICAL for cedilla to work!
  current_lang=$(localectl status 2>/dev/null | grep "System Locale" | grep -o "LANG=[^,]*" | cut -d= -f2 || echo "")
  current_ctype=$(localectl status 2>/dev/null | grep "System Locale" | grep -o "LC_CTYPE=[^,]*" | cut -d= -f2 || echo "")
  
  if [[ "$current_lang" != "en_US.UTF-8" ]] || [[ "$current_ctype" != "pt_BR.UTF-8" ]]; then
    echo "[ezdora][locale] Configurando locale do sistema..."
    sudo localectl set-locale LANG=en_US.UTF-8 LC_CTYPE=pt_BR.UTF-8 LC_TIME=pt_BR.UTF-8 LC_MONETARY=pt_BR.UTF-8 LC_PAPER=pt_BR.UTF-8 LC_MEASUREMENT=pt_BR.UTF-8
    echo "[ezdora][locale] Locale configurado: LANG=en_US.UTF-8, LC_CTYPE=pt_BR.UTF-8"
  else
    echo "[ezdora][locale] Locale já está configurado corretamente"
  fi
  
  # Configure timezone for Brazil
  current_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "")
  if [[ "$current_tz" != "America/Sao_Paulo" ]]; then
    echo "[ezdora][locale] Configurando timezone para America/Sao_Paulo..."
    sudo timedatectl set-timezone America/Sao_Paulo
  else
    echo "[ezdora][locale] Timezone já está configurado para America/Sao_Paulo"
  fi
  
  # Configure KDE regional settings if in KDE session
  if [[ "${XDG_CURRENT_DESKTOP:-}" == "KDE" ]] || [[ "${DESKTOP_SESSION:-}" == *"plasma"* ]]; then
    echo "[ezdora][locale] Configurando configurações regionais do KDE..."
    
    # KDE uses ~/.config/plasma-localerc for regional settings
    mkdir -p "$HOME/.config"
    cat > "$HOME/.config/plasma-localerc" << 'EOF'
[Formats]
LANG=en_US.UTF-8
LC_ADDRESS=pt_BR.UTF-8
LC_COLLATE=en_US.UTF-8
LC_CTYPE=pt_BR.UTF-8
LC_MEASUREMENT=pt_BR.UTF-8
LC_MONETARY=pt_BR.UTF-8
LC_NAME=pt_BR.UTF-8
LC_NUMERIC=pt_BR.UTF-8
LC_PAPER=pt_BR.UTF-8
LC_TELEPHONE=pt_BR.UTF-8
LC_TIME=pt_BR.UTF-8
useDetailed=true
EOF
    echo "[ezdora][locale] Configurações regionais do KDE atualizadas"
  fi
  
  # Export for current session
  export LANG=en_US.UTF-8
  export LC_CTYPE=pt_BR.UTF-8
  export LC_TIME=pt_BR.UTF-8
  export LC_MONETARY=pt_BR.UTF-8
  export LC_PAPER=pt_BR.UTF-8
  export LC_MEASUREMENT=pt_BR.UTF-8
}

# Run locale configuration
configure_kde_locale

# Ensure zsh installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "[ezdora][zsh] zsh não instalado; instalando..."
  sudo dnf install -y zsh
fi

# Set zsh as default shell for current user
ZSH_PATH="$(command -v zsh)"
LOGIN_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$LOGIN_SHELL" != "$ZSH_PATH" ]; then
  echo "[ezdora][zsh] Definindo zsh como shell padrão..."
  # Usa sudo para evitar pedir senha adicional (já temos cache do sudo)
  sudo usermod -s "$ZSH_PATH" "$USER" || echo "[ezdora][zsh] Não foi possível alterar shell automaticamente. Faça manualmente: chsh -s $(command -v zsh)"
fi

mkdir -p "$HOME/.config"
ZSHRC="$HOME/.zshrc"

# Ensure basic PATH and mise/Starship init
touch "$ZSHRC"
if ! grep -q "starship init zsh" "$ZSHRC" 2>/dev/null; then
  {
    echo ''
    echo '# EzDora: Starship prompt'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo 'eval "$(starship init zsh)"'
  } >> "$ZSHRC"
fi

# zoxide integration if installed
if command -v zoxide >/dev/null 2>&1; then
  if ! grep -q "zoxide init zsh" "$ZSHRC" 2>/dev/null; then
    {
      echo ''
      echo '# EzDora: zoxide (jump) integration'
      echo 'eval "$(zoxide init zsh --cmd z)"'
    } >> "$ZSHRC"
  fi
  if ! grep -q "^alias cd=z$" "$ZSHRC" 2>/dev/null; then
    echo 'alias cd=z' >> "$ZSHRC"
  fi
fi

# lazydocker alias
if command -v lazydocker >/dev/null 2>&1; then
  if ! grep -q "^alias ld=lazydocker$" "$ZSHRC" 2>/dev/null; then
    echo "alias ld=lazydocker" >> "$ZSHRC"
  fi
fi

# Ensure mise activation for zsh (only if mise is available)
if ! grep -q "mise activate zsh" "$ZSHRC" 2>/dev/null; then
  {
    echo ''
    echo '# EzDora: mise activation'
    echo 'if command -v mise >/dev/null 2>&1; then'
    echo '    eval "$(mise activate zsh)"'
    echo 'fi'
  } >> "$ZSHRC"
fi

# Preserve history behavior (append/share; never truncate)
if ! grep -q "EzDora: Zsh history" "$ZSHRC" 2>/dev/null; then
  {
    echo ''
    echo '# EzDora: Zsh history (preservar)'
    echo 'export HISTFILE="$HOME/.zsh_history"'
    echo 'export HISTSIZE=50000'
    echo 'export SAVEHIST=50000'
    echo 'setopt APPEND_HISTORY'
    echo 'setopt INC_APPEND_HISTORY'
    echo 'setopt SHARE_HISTORY'
    echo 'setopt HIST_IGNORE_ALL_DUPS'
  } >> "$ZSHRC"
fi

# Fix common keybindings (Backspace/Delete) em terminais diversos (ex.: Delete imprimindo ~)
if ! grep -q "EzDora: Zsh keybindings" "$ZSHRC" 2>/dev/null; then
  {
    echo ''
    echo '# EzDora: Zsh keybindings (consertar Backspace/Delete)'
    echo "bindkey '^?' backward-delete-char"        # Backspace
    echo "bindkey '^H' backward-delete-char"        # Backspace alt
    echo "bindkey '\\e[3~' delete-char"            # Delete
  } >> "$ZSHRC"
fi

# Starship config (rich prompt). If the file não existe ou contém a marca EzDora, escrevemos o padrão.
mkdir -p "$HOME/.config"
STARCONF="$HOME/.config/starship.toml"
if [ ! -f "$STARCONF" ] || grep -q "^# EzDora" "$STARCONF" 2>/dev/null; then
  cat > "$STARCONF" <<'EOF'
# EzDora Starship config (rich prompt)
add_newline = true
command_timeout = 1000

format = """
$time$directory$git_branch$git_status$nodejs$python$rust$golang$docker_context$package$cmd_duration
$character
"""

[time]
disabled = false
format = "[ $time]($style) "
time_format = "%H:%M"

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold cyan"

[git_branch]
symbol = " "
style = "bold purple"
format = "[$symbol$branch]($style) "

[git_status]
style = "bold purple"
format = "([$all_status$ahead_behind]($style)) "
conflicted = "≠"
ahead = "⇡${count}"
behind = "⇣${count}"
stashed = "≡"
modified = "✎${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"
untracked = "?${count}"

[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"

[python]
symbol = " "
format = "[$symbol($version )]($style)"

[rust]
symbol = " "
format = "[$symbol($version )]($style)"

[golang]
symbol = " "
format = "[$symbol($version )]($style)"

[docker_context]
symbol = " "
format = "[$symbol$context]($style) "

[dotnet]
symbol = " "
format = "[$symbol($version )]($style) "

[package]
disabled = true

[cmd_duration]
min_time = 2000
format = "[⏱ $duration]($style) "

[character]
success_symbol = "[➜](bold green) "
error_symbol = "[➜](bold red) "
EOF
fi

echo "[ezdora][zsh] zsh configurado com Starship. Reinicie a sessão para aplicar."

# Fallback imediato: se o shell de login ainda não é zsh, ative starship no bash também
if [ "$LOGIN_SHELL" != "$ZSH_PATH" ]; then
  BASHRC="$HOME/.bashrc"
  touch "$BASHRC"
  if ! grep -q "starship init bash" "$BASHRC" 2>/dev/null; then
    {
      echo ''
      echo '# EzDora: Starship prompt (bash fallback até mudar para zsh)'
      echo 'export PATH="$HOME/.local/bin:$PATH"'
      echo 'eval "$(starship init bash)"'
    } >> "$BASHRC"
    echo "[ezdora][bash] Starship habilitado no bash como fallback."
  fi

  if ! grep -q "mise activate bash" "$BASHRC" 2>/dev/null; then
    {
      echo ''
      echo '# EzDora: mise activation (bash fallback)'
      echo 'if command -v mise >/dev/null 2>&1; then'
      echo '    eval "$(mise activate bash)"'
      echo 'fi'
    } >> "$BASHRC"
  fi
fi
