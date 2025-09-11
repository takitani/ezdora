# Repository Guidelines

## Project Structure & Module Organization
- Root: `install.sh` (orquestra), `bootstrap.sh` (clona e executa), `README.md`.
- Apps: `install/apps/*.sh` — um app por arquivo, executados em ordem alfabética por `install/apps.sh`.
- Nomeação de scripts de app:
  - DNF: `install/apps/dnf-<app>.sh` (ex.: `dnf-vlc.sh`, `dnf-chrome.sh`).
  - Flatpak: `install/apps/flatpak-<app>.sh` (ex.: `flatpak-obsidian.sh`).

## Build, Test, and Development Commands
- Executar instalação completa: `bash install.sh`.
- Executar um app específico: `bash install/apps/dnf-vlc.sh` (ou qualquer outro `.sh`).
- Bootstrap remoto (clona para `~/.local/share/ezdora`): `bash bootstrap.sh`.

## Coding Style & Naming Conventions
- Bash estrito em todos os scripts: `#!/usr/bin/env bash` + `set -euo pipefail`.
- Idempotência: verifique presença antes de instalar (ex.: `rpm -q pkg || sudo dnf install -y pkg`).
- Use `sudo` apenas quando necessário; prefira `dnf` a Flatpak quando houver pacote nativo estável.
- Mantenha scripts pequenos e focados (1 responsabilidade/app).
- URLs de repositórios: usar HTTPS e fontes oficiais (ex.: Google, RPM Fusion, COPR `scottames/ghostty`, Microsoft VS Code).

## Testing Guidelines
- Não há framework de testes; valide em Fedora 42+ (idealmente VM).
- Teste por unidade executando cada script: `bash install/apps/flatpak-discord.sh`.
- Lint opcional: `shellcheck install/**/*.sh` para detectar problemas comuns.

## Commit & Pull Request Guidelines
- Commits pequenos e descritivos. Preferir Conventional Commits:
  - Ex.: `feat(app): add flatpak-obsidian installer`, `fix(dnf-vlc): handle rpmfusion failure`.
- PRs devem incluir:
  - Resumo do objetivo, comandos executados para teste e impacto esperado.
  - Referências/issues quando aplicável; logs de erro relevantes.

## Security & Configuration Tips
- Scripts adicionam repositórios de terceiros (Google, RPM Fusion, COPR). Revise URLs e o escopo antes de mesclar.
- `bootstrap.sh` aceita `EZDORA_REPO_URL` para customizar a origem do clone.
- Evite modificar `install.sh` para lógica por‑app; adicione/edite scripts em `install/apps/` para manter a revisão simples.

