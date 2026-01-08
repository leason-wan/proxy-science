#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${HOME}/.proxy-science"
PROXY_SCRIPT="proxy.sh"
CLAUDECODE_PROXY_SCRIPT="claudecode-proxy.sh"
DEFAULT_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")" && pwd)"

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
    log "Warning: ${PROXY_SCRIPT} not found, skipping"
  fi

  local claudecode_script_path="${DEFAULT_SOURCE_DIR}/${CLAUDECODE_PROXY_SCRIPT}"
  if [[ -f "${claudecode_script_path}" ]]; then
    log "Installing claudecode-proxy.sh"
    command cp -f "${claudecode_script_path}" "${INSTALL_DIR}/${CLAUDECODE_PROXY_SCRIPT}"
  else
    log "Warning: ${CLAUDECODE_PROXY_SCRIPT} not found, skipping"
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
