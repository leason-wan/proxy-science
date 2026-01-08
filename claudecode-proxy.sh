# === Claude Code 代理 开/关/状态 ===
: "${CLAUDECODE_PROXY_CONFIG_FILE:=$HOME/.proxy-science/claudecode-config}"

ccp_load_config() {
  CCP_CONFIG_BASE_URL=""
  CCP_CONFIG_AUTH_TOKEN=""
  CCP_CONFIG_MODEL=""
  if [ -f "$CLAUDECODE_PROXY_CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CLAUDECODE_PROXY_CONFIG_FILE"
  fi
}

ccp_save_config() {
  local config_dir
  config_dir="$(dirname "$CLAUDECODE_PROXY_CONFIG_FILE")"
  mkdir -p "$config_dir"
  {
    printf 'CCP_CONFIG_BASE_URL=%q\n' "$CCP_CONFIG_BASE_URL"
    printf 'CCP_CONFIG_AUTH_TOKEN=%q\n' "$CCP_CONFIG_AUTH_TOKEN"
    printf 'CCP_CONFIG_MODEL=%q\n' "$CCP_CONFIG_MODEL"
  } > "$CLAUDECODE_PROXY_CONFIG_FILE"
}

ccp_prompt_config() {
  echo "=== Configure Claude Code Anthropic Proxy ==="
  local default_base
  default_base="${CCP_CONFIG_BASE_URL:-https://api.toprouter.ai/api/anthropic}"
  while true; do
    printf 'Anthropic Base URL [%s]: ' "$default_base"
    IFS= read -r base_input || base_input=""
    base_input="${base_input:-$default_base}"
    if [ -n "$base_input" ]; then
      CCP_CONFIG_BASE_URL="$base_input"
      break
    fi
    echo "Base URL cannot be empty."
  done

  if [ -n "$CCP_CONFIG_AUTH_TOKEN" ]; then
    printf 'Anthropic Auth Token (leave blank to keep existing): '
    if [ -t 0 ]; then stty -echo; fi
    IFS= read -r token_input || token_input=""
    if [ -t 0 ]; then stty echo; printf '\n'; else printf '\n'; fi
    if [ -n "$token_input" ]; then
      CCP_CONFIG_AUTH_TOKEN="$token_input"
    fi
  else
    while [ -z "$CCP_CONFIG_AUTH_TOKEN" ]; do
      printf 'Anthropic Auth Token: '
      if [ -t 0 ]; then stty -echo; fi
      IFS= read -r token_input || token_input=""
      if [ -t 0 ]; then stty echo; printf '\n'; else printf '\n'; fi
      if [ -n "$token_input" ]; then
        CCP_CONFIG_AUTH_TOKEN="$token_input"
      else
        echo "Auth token cannot be empty."
      fi
    done
  fi

  local default_model
  default_model="${CCP_CONFIG_MODEL:-tp.claude-sonnet-4-5-20250929}"
  while true; do
    printf 'Anthropic Model [%s]: ' "$default_model"
    IFS= read -r model_input || model_input=""
    model_input="${model_input:-$default_model}"
    if [ -n "$model_input" ]; then
      CCP_CONFIG_MODEL="$model_input"
      break
    fi
    echo "Model name cannot be empty."
  done

  ccp_save_config
  echo "Saved configuration to $CLAUDECODE_PROXY_CONFIG_FILE"
}

ccp_configure() {
  ccp_load_config
  ccp_prompt_config
}

ccp_ensure_config() {
  ccp_load_config
  if [ -z "$CCP_CONFIG_BASE_URL" ] || [ -z "$CCP_CONFIG_AUTH_TOKEN" ] || [ -z "$CCP_CONFIG_MODEL" ]; then
    ccp_prompt_config
  fi
}

ccp_on() {
  ccp_ensure_config

  # Claude Code 代理请求走 TopRouter Anthropic 代理
  export ANTHROPIC_BASE_URL="$CCP_CONFIG_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$CCP_CONFIG_AUTH_TOKEN"
  export ANTHROPIC_MODEL="$CCP_CONFIG_MODEL"
  export ANTHROPIC_SMALL_FAST_MODEL="$CCP_CONFIG_MODEL"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="$CCP_CONFIG_MODEL"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="$CCP_CONFIG_MODEL"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="$CCP_CONFIG_MODEL"

  echo "Claude Code Proxy ON -> $ANTHROPIC_BASE_URL"
}

ccp_off() {
  unset ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_MODEL ANTHROPIC_SMALL_FAST_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL ANTHROPIC_DEFAULT_OPUS_MODEL
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  echo "Claude Code Proxy OFF"
}

ccp_status() {
  if [ -n "$ANTHROPIC_BASE_URL" ] || [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
    echo "Claude Code Proxy Status:"
    [ -n "$ANTHROPIC_BASE_URL" ] && echo "  ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
    [ -n "$ANTHROPIC_AUTH_TOKEN" ] && echo "  ANTHROPIC_AUTH_TOKEN=$ANTHROPIC_AUTH_TOKEN"
    [ -n "$ANTHROPIC_MODEL" ] && echo "  ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
    [ -n "$ANTHROPIC_SMALL_FAST_MODEL" ] && echo "  ANTHROPIC_SMALL_FAST_MODEL=$ANTHROPIC_SMALL_FAST_MODEL"
    [ -n "$ANTHROPIC_DEFAULT_SONNET_MODEL" ] && echo "  ANTHROPIC_DEFAULT_SONNET_MODEL=$ANTHROPIC_DEFAULT_SONNET_MODEL"
    [ -n "$ANTHROPIC_DEFAULT_OPUS_MODEL" ] && echo "  ANTHROPIC_DEFAULT_OPUS_MODEL=$ANTHROPIC_DEFAULT_OPUS_MODEL"
    [ -n "$ANTHROPIC_DEFAULT_HAIKU_MODEL" ] && echo "  ANTHROPIC_DEFAULT_HAIKU_MODEL=$ANTHROPIC_DEFAULT_HAIKU_MODEL"
  else
    ccp_load_config
    if [ -n "$CCP_CONFIG_BASE_URL" ] || [ -n "$CCP_CONFIG_AUTH_TOKEN" ] || [ -n "$CCP_CONFIG_MODEL" ]; then
      echo "Claude Code Proxy: OFF (configuration saved in $CLAUDECODE_PROXY_CONFIG_FILE)"
      [ -n "$CCP_CONFIG_BASE_URL" ] && echo "  Saved ANTHROPIC_BASE_URL=$CCP_CONFIG_BASE_URL"
      [ -n "$CCP_CONFIG_AUTH_TOKEN" ] && echo "  Saved ANTHROPIC_AUTH_TOKEN is set"
      [ -n "$CCP_CONFIG_MODEL" ] && echo "  Saved ANTHROPIC_MODEL=$CCP_CONFIG_MODEL"
    else
      echo "Claude Code Proxy: OFF (no Anthropic overrides set)"
    fi
  fi
}

# 一个统一的命令：ccp on/off/status
ccp() {
  case "$1" in
    on|1)  ccp_on ;;
    off|0) ccp_off ;;
    status|"") ccp_status ;;
    config|configure) ccp_configure ;;
    *) echo "Usage: ccp {on|off|status|config}" ;;
  esac
}

ccp_load_config
