{
  if(FNR==NR) {
    list[$0] = 1      # 载入文件A中的所有id
  } else {
    match($0, /"id":"([^"]+)/, arr);    # 对文件B的每一行提取目标字符串到 arr 中
    if (arr[1] != "" && arr[1] in list) {   # 如果提取成功, 且提取到的 id 存在于文件A中, 则输出当前行
#    if (arr[1] != "" && !(arr[1] in list)) {  # 不存在的情况.
        print $0
    }
  }
}
