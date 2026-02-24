---
name: battle-system
description: 处理战斗系统、血量显示、battle_status API接口等相关功能
version: 1.0.0
---

# 战斗系统 (Battle System)

这个技能涵盖了 Pike9 MUD 游戏中的战斗系统相关功能，包括战斗状态 API、NPC 血量显示、战斗属性获取等。

## 核心 API

### `/api/battle_status` 接口

获取当前战斗状态，包括玩家和敌人的信息。

**请求参数：**
- `txd`: TXD 认证字符串

**返回数据结构：**
```json
{
  "in_battle": true,
  "player": {
    "userid": "xd01jinghaha",
    "name_cn": "无心法师",
    "hp": 38,
    "hp_max": 70,
    "level": 1,
    "exp": 60,
    "exp_need": 800,
    "energy": 64,
    "mana": 0,
    "profe": "剑仙",
    "race": "人类"
  },
  "enemy": {
    "name": "tulou1",
    "name_cn": "土蝼",
    "is_npc": 1,
    "level": 1,
    "hp": 60,
    "hp_max": 100,
    "is_dead": 0,
    "profe": "野兽",
    "race": "野兽",
    "attack": 10,
    "defend": 5
  }
}
```

## NPC 血量获取

### 关键函数

NPC 的血量使用以下函数获取：

```pike
// 获取当前血量
int get_cur_life()

// 获取最大血量
int query_life_max()
```

**重要：** NPC 使用 `life/life_max` 变量，而不是玩家的 `jing/jing_max`。

### 正确的血量获取方式

```pike
// 检查函数是否存在
if(functionp(enemy_obj->get_cur_life)) {
    e_hp = enemy_obj->get_cur_life();
}
if(functionp(enemy_obj->query_life_max)) {
    e_hp_max = enemy_obj->query_life_max();
}

// -1 表示死亡，转为 0
if(e_hp < 0) {
    e_hp = 0;
}

enemy_state["hp"] = e_hp;
enemy_state["hp_max"] = e_hp_max;
enemy_state["is_dead"] = (e_hp <= 0);
```

## 战斗属性

### 玩家属性

| 属性 | 说明 | 获取方法 |
|------|------|----------|
| hp | 当前血量 | `get_cur_life()` |
| hp_max | 最大血量 | `query_life_max()` |
| level | 等级 | `query_level()` |
| exp | 经验值 | `query_exp()` |
| exp_need | 升级所需经验 | `query_levelUp_need_exp()` |
| energy | 精力 | `query_jingli()` |
| mana | 法力 | `get_cur_mofa()` |
| mana_max | 最大法力 | `query_mofa_max()` |
| profe | 职业 | `query_profe_cn()` |
| race | 种族 | `query_race_cn()` |

### NPC 属性

| 属性 | 说明 | 获取方法 |
|------|------|----------|
| name | 内部名称 | `query_name()` |
| name_cn | 显示名称 | `query_name_cn()` |
| is_npc | 是否为NPC | `is_npc()` |
| level | 等级 | `query_level()` |
| hp | 当前血量 | `get_cur_life()` |
| hp_max | 最大血量 | `query_life_max()` |
| profe | 职业/种类 | `query_profe_cn()` |
| race | 种族 | `query_race_cn()` |
| attack | 攻击力 | `query_attack_power()` |
| defend | 防御力 | `query_defend_power()` |

## 战斗相关文件

### 核心文件

- **`gamelib/single/daemons/http_api_daemon.pike`** - HTTP API 主文件
  - `handle_api_battle_status()` - 战斗状态接口

- **`lowlib/wapmud2/inherit/feature/fight.pike`** - 战斗系统核心
  - 战斗逻辑
  - 技能释放
  - 仇恨系统

- **`lowlib/wapmud2/inherit/npc.pike`** - NPC 基类
  - NPC 属性定义
  - `life` / `life_max` 变量

- **`lowlib/mudlib/inherit/feature/char.pike`** - 角色属性
  - `get_cur_life()` - 获取当前血量
  - `query_life_max()` - 获取最大血量

### 战斗命令

- **`lowlib/wapmud2/cmds/kill_quick.pike`** - 快速战斗命令

## HTTP API 经验加成系统

### 功能概述

通过 HTTP API (新界面/Vue前端) 登录的玩家自动获得 **50% 经验加成**，鼓励玩家使用新界面。

### 实现架构

#### 1. 玩家标记

**文件：** `lowlib/wapmud2/inherit/user.pike`

```pike
// HTTP API 用户标记 - 用于经验加成等特殊功能
int is_http_api_user;
```

#### 2. 登录检测

**文件：** `lowlib/system/cmds/login_check.pike`

HTTP API 登录时设置标记：
```pike
// HTTP API 模式检测：检查全局标记
int is_http_api = is_http_api_login(user_name);
if(is_http_api) {
    // 标记玩家为 HTTP API 用户（用于经验加成等）
    me->is_http_api_user = 1;
    // 不调用 exec()，更新虚拟连接池
    http_api_daemon->set_virtual_connection(user_name, ({0, time(), me}));
}
```

Socket (老界面) 登录时重置标记：
```pike
} else {
    // Socket 模式：重置 HTTP API 标记，正常调用 exec()
    me->is_http_api_user = 0;
    exec(me,previous_object());
    destruct(previous_object());
}
```

#### 3. 经验加成函数

