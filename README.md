# EzDora (Ez Fedora)

Um post-install minimalista para Fedora 42 KDE (ou superior), focado em instalar alguns apps essenciais via DNF e Flatpak, com instaladores modulares (um app por arquivo), inspirado no Omakub.

## Como usar

- Rodar localmente (clonado este repositório):
  - `bash install.sh`

- Ou usar o bootstrap (clona para `~/.local/share/ezdora` e executa):
  - `bash bootstrap.sh`

- Rodar remoto (uma linha, sem clonar manualmente):
  - Padrão (HTTPS — evita prompts de SSH):
    - `bash <(curl -fsSL https://raw.githubusercontent.com/takitani/ezdora/master/bootstrap.sh)`
    - Se quiser garantir que não use cache: `bash <(curl -fsSL "https://raw.githubusercontent.com/takitani/ezdora/master/bootstrap.sh?nocache=$(date +%s)")`
  - Alternativa com wget:
    - `bash <(wget -qO- https://raw.githubusercontent.com/takitani/ezdora/master/bootstrap.sh)`

### Notas rápidas
- O bootstrap clona o repositório via HTTPS (repo público). Não precisa de SSH.

## O que faz

- Verifica que está em Fedora 42+.
- Atualiza o sistema e metadados (`dnf upgrade --refresh`).
- Garante `git`, `curl`, `flatpak` e `dnf-plugins-core` instalados.
- Configura Flathub (se necessário).
- Executa scripts individuais em `install/apps/*.sh` para instalar cada app.

## Apps padrão incluídos

- DNF: curl, wget, git, vim, htop, tree, unzip, zip, xclip, wl-clipboard, zsh, starship, google-chrome-stable (habilita repo Google), ghostty (habilita COPR `scottames/ghostty`), vlc (habilita RPM Fusion)
- Flatpak: LocalSend (`org.localsend.localsend_app`), ZapZap (`com.rtosta.zapzap`), Discord (`com.discordapp.Discord`), Obsidian (`md.obsidian.Obsidian`), Mission Center (`io.missioncenter.MissionCenter`), Postman (`com.getpostman.Postman`), Slack (`com.slack.Slack`)
- VS Code: via DNF (`code`) com repositório oficial da Microsoft
- Mise: via script oficial (`https://mise.jdx.dev/install.sh`)

Você pode editar as listas em `packages/dnf.txt` e `packages/flatpak.txt` antes de rodar para ajustar.

## Observações

- Chrome via repositório oficial do Google (habilitado automaticamente).
- VLC via DNF (RPM Fusion), LocalSend e demais via Flathub, Ghostty via DNF (COPR `scottames/ghostty`).
- KDE: o script define Ghostty como terminal padrão, mapeia Ctrl+Alt+T para abrir Ghostty e ajusta as animações para "Instant" automaticamente (idempotente; pode reexecutar `bash install.sh` a qualquer momento para autocorrigir).
