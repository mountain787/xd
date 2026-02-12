# URL书签登录功能 (Bookmark Login)

## 概述

允许用户通过URL中的`txd`参数实现跨设备、跨浏览器自动登录。用户可以复制URL分享或收藏，下次直接打开即可自动登录，无需重新输入账号密码。

## 实现日期

2026-02-12 (commit: a50c24dfc3)

## 功能特性

1. **URL参数登录**: 访问 `?txd=xxx` 的URL自动登录
2. **登录后更新URL**: 登录成功后URL自动包含txd参数
3. **复制链接功能**: 菜单中"🔗 复制登录链接"方便分享
4. **跨设备使用**: 复制URL到其他浏览器/设备直接登录

## 文件修改位置

### 前端源文件

1. **`vue_source/js/app.js`**
   - `mounted()`: 读取URL中的`txd`参数（优先于sessionStorage）
   - `updateUrlWithTxd()`: 更新URL包含txd参数
   - `copyBookmarkUrl()`: 复制登录链接到剪贴板
   - `showNotification()`: 显示复制成功提示
   - `sendJsonCommand()`: 从API响应保存userid到sessionStorage

2. **`vue_source/index.html`**
   - 添加"🔗 复制登录链接"菜单项

3. **`vue_source/css/app.css`**
   - 字体大小放大50%: `--font-base: 12px → 18px`
   - 添加 `fadeOut` 动画

### 编译后文件

4. **`web/web_vue/js/app.js`**: 同上（编译生成）
5. **`web/web_vue/index.html`**: 同上（编译生成）
6. **`web/web_vue/css/app.css`**: 同上（编译生成）

## 实现细节

### 1. URL参数读取 (mounted函数)

```javascript
const urlParams = new URLSearchParams(window.location.search);
const txdParam = urlParams.get('txd');
let txdFromUrl = false;

if (txdParam) {
    savedTxd = txdParam;
    txdFromUrl = true;
}
```

### 2. 自动登录条件

```javascript
// 有txd且（来自URL 或 有保存的用户信息）
if (savedTxd && (txdFromUrl || savedUser)) {
    this.txd = savedTxd;
    // ... 自动登录
}
```

### 3. URL更新

```javascript
updateUrlWithTxd() {
    const url = new URL(window.location.href);
    url.searchParams.set('txd', this.txd);
    window.history.replaceState({}, '', url.toString());
}
```

### 4. 用户信息保存

从API响应中提取并保存用户信息：

```javascript
if (data.userid && !sessionStorage.getItem('mud_userid')) {
    const partitionMatch = data.userid.match(/^([a-z]+\d+)/);
    if (partitionMatch) {
        const partition = partitionMatch[1];
        const userid = data.userid.substring(partition.length);
        sessionStorage.setItem('mud_partition', partition);
        sessionStorage.setItem('mud_userid', userid);
    }
}
```

## TXD编码格式

`encodeTxd()` 函数生成txd字符串：

```
userid编码 + "~" + password编码
```

编码规则：
- userid: 偶数位字符+2，奇数位字符+1（y→%7B, z→%7B）
- password: 偶数位字符+1，奇数位字符+2（y→%7B, z→%7C, z→%7C）

## 使用方式

### 用户操作流程

1. **正常登录**: 输入账号密码登录
2. **URL更新**: 登录后地址栏自动变为 `?txd=xxx`
3. **复制分享**:
   - 直接复制地址栏URL
   - 或点击菜单"🔗 复制登录链接"
4. **跨设备使用**: 在其他浏览器/设备粘贴URL打开即可自动登录

### 测试方法

1. 浏览器A登录游戏
2. 复制地址栏URL（包含`?txd=xxx`）
3. 浏览器B（隐私模式）打开URL
4. 应该直接自动登录，无需输入账号密码

## 相关Git提交

```
a50c24dfc3 fix(web): enable auto-login from URL txd parameter
572f23d9a5 feat(web): increase font size by 50% and fix URL update
8ac03bda3f feat(web): add URL-based auto-login for cross-browser support
```

## 后端支持

后端已支持`txd`参数，无需修改。

HTTP API: `gamelib/single/daemons/_http_api_mod/auth.pike`
- `decode_txd(txd)`: 解码txd获取userid和password
