# VIP Level Limit Toggle

This skill should be used when working with VIP level restrictions in the game. Use this when the user asks about "VIP限制", "会员等级", "level limit", or discusses toggling VIP-based gameplay restrictions. Covers the VIP_KILL_LIMIT toggle in globals.h and its usage in kill commands. (user)

## Overview

The game has a global toggle `VIP_KILL_LIMIT` that controls whether VIP level restrictions are enforced for combat-related commands. When disabled (default 0), all players can fight and quick-battle regardless of level.

## Location

**Global Toggle Definition:**
- File: `/usr/local/games/xiand/lowlib/system/include/globals.h`
- Line: ~72
- Definition: `#define VIP_KILL_LIMIT 0`

**Usage Locations:**
- `/usr/local/games/xiand/lowlib/wapmud2/cmds/kill.pike` - Normal attack command
- `/usr/local/games/xiand/lowlib/wapmud2/cmds/kill_quick.pike` - Quick battle command

## How to Use

### To Disable Restrictions (Current Default)
```pike
// In globals.h
#define VIP_KILL_LIMIT 0
```
All players can attack and quick-battle without VIP restrictions.

### To Enable Restrictions
```pike
// In globals.h
#define VIP_KILL_LIMIT 1
```
VIP level restrictions are enforced:
- Level >= 10 and < 50: Requires 水晶会员 (VIP flag >= 1)
- Level >= 50 and < 61: Requires 黄金会员 (VIP flag >= 2)
- Level >= 61 and < 100: Requires 白金会员 (VIP flag >= 3)
- Level >= 100: Requires 钻石会员 (VIP flag >= 4)

## Implementation Pattern

When adding new commands that need VIP toggling:

1. Add the toggle in globals.h (already done)
2. In your command file, wrap VIP checks with:

```pike
#include <command.h>
#include <wapmud2/include/wapmud2.h>

int main(string arg)
{
	object me = this_player();

	if(VIP_KILL_LIMIT){
		// VIP restriction logic here
		if(me->query_level()>=50 && !me->query_vip_flag()){
			tell_object(me, "需要会员才能继续游戏\n");
			return 1;
		}
	} // VIP_KILL_LIMIT

	// Normal command logic continues...
}
```

## VIP Levels Reference

| Level Range | Required VIP | VIP Flag Value |
|-------------|--------------|----------------|
| >= 10 && < 50 | 水晶会员 | >= 1 |
| >= 50 && < 61 | 黄金会员 | >= 2 |
| >= 61 && < 100 | 白金会员 | >= 3 |
| >= 100 | 钻石会员 | >= 4 |

## Related Files

- `lowlib/wapmud2/cmds/kill.pike` - Normal attack VIP check
- `lowlib/wapmud2/cmds/kill_quick.pike` - Quick battle VIP check
- `lowlib/system/include/globals.h` - Global toggle definition
- `gamelib/single/daemons/szxvipd.pike` - VIP daemon for VIP flag management
