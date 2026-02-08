#!/bin/bash
#!/usr/local/bin/pike

# 导出MySQL密码环境变量
# 如果.env文件存在则从其中读取
if [ -f /usr/local/games/xiand/.env ]; then
    export $(grep -v '^#' /usr/local/games/xiand/.env | xargs)
fi

# 如果没有设置MYSQL_PASSWORD，使用默认值
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-"888888"}

/bin/kill $(ps ax|grep pike|grep 13800|cut -d' ' -f1)
/bin/kill $(ps ax|grep pike|grep 13800|cut -d' ' -f2)
/bin/kill $(ps ax|grep pike|grep 13800|cut -d' ' -f3)

pike /usr/local/games/xiand/lowlib/driver.pike -i 127.0.0.1 -p 13800 /usr/local/games/xiand/ &
