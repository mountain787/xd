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

## 经验加成系统

### HTTP API 用户经验加成

通过 HTTP API (新界面) 登录的玩家自动获得 50% 经验加成：

```pike
// 在玩家类中设置标记
int is_http_api_user;

// 经验计算时检查标记
int add_exp_with_bonus(int base_exp) {
    int final_exp = base_exp;
    if(this_object()->is_http_api_user && base_exp > 0) {
        final_exp = base_exp * 3 / 2;  // 1.5倍
    }
    this_object()->exp += final_exp;
    this_object()->current_exp += final_exp;
    return final_exp;
}
```

**经验显示格式：**
- 战斗：`【新界面加成+X】你得到了 Y 点经验。`
- 任务：`【新界面加成+X】得到了Y点经验。`
- 修炼：`你已经修炼了X分钟，获得Y点经验（含新界面加成）。`

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
