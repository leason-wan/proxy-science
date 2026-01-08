# proxy-science

一个最简单的代理开关脚本：在终端里随时 `proxy on/off/status` 或 `ccp on/off/status` 就能切换代理环境变量。

- `proxy` - 适用于大多数命令行工具（curl、git、wget 等）
- `ccp` - 专门针对 Claude Code

## 一键安装

```bash
bash install.sh
```

或者从 GitHub 安装：

```bash
curl -fsSL https://raw.githubusercontent.com/leason-wan/proxy-science/main/install.sh | bash
```

> 如果你想安装指定版本，把 `main` 换成具体 tag，比如 `.../v1.0.0/install.sh`。

安装脚本会做这些事：

1. 复制 `proxy.sh` 和 `claudecode-proxy.sh` 到 `~/.proxy-science/` 目录。
2. 自动在常见的 `~/.bashrc`、`~/.zshrc` 等文件里加入 source 语句。
3. 提示你重新打开终端（或 `source` 你的配置文件）让命令生效。

## 使用方式

安装生效后，有两个命令可用：

### 1. 普通代理（适用于大多数命令行工具）

```bash
proxy on      # 打开代理（导出 http_proxy/https_proxy/all_proxy 等变量）
proxy off     # 关闭代理（清理所有 *_proxy 变量）
proxy status  # 查看当前 shell 是否有 *_proxy 变量
```

### 2. Claude Code 代理（专门针对 Claude Code）

```bash
ccp on      # 打开 Claude Code 代理
ccp off     # 关闭 Claude Code 代理
ccp status  # 查看当前代理状态
```

**区别说明：**
- `proxy` 使用小写环境变量（`http_proxy`、`https_proxy`），适用于 curl、wget、git 等大多数命令行工具
- `ccp` 使用大写环境变量（`HTTP_PROXY`、`HTTPS_PROXY`），专门针对 Claude Code

默认代理地址为 `192.168.10.20:7890`，想换地址直接编辑对应的脚本文件即可。

## 自定义

- 直接编辑 `~/.proxy-science/proxy.sh`，把里面的代理地址改成你自己的服务器或端口。
- 对于 Claude Code 代理，编辑 `~/.proxy-science/claudecode-proxy.sh` 即可。
