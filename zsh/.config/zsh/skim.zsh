# ^t 查找文件
# ^p 查找目录
# ^r 在命令历史中查找
# ^f 查找文件中的字符串

# 需要提前安装好skim fd bat ripgrep

# 可以在这里更改skim的默认命令
export SKIM_DEFAULT_COMMAND="fd --type f -HL --exclude '.git' || git ls-tree -r --name-only HEAD || rg --files || find ."

# sk共用的参数，配置移动的快捷键为^e和^u，视图翻转成从上到下
OPTS=(
  --bind='ctrl-e:down,ctrl-u:up'
  --layout=reverse
)

fzf-redraw-prompt() {
	local precmd
	for precmd in $precmd_functions; do
		$precmd
	done
	zle reset-prompt
}
zle -N fzf-redraw-prompt

# ----------------- 搜索文件 -----------------
fzf-file-widget-custom() {
  # --multi参数在使用tab键的时候可以多选文件
	# -HL参数将会搜索隐藏文件和软链接
  local selected=$(fd --type f -HL --exclude '.git' | sk --multi --preview='bat -n --color=always {}' "${OPTS[@]}")
  
  # 如果有选中项
  if [[ -n "$selected" ]]; then
    # 将多行结果用空格连接起来
    #    (f) 按换行符分割，$selected 变成数组
    #    (j: :) 用空格连接数组元素
    local joined_selected="${(j: :)${(f)selected}}"
    
    # 将连接好的字符串追加到命令行
    LBUFFER+="${joined_selected} " # 追加一个空格以便输入下一个参数
  fi
  # 重绘提示符
  zle reset-prompt
}
zle -N fzf-file-widget-custom
bindkey '^t' fzf-file-widget-custom

# ----------------- 搜索目录 -----------------
fzf-cd-widget-custom() {
  # 使用 fd 并且只查找目录 (--type d)
  local dest_dir=$(fd --type d -HL | sk "${OPTS[@]}")
  # 如果选中了目录
  if [[ -n "$dest_dir" ]]; then
    # cd 到该目录
    cd "$dest_dir"
    # 清空命令行并重绘提示符
    LBUFFER=""
    zle fzf-redraw-prompt # 使用你已有的函数来重绘
  fi
}
zle -N fzf-cd-widget-custom
bindkey '^p' fzf-cd-widget-custom


# ----------------- 搜索历史命令 -----------------
fzf-history-widget-custom() {
  # 从 zsh 历史记录中选择
  local selected_cmd=$(fc -l -n 1 | sk --no-sort --tac --query "$LBUFFER" "${OPTS[@]}")
  if [[ -n "$selected_cmd" ]]; then
    # 替换整个命令行
    LBUFFER=$selected_cmd
  fi
  zle reset-prompt
}
zle -N fzf-history-widget-custom
bindkey '^R' fzf-history-widget-custom

