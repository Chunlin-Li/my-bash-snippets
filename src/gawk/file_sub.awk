{
  if(FNR==NR) { # first file
        map[$0]=1
  } else {  # second file
        if ($1 in map) {
        } else {
            print $1
        }
  }
}

# awk -f this.awk file1 file2
# 输出所有 file2 中存在, 但 file1 中不存在的行.
