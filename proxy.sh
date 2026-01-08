# === 代理 开/关/状态 ===
proxy_on() {
  export http_proxy="http://192.168.10.20:7890"
  export https_proxy="http://192.168.10.20:7890"
  export all_proxy="socks5://192.168.10.20:7890"

  # 兼容用大写变量的程序
  export HTTP_PROXY="$http_proxy"
  export HTTPS_PROXY="$https_proxy"
  export ALL_PROXY="$all_proxy"

  # 不走代理的地址（可按需改）
  export no_proxy="127.0.0.1,localhost,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  export NO_PROXY="$no_proxy"

  echo "Proxy ON -> $http_proxy / $all_proxy"
}

proxy_off() {
  unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
  unset no_proxy NO_PROXY
  echo "Proxy OFF"
}

proxy_status() {
  env | grep -i '_proxy' || echo "no *_proxy variables set"
}

# 一个统一的命令：proxy on/off/status
proxy() {
  case "$1" in
    on|1)  proxy_on ;;
    off|0) proxy_off ;;
    status|"") proxy_status ;;
    *) echo "Usage: proxy {on|off|status}" ;;
  esac
}