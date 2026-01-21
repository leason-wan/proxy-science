#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${HOME}/.proxy-science"
PROXY_SCRIPT="proxy.sh"
CLAUDECODE_PROXY_SCRIPT="claudecode-proxy.sh"
DEFAULT_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")" && pwd)"
REPO_BASE_URL="${PROXY_SCIENCE_BASE_URL:-https://raw.githubusercontent.com/leason-wan/proxy-science/main}"

PROXY_SNIPPET='[ -s "$HOME/.proxy-science/proxy.sh" ] && source "$HOME/.proxy-science/proxy.sh"'
CLAUDECODE_SNIPPET='[ -s "$HOME/.proxy-science/claudecode-proxy.sh" ] && source "$HOME/.proxy-science/claudecode-proxy.sh"'

log() {
  printf '[proxy-science-install] %s\n' "$1"
}

copy_scripts() {
  mkdir -p "${INSTALL_DIR}"

  local script_path="${DEFAULT_SOURCE_DIR}/${PROXY_SCRIPT}"
  if [[ -f "${script_path}" ]]; then
    log "Installing proxy.sh"
    command cp -f "${script_path}" "${INSTALL_DIR}/${PROXY_SCRIPT}"
  else
    log "proxy.sh not found locally; downloading from ${REPO_BASE_URL}"
    download_script "${PROXY_SCRIPT}"
  fi

  local claudecode_script_path="${DEFAULT_SOURCE_DIR}/${CLAUDECODE_PROXY_SCRIPT}"
  if [[ -f "${claudecode_script_path}" ]]; then
    log "Installing claudecode-proxy.sh"
    command cp -f "${claudecode_script_path}" "${INSTALL_DIR}/${CLAUDECODE_PROXY_SCRIPT}"
  else
    log "claudecode-proxy.sh not found locally; downloading from ${REPO_BASE_URL}"
    download_script "${CLAUDECODE_PROXY_SCRIPT}"
  fi
}

download_script() {
  local script_name="$1"
  local target_path="${INSTALL_DIR}/${script_name}"
  local url="${REPO_BASE_URL}/${script_name}"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${url}" -o "${target_path}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "${target_path}" "${url}"
  else
    log "Error: curl or wget is required to download ${script_name}"
    return 1
  fi
}

append_snippet() {
  local rc_file="$1"
  local snippet="$2"
  local comment="$3"

  if [[ ! -e "${rc_file}" ]]; then
    touch "${rc_file}"
  fi

  if grep -F "${snippet}" "${rc_file}" >/dev/null 2>&1; then
    return
  fi

  {
    printf '\n# %s\n' "${comment}"
    printf '%s\n' "${snippet}"
  } >> "${rc_file}"
}

update_shell_profiles() {
  local rc_files=()
  case "$(uname -s)" in
    Darwin)
      rc_files=("${HOME}/.zshrc" "${HOME}/.bash_profile")
      ;;
    Linux*)
      rc_files=("${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.zshrc")
      ;;
    *)
      rc_files=("${HOME}/.bashrc")
      ;;
  esac

  for rc in "${rc_files[@]}"; do
    if [[ -f "${INSTALL_DIR}/${PROXY_SCRIPT}" ]]; then
      append_snippet "${rc}" "${PROXY_SNIPPET}" "proxy helper"
      log "Added proxy snippet to ${rc}"
    fi

    if [[ -f "${INSTALL_DIR}/${CLAUDECODE_PROXY_SCRIPT}" ]]; then
      append_snippet "${rc}" "${CLAUDECODE_SNIPPET}" "Claude Code proxy helper"
      log "Added Claude Code proxy snippet to ${rc}"
    fi
  done
}

main() {
  copy_scripts
  update_shell_profiles

  log "Installation complete!"
  cat <<'EOM'

已安装的脚本：
- proxy.sh       -> 使用 `proxy on/off/status` 命令
- claudecode-proxy.sh -> 使用 `ccp on/off/status` 命令

重新打开终端或运行以下命令让配置生效：
  source ~/.proxy-science/proxy.sh
  source ~/.proxy-science/claudecode-proxy.sh

或者直接 source 你的配置文件（如 ~/.bashrc 或 ~/.zshrc）
EOM
}

main "$@"
