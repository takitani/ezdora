#!/usr/bin/env bash
set -euo pipefail

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
  chsh -s "$ZSH_PATH" "$USER" || echo "[ezdora][zsh] Não foi possível alterar shell automaticamente (talvez por ambiente não login). Faça manualmente: chsh -s $(command -v zsh)"
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

# Ensure mise activation for zsh
if ! grep -q "mise activate zsh" "$ZSHRC" 2>/dev/null; then
  {
    echo ''
    echo '# EzDora: mise activation'
    echo 'eval "$(mise activate zsh)"'
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
      echo 'eval "$(mise activate bash)"'
    } >> "$BASHRC"
  fi
fi
