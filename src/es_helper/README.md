
使用 curl 调用 elasticsearch 的 REST API 的一个 helper.  简化 curl 输入.

可以将该脚本设置为一个名字简单的 alias 比如 es 或 eshelper

```
syntax
    esHelper [HTTP_METHOD] PATH [DATA] [CURL_OPT]
example
    esHelper /_cat/indices
    esHelper get /_cat/indices
    esHelper get /myindex/_stats
    esHelper put /logindex '{settings:{}, mappings:{}}'
    esHelper post /_bulk '{index:{_index:"myindex",_type:"mytyep"}}\n{name:"alpha",age:3}\n'
```