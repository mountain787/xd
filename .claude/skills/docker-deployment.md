# Docker 部署 Skill

当用户需要在 203 服务器上部署 xiand Docker 容器时，使用此技能。

## 环境信息

- 服务器：203 (CentOS Stream 10)
- 项目：xiand (仙道 MUD)
- 镜像：lijingmt/xiand-all:latest

## 目录结构

```
/usr/local/games/xiand/          # 项目根目录
├── docker/
│   ├── Dockerfile.all           # 一体化镜像（Pike + Tomcat）
│   └── docker-compose.yml       # Docker Compose 配置
├── rebuild-image.sh             # 构建并推送镜像
├── restart-docker.sh            # 启动容器脚本
├── xd.sql                       # 数据库初始化文件
└── vue_source/                  # Vue 前端源码

/usr/local/games/allxd/          # 数据目录（按区号）
├── xd01/
│   ├── data_xiand/              # 游戏数据
│   └── item/                    # 物品数据
├── xd02/
│   ├── data_xiand/
│   └── item/
└── log/
    ├── xd01/                    # 日志
    └── xd02/
```

## 目录映射

| 容器内路径 | 宿主机路径 | 说明 |
|-----------|-----------|------|
| `/app/xiand/data_xiand` | `/usr/local/games/allxd/{GAME_AREA}/data_xiand` | 游戏数据 |
| `/app/xiand/gamelib/clone/item` | `/usr/local/games/allxd/{GAME_AREA}/item` | 物品数据 |
| `/app/xiand/log` | `/usr/local/games/allxd/log/{GAME_AREA}/` | 日志文件 |

## 部署步骤

### 1. 拉取代码

```bash
cd /usr/local/games/xiand
git pull
```

### 2. 构建 Vue 前端

```bash
cd vue_source
node build.js
```

### 3. 构建 Docker 镜像（可选）

```bash
# 仅构建本地镜像，不推送
SKIP_PUSH=1 ./rebuild-image.sh

# 或者推送到 Docker Hub
DOCKER_TOKEN=your_token ./rebuild-image.sh
```

### 4. 启动容器

```bash
# 格式: ./restart-docker.sh [GAME_AREA] [TOMCAT_PORT] [API_PORT] [IMAGE_TAG]

# 启动 xd01 区，端口 9001，API 8888
./restart-docker.sh xd01 9001 8888

# 启动 xd02 区，端口 9002，API 8889
./restart-docker.sh xd02 9002 8889

# 启动 xd01-05 合服区，端口 9005，API 8890
./restart-docker.sh xd01-05 9005 8890
```

### 5. 查看日志

```bash
# 查看容器日志
docker logs -f xiand-xd01

# 查看 MUD 日志
tail -f /usr/local/games/allxd/log/xd01/pike.log
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `GAME_AREA` | xd01 | 游戏区号 |
| `GAME_AREAS` | xd01,xd02,xd03,xd04,xd05 | Vue 前端分区列表 |
| `MYSQL_HOST` | 172.17.0.1 | MySQL 主机 |
| `MYSQL_PORT` | 3306 | MySQL 端口 |
| `MYSQL_USER` | root | MySQL 用户 |
| `MYSQL_PASSWORD` | Happy888888 | MySQL 密码 |

## 端口说明

| 端口 | 说明 |
|------|------|
| 13800 | MUD 服务端口 |
| 8888+ | HTTP API 端口（可配置） |
| 9001+ | Tomcat HTTP 端口（可配置） |
| 8443 | Tomcat HTTPS 端口 |

## 数据库自动初始化

容器启动时会自动：
1. 创建数据库（如 xd01）
2. 检查数据库是否为空
3. 如果为空，自动导入 `xd.sql`

## 常见问题

### 容器无法启动

```bash
# 查看容器状态
docker ps -a

# 查看容器日志
docker logs xiand-xd01

# 检查目录权限
ls -la /usr/local/games/allxd/xd01/
```

### 数据库连接失败

```bash
# 检查 MySQL 是否运行
systemctl status mariadb

# 测试连接
mysql -u root -pHappy888888 -e "SHOW DATABASES;"

# 检查防火墙
sudo firewall-cmd --list-all
```

### 目录权限问题

```bash
# 修复权限
chmod -R 777 /usr/local/games/allxd/xd01/
chmod -R 777 /usr/local/games/allxd/log/xd01/
```

### Vue 前端分区配置

分区列表由 `GAME_AREAS` 环境变量控制，容器启动时会自动更新 Vue 配置：

```bash
# 自定义分区列表
GAME_AREAS="xd01,xd02,xd03" ./restart-docker.sh xd01 9001 8888
```

## 容器管理

```bash
# 停止容器
docker stop xiand-xd01

# 启动容器
docker start xiand-xd01

# 重启容器
docker restart xiand-xd01

# 删除容器
docker rm -f xiand-xd01

# 查看容器资源使用
docker stats xiand-xd01

# 进入容器
docker exec -it xiand-xd01 bash
```

## 镜像管理

```bash
# 查看镜像
docker images | grep xiand

# 删除旧镜像
docker rmi lijingmt/xiand-all:old-tag

# 拉取最新镜像
docker pull lijingmt/xiand-all:latest
```

## 调试命令

```bash
# 进入容器检查 Pike
docker exec -it xiand-xd01 bash
which pike
pike -v

# 检查 Tomcat
docker exec -it xiand-xd01 bash
ls -la /usr/local/tomcat/

# 检查 MUD 进程
docker exec -it xiand-xd01 bash
ps aux | grep pike

# 测试 MUD 连接
telnet 127.0.0.1 13800
```

## 重启流程

```bash
# 1. 停止并删除旧容器
docker stop xiand-xd01
docker rm xiand-xd01

# 2. 重新构建前端
cd /usr/local/games/xiand/vue_source && node build.js && cd ..

# 3. 启动新容器
./restart-docker.sh xd01 9001 8888

# 4. 查看日志
docker logs -f xiand-xd01
```

## 多区部署

```bash
# 启动多个区（每个区使用不同的 API 端口）
./restart-docker.sh xd01 9001 8888
./restart-docker.sh xd02 9002 8889
./restart-docker.sh xd03 9003 8890
./restart-docker.sh xd04 9004 8891
./restart-docker.sh xd05 9005 8892
```

## 合服部署

```bash
# 启动合服区 xd01-05
GAME_AREAS="xd01,xd02,xd03,xd04,xd05" ./restart-docker.sh xd01-05 9001 8888
```

