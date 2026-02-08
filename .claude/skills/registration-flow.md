# 注册流程 (Registration Flow)

## 概述

xiand的注册功能通过HTTP API实现，支持Vue前端和JSP两种方式。

## 架构

```
Vue/JSP前端 → HTTP API → 用户创建 → setup() → 保存用户文件
```

## 参数格式

### Vue格式（优先）
```
login_regnew gamelib xd01username passwordHash sessionId challenge
```
- `gamelib`: 项目名称（游戏目录）
- `xd01username`: 带分区前缀的完整用户名
- `passwordHash`: 使用challenge进行SHA256哈希后的密码
- `sessionId`: 随机生成的会话ID
- `challenge`: 从/api/challenge获取的安全令牌

### JSP格式
```
login_regnew gamelib user password sid game_pre m_key userip userua
```
- `gamelib`: 项目名称
- `user`: 不含前缀的用户名
- `password`: 明文密码
- `sid`: JSP会话ID
- `game_pre`: 分区前缀（如xd01）
- `m_key`: 移动端key
- `userip`: 用户IP
- `userua`: 用户代理

## HTTP API处理流程

文件位置: `gamelib/single/daemons/http_api_daemon.pike`

### 1. 参数解析
```pike
// 先尝试Vue格式（6个参数）
int parse_result = sscanf(cmd, "login_regnew %s %s %s %s %s %s",
                          projname, user_name, pswd, sid, challenge, game_pre);

// 如果失败，尝试JSP格式（8个参数）
if(parse_result < 5) {
    parse_result = sscanf(cmd, "login_regnew %s %s %s %s %s %s %s %s",
                          projname, user_name, pswd, sid, game_pre, m_key, userip, userua);
}
```

### 2. 提取分区前缀和实际用户名
```pike
string game_fg = game_pre || "";
string actual_user = user_name;

// 如果user_name包含分区前缀(字母+2位数字)，提取出来
if(sscanf(user_name, "%[a-zA-Z]%d%s", prefix, num, rest) == 3 && sizeof(prefix) == 2) {
    game_fg = prefix + sprintf("%02d", num);
    actual_user = rest;
}
```

### 3. 验证用户名
- 长度: 2-12字符（不含分区前缀）
- 字符: 只允许字母和数字
- 返回错误: `error2,用户名过长` / `error2,用户名过短` / `error2,用户名只能包含字母和数字`

### 4. 检查用户是否存在
```pike
// 检查用户文件
string user_file_path = ROOT + "/gamelib/u/" + full_username[sizeof(full_username)-2..] + "/" + full_username + ".o";

// 检查在线用户
object user_in_memory = find_player(full_username);
```
- 返回错误: `error1,用户名已存在` / `error1,用户已在线`

### 5. 创建用户对象
```pike
// 加载master.pike获取connect函数
m = (object)(ROOT + "/gamelib/master.pike");
u = m->connect();

// 或直接加载user.pike
u = (program)(ROOT + "/gamelib/clone/user.pike");

// 创建实例
object me = u();
me->set_name(full_username);
me->set_password(pswd);
me->set_project(projname || "gamelib");
me->set_userip(client_ip);

// 初始化sid（直接访问成员变量，不使用query方法）
if(!me->sid) {
    me->sid = sid || "tmpUser";
}
```

### 6. 调用setup()
```pike
if(me->setup(pswd)) {
    // 注册成功
    if(environment(me) == 0)
        me->move(LOW_VOID_OB);
    result = actual_user + "," + pswd;
}
```

## 返回格式

### 成功
```
username,passwordHash
```
例如: `jinghaha12,a949af381b77fef17702c59ef6ef9463858df93d28e01d4bd9431d25fa0cab5f`

### 失败
```
error_code,error_message
```
- `error1,用户名已存在`
- `error1,用户已在线`
- `error2,用户名过长，最多12个字符（当前15个）`
- `error2,用户名过短，最少2个字符`
- `error2,密码过短，最少2个字符`
- `error2,用户名只能包含字母和数字`
- `error2,系统错误: 无法加载用户程序`
- `error2,用户初始化失败`

## Vue前端实现

文件位置: `vue_source/js/app.js`

```javascript
// 生成sessionId
const sessionId = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);

// 获取challenge
const challengeResp = await fetch(this.apiBase + '/api/challenge');
const challengeData = await challengeResp.json();
const challenge = challengeData.challenge;

// 计算密码哈希
const passwordHash = await sha256(challenge + this.registerForm.password);

// 构建注册命令
const cmd = `login_regnew gamelib ${fullUserid} ${passwordHash} ${sessionId} ${challenge}`;

// 发送请求
const response = await fetch(this.apiBase + '/api/html?cmd=' + encodeURIComponent(cmd));
```

## 重要配置

### 项目名称
- xiand使用 `gamelib`（不是`gamenv`）
- 配置在Vue源码: `vue_source/js/app.js`

### 用户文件路径
```
/usr/local/games/xiand/gamelib/u/{用户名倒数两位}/{完整用户名}.o
```

例如: `xd01jinghaha12` → `/usr/local/games/xiand/gamelib/u/12/xd01jinghaha12.o`

## 调试日志

启用HTTP API日志查看详细注册流程:
```bash
tail -f /usr/local/games/xiand/log/http_api.log
```

关键日志标识:
- `=== REGISTER REQUEST ===`
- `sscanf Vue format result:`
- `Parsed: game_fg=, user_name=`
- `Step 1-5:` 各步骤执行状态
- `Registration SUCCESS` 或错误信息

## 最近更新

**2025-02-08**
- ✅ 修复项目名称从gamenv改为gamelib
- ✅ 直接使用me->sid而不是me->query("sid")
- ✅ 优先解析Vue格式参数
- ✅ 支持带分区前缀的用户名验证
- ✅ 返回详细错误信息
- ✅ 修复游戏图片路径：自动移除/xd/前缀（/xd/images/xxx.gif → /images/xxx.gif）
