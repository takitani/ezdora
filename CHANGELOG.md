# Changelog

All notable changes to this project will be documented in this file.

## v0.1.0 — initial cut

- Bootstrap via HTTPS one‑liner; clones to `~/.local/share/ezdora`.
- Modular per‑app installers in `install/apps/*.sh`.
- KDE integration: Ghostty como terminal padrão e `Ctrl+Alt+T` remapeado.
- Fonts: instala CascadiaMono, JetBrainsMono (Nerd Fonts) e iA Writer; seletor interativo (gum/fzf) de fonte e tamanho; aplica ao Ghostty.
- Shell: define zsh; Starship com preset rico (hora, git, linguagens, .NET), histórico preservado.
- mise: instala `node@latest` (npm) e `dotnet@9` globalmente; `mise activate` no zsh/bash.
- Navegadores/Apps: Google Chrome (repo oficial), VLC (RPM Fusion), LocalSend, Discord, Obsidian, Mission Center, Postman, Slack, ZapZap.
- Terminais/CLI: Ghostty (COPR), htop, tree, unzip/zip, wget/curl, xclip, wl-clipboard, vim, git, zsh.
- Neovim: instala via DNF com `python3-neovim`; LazyVim starter se não houver config; transparência com toggle `:EzTransparencyToggle`.
- Docker: instala Docker Engine (repo oficial), habilita serviço/grupo; lazydocker.
- JetBrains Toolbox: instala via tarball oficial em `~/.local/share/JetBrains/Toolbox` e symlink em `~/.local/bin`.

