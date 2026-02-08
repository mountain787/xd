# xiand Vue界面样式调整技能

## 技能描述
用于调整xiand（仙岛）MUD游戏的Vue前端界面样式，包括按钮大小、布局位置、文字大小等。

## 使用场景
当用户反馈游戏界面按钮太小、布局不合理、需要调整主游戏区域样式时使用此技能。

## 主要修改文件
- `vue_source/css/app.css` - 前端样式源文件
- `restart.sh` - 重启脚本（添加自动构建功能）
- `gamelib/d/init` - 修复sid字段undefined问题

## 样式配置参考

### 按钮样式 (.mud-btn)
```css
.mud-btn {
    padding: 10px 20px;      /* 按钮内边距 */
    font-size: 16px;         /* 字体大小 */
    border-radius: 7px;      /* 圆角 */
}
```

### 游戏主区域布局 (.mud-child)
```css
.mud-child {
    width: 100%;             /* 宽度100% */
    max-width: none;         /* 无最大宽度限制 */
    text-align: left;        /* 左对齐 */
    padding-left: 18%;       /* 左移18% */
}
```

### 文字样式 (.mud-text)
```css
.mud-text {
    font-size: 18px;         /* 字体大小 */
}
```

## 自动构建
每次修改 `vue_source/css/app.css` 后需要构建：
```bash
cd vue_source && npm run build
```

或者使用 restart.sh 会自动构建前端。

## 常见问题

### 修改样式后没生效？
需要重新构建：`cd vue_source && npm run build`

### 按钮太小或太大
调整 `.mud-btn` 的 padding 和 font-size

### 内容区域太窄
调整 `.mud-child` 的 width 和 padding-left

### 文字太小
调整 `.mud-text` 的 font-size

## 修改历史
- 2025-02-08: 初始版本，按钮缩小、布局调整、sid修复
