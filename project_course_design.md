---
name: project-course-design
description: 移动通信课程设计 — VHF OFDM 系统 MATLAB 仿真，第2组，逐步搭建中
metadata:
  type: project
  originSessionId: 50fe77a9-7712-4d46-9e97-1ff0bb501b6f
---

# 移动通信课程设计 — VHF 无线通信系统

## 当前状态 (2026-05-24)

**当前电脑**: QIANJUNYANG（另一台 Lenovo1 有旧代码）
**MATLAB 路径**: `E:\MATLAB\R2024b\bin`
**项目路径**: `C:\Users\Qianjunyang\Desktop\vhf_ofdm\`

## 系统条件（第2组 — VHF）

| 参数 | 值 |
|------|-----|
| 信号带宽 | 1 MHz |
| 载频 | 100 MHz |
| 晶振稳定度 | 0.1 ppm |
| 信道条件 | 军用车载移动信道 |
| 移动速度 | 60 km/h |
| 多径（5径） | 相对时延 [0, 0.2, 0.5, 1.0, 2.0] μs，相对功率 [0, -3, -6, -9, -12] dB |

## OFDM 参数（已选定）

| 参数 | 值 | 理由 |
|------|------|------|
| FFT 点数 N_fft | 512 | 符号 512 μs，CP 开销合理 |
| 有效子载波 | 400 | ~80 保护带，~32 导频 |
| 子载波间隔 Δf | 1.95 kHz | ≫ 多普勒 5.6 Hz |
| CP 长度 | 8 μs (8 样本) | 覆盖 2 μs 时延 |
| 符号总长 | 520 μs | 512 + 8 |
| 每符号数据 bit | 368~736 | 取决于调制阶数 |

## 发射端已实现模块

| # | 模块 | 文件 | 参数 |
|---|------|------|------|
| 1 | 信源 | `generate_source.m` | 10^6 bit, uniform random |
| 2 | CRC-16 | `crc16_encode.m` | CRC-16-CCITT (0x1021), 1024 data + 16 CRC /帧 |
| 3 | 信道编码 | `channel_encode.m` | 卷积码 K=7 R=1/2 [171,133] |
| 4 | 交织 | `interleave.m` / `deinterleave.m` | 随机交织 (固定种子 rng(42)), 跨帧全排列 |
| 5 | 符号调制 | `modulate.m` / `demodulate.m` | QPSK / 16QAM / 64QAM (整数方式, 避免 bit 对齐问题) |

## 测试与可视化

- `test_all.m` — 总测试脚本，`%%` 分节，支持逐节调试 (Ctrl+Enter)
- `visualize_pipeline.m` — 6 个独立窗口可视化每个环节的 bit 变换
- 全局参数区可切换调制方式 (`mod_type = 'QPSK'|'16QAM'|'64QAM'`)
- 所有 fprintf 输出使用英文，避免 MATLAB 控制台中文乱码

## 待实现模块

| # | 模块 |
|---|------|
| 6 | 导频插入 / 成帧 |
| 7 | OFDM 调制 (IFFT + CP) |
| 8 | 信道模型 (VHF 多径 + 多普勒) |
| 9 | 接收端: 下变频 + 时间同步 + 频率同步 |
| 10 | 信道估计与插值 |
| 11 | MIMO 均衡与检测 |
| 12 | 解调 → 解交织 → 译码 → CRC 校验 |
| 13 | BER 统计与分析 |
| 14 | GUI 封装 |

## 关键技术决策记录

- **CRC 选 16 而非 32**: 后续有卷积码兜底，CRC-16 是通信标配
- **卷积码而非 Turbo/LDPC**: 实现简单，MATLAB 自带函数，课程设计重点在同步和信道估计
- **随机交织而非块交织**: 相干带宽 400 kHz 涵盖 200 子载波，块交织频域打散不够
- **调制用 bi2de/de2bi 而非 qammod 'bit' 模式**: 'bit' 模式在 2D/1D 矩阵间转换有对齐陷阱，整数方式更可靠
- **多普勒 5.6 Hz 很小**: Δf=1.95 kHz ≫ fd，ICI 可忽略

## 历史

- 快速原型: `C:\Users\Lenovo1\Desktop\vhf_ofdm_system\` (15 个 .m 文件, 含 GUI, 有 bug)
- 2026-05-24 决定从基础重新逐步搭建
