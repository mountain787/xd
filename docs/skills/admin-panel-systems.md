# 管理后台系统 (Admin Panel Systems)

## 概述

本文档记录 txpike9 和 xiand 两个项目的管理后台系统架构、功能模块和实现差异。

---

## txpike9 管理系统

### 核心文件结构

```
txpike9/
├── gamenv/d/manager/m94ayhohe      # 管理员房间（主入口）
├── gamenv/single/daemons/
│   ├── szxvipd.pike                # VIP会员系统daemon
│   ├── exp_settingd.pike           # 经验倍数系统daemon
│   └── check_bangd.pike            # 帮派检查daemon
└── pikenv/wapmud2/single/bangd.pike # 帮派系统daemon（大文件）
```

### 管理员房间 (m94ayhohe)

**路径**: `/usr/local/games/txpike9/gamenv/d/manager/m94ayhohe`

**主要功能**:
- `[shout]` - 发送系统广播消息
- `[wholist]` - 查看在线用户列表（已注释）
- `[msg_read admin old]` - 查看/修改公告
- `[msg_write_entry]` - 添加新公告
- `[manage_userMain]` - 查看账号详细信息
- `[manageRoom]` - 管理黑屋（封号名单）
- `[qge74hye manager/xxx]` - 特卖商店/道具/商人管理
- `[manageExpSetting]` - 管理经验倍数
- `[gcStatus]` - 查看GC状态
- `[manageBang]` - 管理帮派
- `[manageAddMember]` - 添加帮派成员
- `[manage_promotion all]` - 推荐系统管理

**权限检查**:
```pike
int checkpower(string arg)
{
    string userid = me->name;
    if(MANAGED->checkpower("xxx"))
        return 1;
    return 0;
}
```

### szxvipd.pike - VIP会员系统

**路径**: `/usr/local/games/txpike9/gamenv/single/daemons/szxvipd.pike`

**等级系统** (19个等级):
| 等级 | 名称 | 充值范围 |
|------|------|----------|
| 1 | 普通 | 50-100 |
| 2 | 蓝铜 | 100-200 |
| 3 | 银月 | 200-300 |
| 4 | 水晶 | 300-500 |
| 5 | 金星 | 500-800 |
| 6 | 白金 | 800-1200 |
| 7 | 红宝石 | 1200-2000 |
| 8 | 蓝宝石 | 2000-2800 |
| 9 | 黄钻 | 2800-3800 |
| 10 | 绿钻 | 3800-5000 |
| 11 | 粉钻 | 5000-8000 |
| 12 | 紫钻 | 8000-10000 |
| 13 | 皇冠 | 10000-10500 |
| 14 | 星级皇冠 | 10500-15000 |
| 15-19 | N星级皇冠 | 15000-50000+ |

**主要功能**:
- `query_szx_grade(object player)` - 返回玩家VIP等级
- `query_szx_grade_cn(object player)` - 返回等级中文名
- `init_szx_vip_day_buy_repute()` - 初始化每日购买荣誉点权限
- `init_szx_vip_day_free_get()` - 初始化每日免费buff获取
- `init_szx_vip_free_rock()` - 初始化幸运宝石领取
- `init_szx_vip_free_box()` - 初始化宝箱领取

**权限编码系统**:
使用字符串编码存储权限：
- `day_buy_power` - 每日购买权限（第2位=荣誉卷轴数量）
- `free_get_power` - 免费获取权限（10位，每位代表一种buff）
- `free_rock` - 幸运宝石数量
- `free_box` - 宝箱数量

### exp_settingd.pike - 经验倍数系统

**路径**: `/usr/local/games/txpike9/gamenv/single/daemons/exp_settingd.pike`

**配置文件**: `gamenv/u/exp_setting.conf`

**格式**: `prefix:multiplier:enabled`
```
tx10:5:1    # tx10区服 5倍经验 开启
tx11:10:0   # tx11区服 10倍经验 关闭
```

**主要API**:
- `set_multiplier(string prefix, int multiplier)` - 设置倍数
- `del_prefix(string prefix)` - 删除配置
- `get_multiplier(string prefix)` - 获取倍数
- `query_all_config()` - 获取所有配置
- `query_config_string()` - 获取配置显示字符串

