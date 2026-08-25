<div align="center">
  <h1>🔥 FanExtreme — 更好的红魔</h1>
</div>

<div align="center">
  <a href="https://github.com/ling9ling7/RedMagic-FanExtreme/releases/latest"><img src="https://img.shields.io/github/v/release/ling9ling7/RedMagic-FanExtreme?style=flat-square&cacheSeconds=3600" alt="GitHub Release"></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Custom-red?style=flat-square" alt="License"></a><a href="https://github.com/ling9ling7/RedMagic-FanExtreme/stargazers"><img src="https://img.shields.io/github/stars/ling9ling7/RedMagic-FanExtreme?style=flat-square" alt="Stars"></a><img src="https://img.shields.io/github/downloads/ling9ling7/RedMagic-FanExtreme/total.svg?style=flat-square" alt="Downloads">
</div>

<div align="center">
红魔手机 KernelSU 模块 · 多合一性能优化 · WebUI 可视化控制面板 · 在线更新
</div>

> 为红魔手机而生：风扇极速、充电分离、云控屏蔽、温控移除、振动增强、触控优化、充电加速等，一站式解决性能调校。
<table>
  <tr>
    <td><img width="350" alt="前端展示" src="https://github.com/user-attachments/assets/990ab9a2-f490-4c4c-8cf9-f6a1cf6e4056" /></td>
    <td><img width="350" alt="前端展示2" src="https://github.com/user-attachments/assets/f0a6dd4e-030d-4741-b83a-b01f3727a85b" /></td>
  </tr>
</table>

## ✨ 为什么选择 FanExtreme？

其他模块单独一项功能就一个模块，装多了互相冲突。**FanExtreme 一个模块搞定多个功能**，内置 WebUI 控制面板，开关随心，新手也能用。

- 🎛️ **WebUI 控制面板** — 模块列表直接进入，实时电量/温度/功率监控，充电分离与风扇极速开关自如
- 🔌 **在线更新** — 模块列表内一键检测新版本，不用手动下载 ZIP
- 📋 **调试日志** — 一键生成系统运行状态日志，快速定位问题
- 💬 **社区支持** — 内置 QQ 群入口，问题反馈即时

## 🚀 功能一览

| 功能 | 说明 |
|------|------|
| 💧 液冷控制 | 支持红魔11 Pro 内置液冷水泵四档调速，按需主动降温 |
| 🌀 风扇极速 | 开机自动满速锁死，WebUI 支持 1-5 级挡位切换 |
| ⚡ 充电分离 | 电量达到设定阈值自动启用，USB 直接供电不伤电池 |
| ☁️ 云控屏蔽 | 解锁→清空→锁定 cube 云控目录，杜绝远程下发频率限制 |
| 🔥 温控移除 | 所有温度墙拉到 95°C，满血释放 |
| 📳 振动增强 | 自定义 AW8697 线性马达增益 / 时长 / 电压上限 |
| 👆 触控优化 | 提高采样率 + 游戏模式 + 跟手度 4 级 + 熄屏守护 + 960Hz 系统层 + 60 秒守护防回退 |
| 🔋 充电加速 | 解除部分情况下的充电电流限制 |
| 📈 频率控制 | 自定义CPU和GPU的频率，同时提供了一个省电预设 |
| 💡 亮度解锁 | 红魔11Pro系列可激发最大屏幕亮度 |

## 📲 安装

