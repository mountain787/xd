---
name: equipment-deduplication
description: 处理装备按钮重复累积问题和相关游戏优化
version: 1.0.0
---

# 装备按钮去重与游戏优化

这个技能涵盖了处理装备按钮重复累积问题，以及相关的游戏优化功能。

## 问题背景

在 Pike9 MUD 游戏中，装备物品的 `query_inventory_links()` 函数每次被调用时都会在 `inventory_links` 变量上追加新的按钮文本。这个变量会被序列化保存到玩家档案文件中，导致重复的按钮不断累积，最终档案文件变得很大，显示时出现大量重复按钮。

## 解决方案

### 1. 基础类去重 (links.pike)

在 `/usr/local/games/lowlib/wapmud2/inherit/feature/links.pike` 中添加智能去重函数：

```pike
private string safe_deduplicate(string links_str) {
    // 使用 catch 包裹，确保任何错误都不会影响原有功能
    mixed err = catch {
        // 统计每个命令动词出现的次数
        mapping(string:int) link_counts = ([]);
        mapping(string:string) last_link = ([]);
        // ... 解析和去重逻辑
    };
    if(err) {
        werror("[links.pike] safe_deduplicate error: %s\n", describe_error(err));
        return links_str;  // 出错时返回原字符串
    }
}
```

**关键点：**
- 使用 `catch` 捕获所有可能的错误
- 错误时返回原字符串，不会破坏原有功能
- 有错误日志输出，方便调试
- 无重复时直接返回，无性能损耗

### 2. 子类检查 (装备类)

在装备子类中添加链接存在检查：

```pike
string query_inventory_links(void|int count) {
    string base_links = ::query_inventory_links(count);
    string new_link = equiped ? "[脱下:unwear ...]" : "[穿戴:wear ...]";

    // 如果已经有相同类型的链接，就不添加了
    if(search(base_links, new_link) >= 0) {
        return base_links;
    }
    return base_links + new_link;
}
```

**影响的文件：**
- `/usr/local/games/lowlib/wapmud2/inherit/armor.pike` - 防具
- `/usr/local/games/lowlib/wapmud2/inherit/weapon.pike` - 武器
- `/usr/local/games/lowlib/wapmud2/inherit/jewelry.pike` - 首饰
- `/usr/local/games/lowlib/wapmud2/inherit/decorate.pike` - 饰物

## 相关功能

### 错误日志增强

修改 `/usr/local/games/lowlib/driver.pike`，让编译错误同时写入 `error.13800`：

```pike
void compile_error(string file, int line, string msg)
{
    string timestamp = String.trim_all_whites(ctime(time()));
    string error_msg = sprintf("-----%s-----\nCOMPILE ERROR: %s:%d: %s\n", timestamp, file, line, msg);
    werror("%s:%d: %s\n", file, line, msg);
    debug_log->write("%s:%d: %s\n", file, line, msg);
    log->write(error_msg);  // 同时写入主错误日志
}
```

### 手动存档功能

创建 `/usr/local/games/xiand/gamelib/cmds/save_game.pike` 命令，允许玩家手动保存进度而不退出游戏。

### VIP飞行费用配置

在 `/usr/local/games/xiand/gamelib/single/daemons/mapd.pike` 中添加可配置的VIP飞行费用：

```pike
private mapping(int:int) vip_fly_fee_config = ([
    0: 0,        // 非会员：按等级计算
    1: 200000,   // 水晶会员：20万 (2000金)
    2: 100000,   // 黄金会员：10万 (1000金)
    3: 50000,    // 白金会员：5万 (500金)
    4: 5000,     // 钻石会员：5千 (50金)
]);
```

## 安全性评估

- **极低风险**：使用 `catch` 保护，任何错误都会安全回退
- **无性能影响**：无重复时只做一次 `search()` 检查
- **向后兼容**：不改变函数签名和返回值格式
- **防御性编程**：双重保护（基础类+子类检查）

## 使用场景

当用户提到以下问题时，触发此技能：
- "装备按钮重复"
- "脱下按钮很多"
- "穿戴无限循环"
- "inventory_links 累积"
- "档案文件太大"
- "compile_error 记录"