**管理界面**: `manageExpSetting` 命令
1. 显示当前配置
2. 选择区号 (支持单区 `tx01` 和合服区 `tx01-06`)
3. 选择倍数 (关闭/2倍/3倍/5倍/10倍/20倍/50倍/100倍)
4. 保存配置

### 帮派管理 (BANGD)

**功能**:
- 列出所有帮派状态
- 查看帮派详情
- 重置人数不足计数
- 重置上线不足计数
- 添加玩家到帮派
- 设置帮派成员等级

---

## xiand 管理系统

### 核心文件结构

```
xiand/
├── gamelib/cmds/game_deal.pike        # 管理命令主入口
├── gamelib/cmds/mgr_usr_data.pike     # 用户数据管理
├── gamelib/d/manager_room             # 管理员房间
├── gamelib/single/daemons/
│   ├── managed.pike                   # 管理daemon（禁言/封号）
│   └── vipd.pike                      # VIP系统daemon
└── gamelib/etc/
    ├── mananer_id                     # 管理员ID列表
    ├── unlogin_id                     # 封号名单
    └── unchat_id                      # 禁言名单
```

### 管理命令 (game_deal.pike)

**路径**: `/usr/local/games/xiand/gamelib/cmds/game_deal.pike`

**入口命令**: `game_deal`

**主要功能**:
- `[wiz_shout2]` - 发送系统消息
- `[mgr_script]` - 在线更新脚本
- `[mgr_usr_data]` - 用户数据管理
- `game_deal manager_user_online allcount` - 在线总数
- `game_deal manager_user_online not not not` - 实时在线列表
- `game_deal unchat_user_list` - 禁言用户列表
- `game_deal unlogin_user_list` - 封号用户列表
- `game_deal manager_user_history` - 历史用户查询（未实现）

**用户管理功能**:
- 查看用户详细资料（等级、性别、通宝、门派、帮派等）
- 禁言操作（1/4/8小时，1/2/4/8天）
- 封号操作（1/4/8小时，1/2/4/8天）
- 解除禁言/封号

### managed.pike - 管理Daemon

**路径**: `/usr/local/games/xiand/gamelib/single/daemons/managed.pike`

**权限系统**:
- `admin` - 最高权限管理员（可封禁/解封）
- `assist` - 辅助管理员（只能封禁，不能解封）
- `nopower` - 无权限

**数据结构**:
```pike
mapping(string:string) manager_mem = ([]);      // [id:权限]
mapping(string:array) unlogin_mem = ([]);       // [id:({id,中文名,起始时间,期限,时间描述})]
mapping(string:array) unchat_mem = ([]);        // [id:({id,中文名,起始时间,期限,时间描述})]
```

**主要API**:
- `checkpower(string userid)` - 检查权限，返回 "admin"/"assist"/"nopower"
- `add_unlogin(mid, userid, usernamecn, limit_time)` - 添加封号
- `free_user_login(mid, userid)` - 解除封号
- `add_unchat(mid, userid, usernamecn, limit_time)` - 添加禁言
- `free_user_chat(mid, userid)` - 解除禁言
- `list_nologin_user(userid)` - 列出封号列表
- `list_nochat_user(userid)` - 列出禁言列表
- `query_unlogin_desc(userid)` - 查询封号状态描述
- `query_unchat_desc(userid)` - 查询禁言状态描述

**自动存档**: 每10分钟回写到文件

### vipd.pike - VIP系统

**路径**: `/usr/local/games/xiand/gamelib/single/daemons/vipd.pike`

**较简单的VIP系统**:
- VIP等级和价格配置从文件读取
- 支持VIP升级、续费
- VIP免费物品领取
- VIP折扣购买
- 自动检测VIP过期

**主要API**:
- `get_vip_state(object player)` - 返回VIP状态（0=非VIP,1=正常,2=优惠期,3=即将到期）
- `get_vip_state_des(object player)` - 返回VIP状态描述和链接
- `give_vip_to(object player, int level)` - 授予VIP
- `display_free_goods(sub, lv)` - 显示免费物品
- `display_off_goods(sub, lv)` - 显示折扣物品