**文件：** `lowlib/mudlib/inherit/feature/level.pike`

```pike
/**
 * 添加经验值（HTTP API 用户自动获得 50% 加成）
 * @param base_exp 基础经验值
 * @return 实际获得的经验值（含加成）
 */
int add_exp_with_bonus(int base_exp)
{
    object me = this_object();
    int final_exp = base_exp;

    // HTTP API 用户获得 50% 经验加成
    if(me->is_http_api_user && base_exp > 0) {
        final_exp = base_exp * 3 / 2;  // 1.5倍 = 原始 + 50%加成
    }

    me->exp += final_exp;
    me->current_exp += final_exp;
    return final_exp;
}
```

#### 4. 经验获取位置

| 位置 | 文件 | 说明 |
|------|------|------|
| 战斗经验 | `gamelib/inherit/npc.pike` | 击杀怪物获得经验 |
| 任务奖励 | `gamelib/single/daemons/taskd.pike` | 完成任务获得经验 |
| 自动修炼 | `gamelib/single/daemons/autolearnd.pike` | 挂机修炼获得经验 |

### 经验显示格式

#### 战斗经验
```pike
// 构建 HTTP API 加成提示
string api_tip = "";
if(first->is_http_api_user && actual_exp > exp_gain) {
    int bonus = actual_exp - exp_gain;
    api_tip = "<font style=\"color:GOLD\">【新界面加成+"+bonus+"】</font> ";
}
t += api_tip + "你得到了 "+actual_exp+" 点经验。\n";
```

**显示效果：** `【新界面加成+30】你得到了 90 点经验。`

#### 任务奖励
```pike
if(player->is_http_api_user && actual_exp > get_exp) {
    int bonus = actual_exp - get_exp;
    s_rtn = "【新界面加成+"+bonus+"】得到了"+actual_exp+"点经验。\n";
} else {
    s_rtn = "得到了"+actual_exp+"点经验。\n";
}
```

#### 自动修炼
```pike
string api_bonus_tip = "";
if(user->is_http_api_user && actual_exp > speed) {
    api_bonus_tip = "（含新界面加成）";
}
resultDesc = "你已经修炼了"+ time +"分钟，获得"+ exp +"点经验"+api_bonus_tip+"。";
```

### 关键流程

#### HTTP API 登录流程

```
1. 前端发送 /api 请求（含 txd）
2. http_api_daemon 解码 txd 获取用户名密码
3. 设置 http_api_login_pending[userid] = 1
4. 调用 login_check.pike 进行登录
5. login_check 检测到 http_api_login_pending 标记
6. 设置 me->is_http_api_user = 1
7. 将玩家加入虚拟连接池（不调用 exec()）
8. 清除 http_api_login_pending 标记
```

#### Socket 登录流程

```
1. Socket 连接建立
2. 调用 login_check.pike 进行登录
3. http_api_login_pending 标记不存在（值为 0）
4. 设置 me->is_http_api_user = 0
5. 调用 exec() 切换连接
```

### 安全性考虑

1. **状态切换安全**：每次登录时都会重新设置 `is_http_api_user` 标记
   - HTTP API 登录 → 设为 1
   - Socket 登录 → 设为 0

2. **只对正经验加成**：`base_exp > 0` 检查确保损失经验时不触发加成

3. **函数调用检查**：所有属性获取都使用 `functionp()` 检查函数存在性

### 相关文件列表

| 文件 | 作用 |
|------|------|
| `lowlib/wapmud2/inherit/user.pike` | 玩家类，定义 `is_http_api_user` 标记 |
| `lowlib/system/cmds/login_check.pike` | 登录检测，设置/重置标记 |
| `lowlib/mudlib/inherit/feature/level.pike` | 经验系统，提供 `add_exp_with_bonus()` |
| `gamelib/inherit/npc.pike` | 战斗经验，应用加成 |
| `gamelib/single/daemons/taskd.pike` | 任务经验，应用加成 |
| `gamelib/single/daemons/autolearnd.pike` | 修炼经验，应用加成 |
| `gamelib/single/daemons/http_api_daemon.pike` | HTTP API，管理虚拟连接 |

## 常见问题

### Q: NPC 血量返回 null？

**原因：** 代码使用了错误的变量名 `jing/jing_max`（玩家的变量），而 NPC 使用的是 `life/life_max`。

**解决：** 使用 `get_cur_life()` 和 `query_life_max()` 函数。

### Q: 如何判断敌人是否死亡？

```pike
int is_dead = (e_hp <= 0);
// 或者
int is_dead = (enemy_obj->get_cur_life() <= 0);
```

### Q: 如何获取战斗中的敌人对象？

```pike
// 方法1: 通过 query_attack_target()
if(functionp(enemy_obj->query_attack_target)) {
    if(enemy_obj->query_attack_target() == player) {
        // 这是敌人的敌人
    }
}

// 方法2: 遍历房间生物
array inv = all_inventory(room);
foreach(inv, object ob) {
    if(functionp(ob->query_in_combat) && ob->query_in_combat()) {
        // 在战斗中
    }
}
```

## 使用场景

当用户提到以下问题时，触发此技能：
- "battle_status"
- "战斗状态"
- "NPC 血量"
- "敌人属性"
- "攻击力"
- "防御力"
- "战斗 API"
- "经验加成"
- "新界面加成"
- "HTTP API 经验"
- "is_http_api_user"
- "新界面50%加成"
