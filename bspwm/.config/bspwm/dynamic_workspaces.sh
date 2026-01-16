#!/bin/sh

# 监听 bspwm 的事件：
# node_add: 窗口打开
# node_remove: 窗口关闭
# node_transfer: 窗口移动
# desktop_focus: 切换工作区 (用于检测是否需要删除多余的)
bspc subscribe node_add node_remove node_transfer desktop_focus | while read -r event; do

    # 1. 获取最后一个工作区的名字 (例如 "1", "2", "3")
    last_ds_name=$(bspc query -D --names | tail -n1)
    
    # 2. 检查最后一个工作区是否有窗口
    # bspc query -N -d ... -n .window : 查找该工作区下的窗口节点
    last_is_occupied=$(bspc query -N -n .window -d "$last_ds_name")

    # =================================================
    # 规则 A：扩展 (当最后一个工作区被占用时，新建下一个)
    # =================================================
    if [ -n "$last_is_occupied" ]; then
        # 计算下一个编号
        new_ds_num=$((last_ds_name + 1))
        # 添加新工作区
        bspc monitor -a "$new_ds_num"
    fi

    # =================================================
    # 规则 B：收缩 (当末尾有多余空工作区时，删除)
    # 逻辑：如果 "最后一个为空" 且 "倒数第二个也为空"，删除最后一个
    # 这样可以保留 1 个空白工作区作为缓冲，像 Cosmic 一样
    # =================================================
    
    # 获取当前工作区总数
    total_count=$(bspc query -D | wc -l)

    if [ "$total_count" -gt 1 ]; then
        # 获取倒数第二个工作区的名字
        prev_ds_name=$(bspc query -D --names | tail -n2 | head -n1)
        
        # 检查占用情况
        last_occupied=$(bspc query -N -n .window -d "$last_ds_name")
        prev_occupied=$(bspc query -N -n .window -d "$prev_ds_name")
        
        # 获取当前聚焦的工作区 (防止删掉你正盯着看的工作区)
        focused_ds=$(bspc query -D -d focused --names)

        # 如果 [最后空] 且 [倒数第二空] 且 [当前没聚焦在最后一个]
        if [ -z "$last_occupied" ] && [ -z "$prev_occupied" ] && [ "$last_ds_name" != "$focused_ds" ]; then
            bspc desktop "$last_ds_name" -r
        fi
    fi

done
