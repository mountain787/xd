#!/bin/bash
#!/usr/local/bin/pike

# 导出MySQL密码环境变量
# 如果.env文件存在则从其中读取
if [ -f /usr/local/games/xiand/.env ]; then
    export $(grep -v '^#' /usr/local/games/xiand/.env | xargs)
fi

# 检查MYSQL_PASSWORD是否设置
if [ -z "$MYSQL_PASSWORD" ]; then
    echo "错误: MYSQL_PASSWORD 环境变量未设置!"
    echo "请创建 .env 文件并设置 MYSQL_PASSWORD，或导出该环境变量"
    exit 1
fi

/bin/kill $(ps ax|grep pike|grep 13800|cut -d' ' -f1)
/bin/kill $(ps ax|grep pike|grep 13800|cut -d' ' -f2)
/bin/kill $(ps ax|grep pike|grep 13800|cut -d' ' -f3)

pike /usr/local/games/xiand/lowlib/driver.pike -i 127.0.0.1 -p 13800 /usr/local/games/xiand/ &