### 管理员房间 (manager_room)

**路径**: `/usr/local/games/xiand/gamelib/d/manager_room`

**功能**:
- `[paihang_account_toplist]` - 财富排行榜
- `[paihang_mark_toplist]` - 综合实力排行榜
- `[msg_read admin old]` - 历史公告管理
- `[msg_write_entry]` - 新增公告
- `[fee_exchange_list]` - 兑换欢乐棋牌筹码
- `[wiz_check_user ...]` - 玩家帐号检查

---

## 功能对比表

| 功能 | txpike9 | xiand | 备注 |
|------|---------|-------|------|
| 系统广播 | ✅ shout | ✅ wiz_shout2 | |
| 在线用户列表 | ✅ wholist | ✅ manager_user_online | |
| 公告管理 | ✅ | ✅ | |
| 封号系统 | ✅ manageRoom | ✅ managed.pike | xiand更完善 |
| 禁言系统 | ❌ | ✅ managed.pike | txpike9无 |
| VIP系统 | ✅ szxvipd.pike (19级) | ✅ vipd.pike | txpike9更复杂 |
| 经验倍数 | ✅ exp_settingd.pike | ❌ | 可迁移 |
| 帮派管理 | ✅ manageBang | ❌ | |
| 推荐系统 | ✅ manage_promotion | ❌ | |
| GC状态 | ✅ gcStatus | ❌ | |
| 特卖商店 | ✅ | ❌ | |
| 历史用户查询 | ❌ | ⏳ 未实现 | |

---

## 可迁移功能

### 1. 经验倍数系统 (exp_settingd.pike)

需要迁移的文件:
- `gamenv/single/daemons/exp_settingd.pike` → `gamelib/single/daemons/exp_settingd.pike`
- 管理房间中的 `manageExpSetting` 相关代码
- 配置文件: `gamenv/u/exp_setting.conf` → `gamelib/data/exp_setting.conf`

修改点:
- 路径从 `gamenv` 改为 `gamelib`
- 根目录常量检查
- 日志路径调整

### 2. VIP系统升级 (szxvipd.pike)

需要适配:
- 19级VIP系统
- 权限编码系统
- 每日免费领取（buff/宝石/宝箱）

注意: xiand已有vipd.pike，需要评估是否替换或合并

### 3. 帮派管理

如果xiand有帮派系统，可以添加管理界面:
- 查看帮派列表
- 管理解散倒计时
- 添加帮派成员

---

## 常用命令速查

### txpike9 管理员房间命令
```
shout <消息>                    # 发送系统广播
manageExpSetting                # 经验倍数管理
manageBang                      # 帮派管理
manageAddMember <帮派ID>        # 添加帮派成员
manage_promotion all            # 推荐系统管理
gcStatus                       # GC状态
```

### xiand 管理命令
```
game_deal                       # 管理主界面
game_deal manager_user_online not not not    # 在线用户列表
game_deal unchat_user_list      # 禁言列表
game_deal unlogin_user_list     # 封号列表
game_deal manager_user_online char_user <ID> not  # 查看用户详情
wiz_shout2                      # 发送系统消息
```

---

## 文件路径速查

### txpike9
- 管理员房间: `gamenv/d/manager/m94ayhohe`
- VIP daemon: `gamenv/single/daemons/szxvipd.pike`
- 经验倍数: `gamenv/single/daemons/exp_settingd.pike`
- 管理员名单: `gamenv/etc/mananer_id` (实际可能不存在)

### xiand
- 管理命令: `gamelib/cmds/game_deal.pike`
- 管理 daemon: `gamelib/single/daemons/managed.pike`
- VIP daemon: `gamelib/single/daemons/vipd.pike`
- 管理员房间: `gamelib/d/manager_room`
- 管理员名单: `gamelib/etc/mananer_id`
- 封号名单: `gamelib/etc/unlogin_id`
- 禁言名单: `gamelib/etc/unchat_id`

---

## 待实现功能

- [ ] 经验倍数系统迁移
- [ ] 帮派管理界面
- [ ] 推荐系统管理
- [ ] GC状态监控
- [ ] 历史用户查询（数据库集成）
