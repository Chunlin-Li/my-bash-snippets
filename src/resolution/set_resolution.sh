#!/usr/bin/env bash

# 手动将GUI的分辨率设置为 2048x1152 60Hz. 并从 HDMI1 输出

# 获取指定分辨率的信息
# cvt 2048 1152 60
# 根据上一步的输出信息, 创建一个新的模式
xrandr --newmode "2048x1152_60.00"  197.97  2048 2184 2408 2768  1152 1153 1156 1192  -HSync +Vsync
# 将上面创建的新显示模式添加到 HDMI1 上
xrandr --addmode HDMI1 2048x1152_60.00
# 切换到新的模式显示
xrandr --output HDMI1 --mode 2048x1152_60.00