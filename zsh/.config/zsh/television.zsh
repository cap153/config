# ╭──────────────────────────────────────────────────────────╮
# │    Shell集成 自动补全 (Ctrl+T) 命令历史 (Ctrl+R)         │
# ╰──────────────────────────────────────────────────────────╯
eval "$(tv init zsh)"

# ╭──────────────────────────────────────────────────────────╮
# │              Ctrl-F查找文本内容                          │
# ╰──────────────────────────────────────────────────────────╯
_tv_text_widget() {
    # 1. 使 ZLE 失效
    zle -I
    # 2. 显式关闭括号粘贴模式 (防止转义码干扰)
    # \e[?2004l 是关闭，\e[?2004h 是开启
    printf '\e[?2004l'
    # 3. 运行 tv 并确保标准输入输出指向当前 TTY
    # 使用 < /dev/tty 是解决 ZLE 交互问题的万金油
    tv text < /dev/tty
    # 4. 恢复括号粘贴模式 (还给 Zsh)
    printf '\e[?2004h'
    # 5. 重绘提示符
    zle reset-prompt
}
zle -N _tv_text_widget
bindkey '^F' _tv_text_widget
bindkey -M viins '^F' _tv_text_widget

# ╭──────────────────────────────────────────────────────────╮
# │      Television Channel参数补全                          │
# ╰──────────────────────────────────────────────────────────╯
_tv() {
    local cable_dir="${HOME}/.config/television/cable"
    typeset -A chan_map
    # 内置默认值
    chan_map=(
        'alias' 'Alias channel'
        'bash-history' 'Bash history channel'
        'dirs' 'Directories channel'
        'docker-images' 'Docker images channel'
        'env' 'Environment variables channel'
        'files' 'Files channel'
        'git-branch' 'Git branches channel'
        'git-diff' 'Git diff channel'
        'git-log' 'Git log channel'
        'git-repos' 'Git repositories channel'
        'text' 'Text search channel'
    )
    # 扫描目录并解析描述
    if [[ -d "$cable_dir" ]]; then
        for f in "$cable_dir"/*.toml(N); do
            local name="${f:t:r}"
            # 使用 awk 提取描述：
            local desc=$(awk '/description =/ {
                sub(/.*description =[[:space:]]*/, "");
                if ($0 ~ /^("""|'\'\'\''|"|'\'')\s*$/ || $0 == "") { getline; }
                gsub(/^[[:space:]]*["'\'']+|["'\'']+[[:space:]]*$/, "");
                if ($0 != "") { print $0; exit; }
            }' "$f")
            # 如果读到了描述，存入 Map（如果是内置同名频道，会覆盖旧描述）
            if [[ -n "$desc" ]]; then
                # 限制描述长度，防止 fzf 界面乱掉（可选）
                [[ ${#desc} -gt 70 ]] && desc="${desc[1,67]}..."
                chan_map[$name]="$desc"
            else
                # 如果文件里真没写描述，且 Map 里也没有（说明不是内置频道），给个默认文案
                [[ -z "${chan_map[$name]}" ]] && chan_map[$name]="Custom channel"
            fi
        done
    fi
    # 转换回 _arguments 需要的格式
    local -a channels
    for k v in ${(kv)chan_map}; do
        channels+=("${k}:${v}")
    done

    _arguments -s \
        '--help[Show help]' \
        '--version[Show version]' \
        '1:channel:(($channels))' \
        '*:filename:_files'
}

compdef _tv tv

# ╭──────────────────────────────────────────────────────────╮
# │   Ctrl-t查找文件(和默认的zsh集成冲突)                    │
# ╰──────────────────────────────────────────────────────────╯
# _tv_files_widget() {
# 	# 运行 tv files 并获取输出
# 	local selected=$(tv files)
# 	if [[ -n "$selected" ]]; then
# 		# 将结果插入到当前光标位置
# 		LBUFFER+="${selected}"
# 	fi
# 	# 强制重新绘图，防止界面残留
# 	zle reset-prompt
# }
# zle -N _tv_files_widget
# bindkey '^T' _tv_files_widget
# # vi模式也生效
# bindkey -M viins '^T' _tv_files_widget

# ╭──────────────────────────────────────────────────────────╮
# │                          修复光标形状                    │
# ╰──────────────────────────────────────────────────────────╯
_patch_television_widgets() {
  # 获取所有以 _tv- 开头的函数（这些是 television 生成的 widget）
  local tv_widgets=(${(k)functions[(I)_tv-*]})
  for w in $tv_widgets; do
    # 避免重复包装
    [[ "$w" == *_orig ]] && continue
    # 将原始函数重命名（例如 _tv-files 改名为 _tv-files_orig）
    functions[${w}_orig]=$functions[$w]
    # 重新定义该 Widget：执行原逻辑 + 修复光标
    eval "
    $w() {
      zle ${w}_orig
      if [[ -n \"\$(typeset -f zle-keymap-select)\" ]]; then
        zle-keymap-select
      fi
      zle reset-prompt
    }
    "
  done
}
_patch_television_widgets