1. 下载 [最新 Release](https://github.com/ling9ling7/RedMagic-FanExtreme/releases/latest)
2. KernelSU Manager → 模块 → 从存储安装
3. 重启生效

## ⚙️ 配置

模块目录下的 `config.txt`（重启生效）：

```
0=关闭 1=启用
风扇极速=1
充电分离=1
充电分离阈值=100
云控屏蔽=1
温控移除=1
振动增强=1
振动增益=168
振动时长=18ms
振动上限=128
触控优化=1
充电加速=1
亮度解锁=1
```

WebUI 中可实时开关功能、调整风扇挡位和充电分离阈值。

## 📖 项目结构
```
FanExtreme/
│
├── module.prop            # 模块元数据
├── customize.sh           # 安装时执行
├── service.sh             # 主守护进程
├── config.txt             # 配置文件
├── update.json            # 在线更新描述
│
├── lib/                   # 功能库
│   ├── common.sh          # cfg() 读 config.txt 配置
│   ├── features.sh        # 各功能开关实现
│   ├── status.sh          # 生成 WebUI 状态 JSON
│   ├── perf.sh            # CPU/GPU 频率与锁频控制
│   └── loop.sh            # WebUI 命令循环
│
├── webroot/               # WebUI 控制面板
│   ├── index.html         # 页面骨架
│   ├── style.css          # 样式
│   ├── app.js             # 前端逻辑
│   ├── avatar.png         # 页面头像
│   ├── sponsor.jpg        # 赞助图
│   └── xmtx.png           # 社区贡献者头像
│
└── vendor/etc/
    └── thermal-engine.conf   # 温控引擎配置
```

## 🛠️ 开发环境
- 模块本体纯 shell (system/bin/sh) + JS/CSS，无需编译
- 测试设备红魔 9 Pro (NX769J, Android 16, KernelSU)
- 打包 ZIP 直接压缩模块根目录即可

## ❓ 常见问题

**Q: 为什么安装模块后过一会模块会自己消失？**  
A: 模块已在 2026年8月7日（v3.1.5版本）开始正式转变为仅赞助用户可安装使用，非授权机型模块会自动卸载，可联系作者了解赞助授权相关信息。

**Q: 控制面板（WebUI）入口在哪？**  
A: KernelSU Manager → 模块 → 找到「更好的红魔」→ 点击「控制面板」。

**Q: 我是 Magisk 用户，模块列表里没有「控制面板」按钮怎么办？**  
A: Magisk 暂不支持 WebUI 功能。你可以：① 换用 KernelSU 管理器；② 安装独立的 WebUI 管理软件（如 MMRL、KsuWebUI等）。模块其他功能不受影响。

**Q: 我不是 KernelSU 用户，也能使用吗？**  
A: 可以。FanExtreme 兼容 KernelSU、KernelSU Next、APatch、Magisk（部分版本）。但 WebUI 控制面板目前仅 KernelSU 系列管理器支持。Magisk 用户功能正常生效，只是没有控制面板界面。

**Q：红魔原生就支持充电分离为什么模块还要做这个功能？**
A：红魔原生充电分离的电量触发值范围为 20-90 并不能设置90以上的电量触发分离，模块则完美解决这个问题。

**Q: 装了模块后游戏掉帧？**  
A: 模块本身不会导致掉帧。如果遇到问题，请用控制面板的「调试日志」功能导出日志反馈。

**Q: 充电分离为什么没有触发？**  
A: 请确认：① config.txt 中 `充电分离=1` 并重启；② WebUI 中充电分离开关已开启；③ 手机正在充电；④ 电量达到了设定的阈值。

## 📱 兼容性

理论支持全版本红魔机型

| 机型 | Android | 适配情况 |
|------|---------|---------|
| 红魔 8 Pro | 15 | 完美适配✅ |
| 红魔 9 Pro | 16 | 完美适配✅ |
| 红魔 10 Pro | 16 | 完美适配✅ |
| 红魔 11 Pro | 16 | 完美适配✅ |
| 红魔电竞平板 Pro | 16 | 完美适配✅ |
| 红魔电竞平板 3 Pro | 16 | 完美适配✅ |
| 红魔电竞平板 5 Pro | 16 | 完美适配✅ |

## 💬 反馈 & 社区

- [酷安 @ling_凌](https://www.coolapk.com/)
- [QQ 群 777533513](https://qm.qq.com/q/QCBSaor22k)
- [TG频道](https://t.me/FanExtreme)
- 控制面板内置调试日志，遇到问题一键导出反馈

## 📄 License

Custom License © 酷安@ling_凌

本模块**保留所有权利**，采用白名单设备授权机制。源码公开供学习/审查/个人调试，未经授权不得安装运行于设备（白名单外使用需购买商业授权），禁止商用与二次公开分发。

---
## ⚠️ 新闻

> ⚠️ **2026年6月14日：FanExtreme 正式停止更新** 因个人原因，我的心理问题导致我没精力继续更新下去，在未来可能时不时的发布新的版本，况且现在模块功能已趋近完备，可做的都做了。如果你有兴趣可以继续维护这个项目，欢迎 Fork

> ⚠️ **2026年7月26日：FanExtreme 恢复更新** 在熬过一个艰难的时期后，我有精力继续维护这个项目，在未来项目会继续保持更新，感谢大家的支持与陪伴

>  ⚠️ **2026年8月7日：FanExtreme 仅赞助用户可用** 自首次发布以来模块已经经过了20以上的版本迭代，随着模块体量的增加，模块的维护与更新成本也在上升。最终在与模块用户的讨论中决定，FanExtreme-更好的红魔 从v3.1.5版本开始正式实施仅赞助用户可安装使用，低于v3.1.5的版本仍然保持开源免费使用，但不再对其版本进行维护。如有用户想继续更新和使用最新版本，赞助模块 15R 支持开发后联系开发者即可永久使用此模块
