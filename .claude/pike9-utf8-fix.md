# Pike 9 UTF-8 编码修复技能

## 概述
用于修复 Pike 源代码文件中的中文乱码问题（UTF-8 被错误解释导致）。

## 常见乱码模式

### 基础乱码字符映射
| 乱码 | 正确中文 |
|------|----------|
| 杩斿洖 | 返回 |
| 娓告垙 | 游戏 |
| 鍒犻櫎 | 删除 |
| 鎴愬姛 | 成功 |
| 澶辫触 | 失败 |
| 鐜夌煴 | 钻灵 |
| 浠欑帀 | 灵玉 |
| 鐜╁ | 玩家 |
| 鎵嬪 | 手机 |
| 鐢ㄦ埛 | 用户 |
| 鎮ㄦ | 您的 |
| 纭 | 确认 |
| 鐧婚檰 | 登录 |
| 娉ㄥ唽 | 注册 |
| 璐ｆ暜 | 解散 |
| 鍛樺椂 | 团队 |
| 搴楃摱 | 银行 |
| 鎹愯禒 | 挑战 |
| 璇存槑 | 说明 |
| 跺拱 | 购买 |

### 常见短语映射
| 乱码 | 正确中文 |
|------|----------|
| 浣犺繕娌℃湁鍦颁骇锛岀┖鎵嬪鐧界嫾鍦ㄨ繖閲屽彲琛屼笉閫€ | 你还没有房产，空手白拼在这里可行不通 |
| 鍒犻櫎鍏虫敞淇℃伅澶辫触锛岃閲嶈瘯銆 | 删除关注信息失败，请重试。 |
| 鎴愬姛鍒犻櫎璇ラ偖浠讹紝璇疯繑鍥烒n | 成功删除该邮件，请返回！\n |
| 鎮ㄨ緭鍏ョ殑缁勫悕涓嶆纭紝璇烽噸鏂拌緭鍏ワ細 | 您输入的组名不正确，请重新输入： |
| 鐜夌煴鐜╁鎿嶄綔鎺ュ彛 | 钻灵玩家操作接口 |
| 鎹愯禒鑾峰彇浠欑帀璇存槑锛 | 挑战获取灵玉说明： |
| 鐢ㄦ埛鎹愯禒50鍏冿紝鍗冲彲鑾峰緱5棰楃崉鐠庢暀 | 用户挑战50元，即可获得5艘天灵玉 |
| 鎹愯禒鑱旂粰qq: | 挑战联络qq: |

## 修复方法

### 方法1: 使用转换脚本
```bash
# 扫描并显示需要转换的文件（不修改）
./bin/cmd_convert_to_utf8.py -n gamelib/cmds

# 实际转换文件
./bin/cmd_convert_to_utf8.py gamelib/cmds

# 转换单个文件
./bin/cmd_convert_to_utf8.py gamelib/cmds/test.pike
```

### 方法2: 手动替换
使用 Python 脚本进行批量替换：
```python
import os

mapping = {
    "杩斿洖娓告垙": "返回游戏",
    "杩斿洖": "返回",
    "娓告垙": "游戏",
    # ... 更多映射
}

for filepath in glob.glob("gamelib/cmds/*.pike"):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    for bad, good in mapping.items():
        content = content.replace(bad, good)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
```

## 已修复的文件列表

### gamelib/cmds/
- add_else_fee.pike
- home_functionroom_buy_list.pike
- home_functionroom_remind.pike
- home_get_pass_time_item.pike
- home_purchase_flat_list.pike
- home_purchase_home_list.pike
- home_query_area_desc.pike
- home_sell_remind.pike
- home_shop_service_center.pike
- home_view.pike
- home_visit.pike
- item_ungroup_confirm.pike
- mailbox.pike
- mailbox_delete.pike
- msg_del.pike
- my_term.pike
- paihang_update_account_toplist.pike
- paihang_update_mark_toplist.pike
- qqlist_admin_new.pike
- qqlist_move.pike
- relife.pike
- spec_learn.pike
- spy_del_confirm.pike
- term_release.pike
- toolbar_cancel.pike
- vendue_cancel.pike
- viceskill_peifang_view.pike
- view_equip.pike
- vip_service_list.pike
- wiz_goto.pike
- yblh_buy_detail.pike
- yblh_buy_confirm.pike
- yushi_buy_hlbook_detail.pike
- yushi_do_else.pike
- yushi_get_test.pike
- yushi_readme.pike
- chatroom_block.pike
- chatroom_list.pike
- home_life_cancel_submit.pike
- home_life_replace_submit.pike

### lowlib/
- system/cmds/charerror.pike
- system/cmds/login_check_intro.pike
- wapmud2/cmds/checkitem.pike

## 检测乱码的命令

```bash
# 查找包含乱码的文件
grep -r "杩斿洖\|娓告垙\|鐜夌煴\|浠欑帀" gamelib/cmds/

# 使用脚本检查
./bin/cmd_convert_to_utf8.py -n gamelib/cmds
```

## 相关 Commit
- `1d57aaf2b` - Fix UTF-8 encoding in command files (35 files)
- `a4f6070fa` - Complete UTF-8 encoding fix for yushi_readme.pike
- `151b944a4` - Fix UTF-8 encoding for remaining command files (18 files)
- `c182f65b6` - Add UTF-8 encoding conversion script