# ----------------- 搜索文件里面的内容 -----------------
fzf-global-grep() {
	# 调用bat预览，高亮显示字符串所在行并实现一个“伪居中”的效果：
	# 需要高亮行的行号大于 10 时，从 行号 - 10 的位置开始显示，否则就从第 1 行开始
	local preview_command='
		file="{1}";
		line="{2}";
		start=$((line > 10 ? line - 10 : 1));
		bat --style=numbers --color=always --line-range "$start:" --highlight-line "$line" "$file"
	'
	# 1. 使用 ripgrep 搜索：
	#	 --color-always:高亮显示
	#	 --vimgrep:	    输出格式为 `文件路径:行号:列号:内容`
	#	 --no-heading:  在搜索目录时，不为每个文件添加标题。
	#	 --smart-case:  智能大小写匹配。
	#	sk相关参数：
	#	 --nth 4..: fzf 的一个技巧，只在前几个字段（文件名和行号、列号）之后的内容中搜索，
	#	 这样搜索 'foo' 时就不会意外匹配到名为 'foo.txt' 的文件。
	#	关于预览窗口--preview-window ：
	#	 'up,60%,border-bottom': 定义窗口在上方，占60%高度，带边框
	#	 '+{2}/2: 将预览内容滚动，使第 {2} 行(rg返回的行号)位于窗口中央(没有生效所以改用bat的--line-range显示指定范围)
	#	 'wrap': 如果一行内容太长，自动换行显示
	#	 {1}: rg返回的文件名
	local selected
	selected=$(sk --ansi \
		-i \
		-c 'rg --color=always --vimgrep --smart-case "{}"' \
		--delimiter ':' \
		--nth 4.. \
		--preview "sh -c '$preview_command' _ {1} {2}" \
		"${OPTS[@]}"
	)

	# 2. 如果用户没有按 Esc 中断，则处理选中的结果
	if [[ -n "$selected" ]]; then
		local file=$(echo "$selected" | cut -d: -f1)
		local line=$(echo "$selected" | cut -d: -f2)
		local column=$(echo "$selected" | cut -d: -f3)

		# --- 关键改动 4 ---
		# 使用 nvim 的 +call cursor() 函数来精确定位光标
		nvim "+call cursor(${line}, ${column})" "${file}"
	fi
}
zle -N fzf-global-grep-widget fzf-global-grep

# 绑定快捷键，例如 Ctrl+G
bindkey '^f' fzf-global-grep-widget

# fzf-global-grep() {
#   # 1. 使用 ripgrep 搜索，输出格式为 `文件路径:行号:内容`
#   #    --color=always:     高亮显示
#   #    -n, --line-number:  这是解决重复问题的关键，每匹配行只输出一次。
#   #    --no-heading:       在搜索目录时，不为每个文件添加标题。
#   #    --smart-case:       智能大小写匹配。
# 	#		 --nth 3..: fzf 的一个技巧，只在前两个字段（文件名和行号）之后的内容中搜索，
# 	# 	 这样搜索 'foo' 时就不会意外匹配到名为 'foo.txt' 的文件。
# 	# 	 关于预览窗口--preview-window ：
# 	# 	 'up,60%,border-bottom': 定义窗口在上方，占60%高度，带边框
# 	# 	 '+{2}/2':              将预览内容滚动，使第 {2} 行位于窗口中央
# 	# 	 'wrap':              如果一行内容太长，自动换行显示
#   local selected
#   selected=$(rg --color=always --line-number --no-heading --smart-case '' | \
# 		sk --ansi \
# 			--delimiter ':' \
# 			--nth 3.. \
# 			--preview 'sh -c '\''
# 				file="{1}";
# 				line="{2}";
# 				# 实现一个“伪居中”的效果：需要高亮行的行号大于 10 时，从 行号 - 10 的位置开始显示，否则就从第 1 行开始
# 				start=$((line > 10 ? line - 10 : 1));
# 				bat --style=numbers --color=always --line-range "$start:" --highlight-line "$line" "$file"
# 				# 这是 sh -c 的一个标准用法。_ 是一个占位符，传给脚本作为名称 ($0)。 {1} (文件名) 会被 sk 替换并作为第一个参数 ($1) 传给脚本。{2} (行号) 会被作为第二个参数 ($2) 传入
# 			'\'' _ {1} {2}' \
# 			"${OPTS[@]}"
# 	)

#   # 2. 如果用户没有按 Esc 中断，则处理选中的结果
#   if [[ -n "$selected" ]]; then
#     # 3. 从 `文件路径:行号:列号:内容` 中提取文件路径和行号
#     #    使用 cut 命令，以 ':' 为分隔符
#     local file=$(echo "$selected" | cut -d: -f1)
#     local line=$(echo "$selected" | cut -d: -f2)

#     # 4. 在 Neovim 中打开该文件的指定行
#     nvim "+${line}" "${file}"
#   fi
# }
