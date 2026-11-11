#!/usr/bin/env bash
# Roda a Godot em ambiente isolado (bubblewrap):
#  - sem acesso à rede
#  - só vê a placa de vídeo e a tela (Wayland) para abrir a janela
#  - sistema inteiro somente leitura
#  - só a pasta do projeto pode ser alterada
#  - o resto do seu HOME fica invisível; HOME da Godot = tools/home (configurações da Godot não vão para o seu ~)
# Uso: tools/godot.sh [argumentos da Godot]   ex.: tools/godot.sh --headless --import
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$ROOT/tools/godot/Godot_v4.7.2-stable_linux.x86_64"
mkdir -p "$ROOT/tools/home"

# Placa de vídeo (para abrir a janela do jogo). Sem ela a Godot só roda com --headless.
GPU=()
[ -e /dev/dri ] && GPU=(--dev-bind /dev/dri /dev/dri)

exec bwrap \
	--ro-bind / / \
	--dev /dev \
	--proc /proc \
	"${GPU[@]}" \
	--tmpfs /tmp \
	--tmpfs "$HOME" \
	--bind "$ROOT" "$ROOT" \
	--bind "$ROOT/tools/home" /tmp/home \
	--unshare-net \
	--unshare-pid \
	--die-with-parent \
	--chdir "$ROOT" \
	--setenv HOME /tmp/home \
	--setenv TESTE_DETALHADO "${TESTE_DETALHADO:-}" \
	"$GODOT" --path "$ROOT" "$@"
