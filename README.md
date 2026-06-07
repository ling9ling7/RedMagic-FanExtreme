# 🔥 FanExtreme — 更好的红魔

[![GitHub Release](https://img.shields.io/github/v/release/ling9ling7/RedMagic-FanExtreme?style=flat-square)](https://github.com/ling9ling7/RedMagic-FanExtreme/releases/latest)
[![License](https://img.shields.io/github/license/ling9ling7/RedMagic-FanExtreme?style=flat-square)](LICENSE)
[![Stars](https://img.shields.io/github/stars/ling9ling7/RedMagic-FanExtreme?style=flat-square)](https://github.com/ling9ling7/RedMagic-FanExtreme/stargazers)

红魔手机 KernelSU 模块 · 八合一性能优化 · WebUI 可视化控制面板 · 在线更新

> 为红魔手机而生：风扇极速、充电分离、云控屏蔽、温控移除、振动增强、触控优化、充电加速，一站式解决性能调校。

## ✨ 为什么选择 FanExtreme？

其他模块单独一项功能就一个模块，装多了互相冲突。**FanExtreme 一个模块搞定全部八项**，内置 WebUI 控制面板，开关随心，新手也能用。

- 🎛️ **WebUI 控制面板** — 模块列表直接进入，实时电量/温度/功率监控，充电分离与风扇极速开关自如
- 🔌 **在线更新** — 模块列表内一键检测新版本，不用手动下载 ZIP
- 📋 **调试日志** — 一键生成系统运行状态日志，快速定位问题
- 💬 **社区支持** — 内置 QQ 群入口，问题反馈即时

## 🚀 功能一览

| 功能 | 说明 |
|------|------|
| 🎛️ WebUI 控制面板 | 模块列表进入，实时充电监控 + 风扇挡位调节 + 调试日志 + QQ 群 |
| 🌀 风扇极速 | 开机自动满速锁死，WebUI 支持 1-5 级挡位切换 |
| ⚡ 充电分离 | 电量达到设定阈值自动启用，USB 直接供电不伤电池 |
| ☁️ 云控屏蔽 | 解锁→清空→锁定 cube 云控目录，杜绝远程下发频率限制 |
| 🔥 温控移除 | 所有温度墙拉到 95°C，满血释放 |
| 📳 振动增强 | 自定义 AW8697 线性马达增益 / 时长 / 电压上限 |
| 👆 触控优化 | 提高采样率 + 游戏模式 + 跟手度 4 级 + 熄屏守护 + 960Hz 系统层 + 60 秒守护防回退 |
| 🔋 充电加速 | 解除部分情况下的充电电流限制 |

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
振动增益=168%%
振动时长=18ms
振动上限=128
触控优化=1
充电加速=1
```

WebUI 中可实时开关功能、调整风扇挡位和充电分离阈值。

## 📱 兼容性

理论支持全版本红魔机型。

| 机型 | 主控 | Android | 测试状态 |
|------|------|---------|---------|
| NX769J (红魔 9 Pro) | SM8650 | 16 | ✅ 主力测试 |
| 其他红魔机型 | — | — | ⏳ 待用户反馈 |

## 💬 反馈 & 社区

- [酷安 @ling_凌](https://www.coolapk.com/)
- [QQ 群 777533513](https://qm.qq.com/q/QCBSaor22k)
- 控制面板内置调试日志，遇到问题一键导出反馈

## 📄 License

MIT © 酷安@ling_凌
