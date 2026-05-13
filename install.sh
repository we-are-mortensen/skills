#!/usr/bin/env bash
#
# Mortensen Skills installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/we-are-mortensen/skills/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/we-are-mortensen/skills/main/install.sh | bash -s <skill-name>
#
set -euo pipefail

REPO_URL="https://github.com/we-are-mortensen/skills.git"
REPO_RAW="https://raw.githubusercontent.com/we-are-mortensen/skills/main"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Colours (only if stdout is a TTY)
if [ -t 1 ]; then
  BOLD="$(printf '\033[1m')"; DIM="$(printf '\033[2m')"
  GREEN="$(printf '\033[32m')"; YELLOW="$(printf '\033[33m')"
  BLUE="$(printf '\033[34m')"; RED="$(printf '\033[31m')"
  RESET="$(printf '\033[0m')"
else
  BOLD=""; DIM=""; GREEN=""; YELLOW=""; BLUE=""; RED=""; RESET=""
fi

say()   { printf "%s\n" "$*"; }
info()  { printf "${BLUE}›${RESET} %s\n" "$*"; }
ok()    { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}!${RESET} %s\n" "$*"; }
err()   { printf "${RED}✗${RESET} %s\n" "$*" >&2; }

# When the script is piped from curl, stdin is the pipe — we need /dev/tty for prompts.
if [ -t 0 ]; then
  PROMPT_FD="/dev/stdin"
else
  if [ -e /dev/tty ]; then
    PROMPT_FD="/dev/tty"
  else
    err "No interactive terminal available. Pass the skill name as an argument:"
    err "  curl ... | bash -s <skill-name>"
    exit 1
  fi
fi

ask() {
  # ask "prompt" "default"
  local prompt="$1" default="${2:-}" answer
  if [ -n "$default" ]; then
    printf "%s${DIM} [%s]${RESET}: " "$prompt" "$default" > /dev/tty
  else
    printf "%s: " "$prompt" > /dev/tty
  fi
  IFS= read -r answer < "$PROMPT_FD" || answer=""
  printf "%s" "${answer:-$default}"
}

ask_choice() {
  # ask_choice "prompt" "default-index" "opt1" "opt2" ...
  local prompt="$1"; shift
  local default_idx="$1"; shift
  local i=1
  printf "${BOLD}%s${RESET}\n" "$prompt" > /dev/tty
  for opt in "$@"; do
    if [ "$i" = "$default_idx" ]; then
      printf "  ${GREEN}%d)${RESET} %s ${DIM}(default)${RESET}\n" "$i" "$opt" > /dev/tty
    else
      printf "  %d) %s\n" "$i" "$opt" > /dev/tty
    fi
    i=$((i+1))
  done
  local choice
  printf "Choice ${DIM}[%s]${RESET}: " "$default_idx" > /dev/tty
  IFS= read -r choice < "$PROMPT_FD" || choice=""
  choice="${choice:-$default_idx}"
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$#" ]; then
    err "Invalid choice: $choice"
    exit 1
  fi
  eval "printf '%s' \"\${$choice}\""
}

confirm() {
  # confirm "prompt" "Y|N"
  local prompt="$1" default="${2:-Y}" hint answer
  if [ "$default" = "Y" ]; then hint="Y/n"; else hint="y/N"; fi
  printf "%s ${DIM}[%s]${RESET}: " "$prompt" "$hint" > /dev/tty
  IFS= read -r answer < "$PROMPT_FD" || answer=""
  answer="${answer:-$default}"
  case "$answer" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
say ""
printf "${BOLD}Mortensen Skills${RESET} installer\n"
printf "${DIM}https://github.com/we-are-mortensen/skills${RESET}\n"
say ""

# ---------------------------------------------------------------------------
# 1. Clone repo (shallow) so we can list skills and copy them
# ---------------------------------------------------------------------------
info "Fetching skill index…"
if ! git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR/repo" 2>/dev/null; then
  err "Could not clone $REPO_URL"
  exit 1
fi

# Discover skills: any top-level directory containing a SKILL.md
mapfile -t AVAILABLE < <(
  find "$TMP_DIR/repo" -mindepth 2 -maxdepth 2 -name SKILL.md -print0 \
    | xargs -0 -n1 dirname \
    | xargs -n1 basename \
    | sort
)

if [ "${#AVAILABLE[@]}" -eq 0 ]; then
  err "No skills found in the repository."
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Pick the skill
# ---------------------------------------------------------------------------
SKILL_NAME="${1:-}"
if [ -z "$SKILL_NAME" ]; then
  say ""
  SKILL_NAME="$(ask_choice "Which skill do you want to install?" 1 "${AVAILABLE[@]}")"
fi

# Validate
FOUND=0
for s in "${AVAILABLE[@]}"; do
  if [ "$s" = "$SKILL_NAME" ]; then FOUND=1; break; fi
done
if [ "$FOUND" -ne 1 ]; then
  err "Skill '$SKILL_NAME' not found. Available: ${AVAILABLE[*]}"
  exit 1
fi

SKILL_SRC="$TMP_DIR/repo/$SKILL_NAME"

# ---------------------------------------------------------------------------
# 3. Global vs local
# ---------------------------------------------------------------------------
say ""
SCOPE="$(ask_choice "Where do you want to install it?" 2 \
  "Global  (~/.claude/skills/)  — available in every Claude Code session" \
  "Local   (./.claude/skills/)  — only in the current project (commit-friendly)"
)"

case "$SCOPE" in
  Global*) DEST_BASE="$HOME/.claude/skills"; SCOPE_LABEL="global" ;;
  Local*)  DEST_BASE="$(pwd)/.claude/skills"; SCOPE_LABEL="local"  ;;
  *) err "Unknown scope"; exit 1 ;;
esac

DEST="$DEST_BASE/$SKILL_NAME"

# ---------------------------------------------------------------------------
# 4. Overwrite check
# ---------------------------------------------------------------------------
if [ -e "$DEST" ]; then
  warn "$DEST already exists."
  if ! confirm "Overwrite?" "Y"; then
    say "Aborted."
    exit 0
  fi
  rm -rf "$DEST"
fi

# ---------------------------------------------------------------------------
# 5. Install
# ---------------------------------------------------------------------------
mkdir -p "$DEST_BASE"
cp -R "$SKILL_SRC" "$DEST"

say ""
ok "Installed ${BOLD}$SKILL_NAME${RESET} (${SCOPE_LABEL}) at:"
say "  $DEST"
say ""
say "${DIM}Restart your Claude Code session (or run /reload) for the skill to be picked up.${RESET}"
say ""
