---
name: project-course-design
description: 移动通信课程设计 — VHF OFDM 系统 MATLAB 仿真，第2组，逐步搭建中
metadata:
  type: project
  originSessionId: 50fe77a9-7712-4d46-9e97-1ff0bb501b6f
---

# 移动通信课程设计 — VHF 无线通信系统

## 当前状态 (2026-05-27)

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
| 有效子载波 | 400 | DC(1)+左保护带(55)+右保护带(55)+Nyquist(1)=112 空 |
| 子载波间隔 Δf | 1.95 kHz | ≫ 多普勒 5.6 Hz |
| CP 长度 | 8 μs (8 样本) | 覆盖 2 μs 时延 + 同步余量 |
| 符号总长 | 520 μs | 512 + 8 |
| 每 OFDM 符号数据 bit | 800~2400 | QPSK:800 / 16QAM:1600 / 64QAM:2400 |
| 帧结构 | 训练+导频+数据 | 块状导频, 训练序列用于时间/频率同步 |

## 发射端已实现模块

| # | 模块 | 文件 | 参数 |
|---|------|------|------|
| 1 | 信源 | `generate_source.m` | 10^4 bit, uniform random |
| 2 | CRC-16 | `crc16_encode.m` | CRC-16-CCITT (0x1021), 1024 data + 16 CRC /帧 |
| 3 | 信道编码 | `channel_encode.m` | 卷积码 K=7 R=1/2 [171,133] |
| 4 | 交织 | `interleave.m` / `deinterleave.m` | 随机交织 (固定种子 rng(42)), 跨帧全排列 |
| 5 | 符号调制 | `modulate.m` / `demodulate.m` | QPSK / 16QAM / 64QAM |
| 6 | OFDM 调制 | `ofdm_config.m` / `ofdm_tx_symbol.m` / `ofdm_assemble_frame.m` | 512 FFT, CP=8, DC+保护带(55+55), 块状导频, PN 训练序列 |
| 7 | 信道模型 | `vhf_channel.m` / `rayleigh_fading.m` | 5径 [0,0.2,0.5,1.0,2.0]μs, fd=5.56Hz, 分数延迟(interp1), 滤波高斯噪声 Doppler 谱 |
| 8 | 接收同步 | `ofdm_time_sync.m` / `ofdm_freq_sync.m` | 互相关时间同步 + CP 相位差频偏估计(多符号平均) |
| 9 | AWGN 噪声 | `add_awgn.m` | 给定 SNR(dB) 添加复高斯白噪声, 模拟接收机热噪声 |

## 可视化窗口

| 窗口 | 内容 |
|------|------|
| figure(1) | 5 行 stem — bit 流水线: 蓝(信源)→蓝+红(CRC追加)→绿+红burst(编码)→绿+红散点(交织)→绿+红恢复(解交织) |
| figure(2) | 2 行 — 功率延迟谱 + 收发信号包络对比 |
| figure(3) | 2 行 stem — QPSK/16QAM/64QAM 的 I/Q 分量 |
| figure(4) | 2 行 — OFDM 时域(光滑曲线,CP红+IFFT蓝) + 频域子载波数据 |
| figure(5) | **3 行** — 时间同步相关峰 + **频偏纠正前各符号CP-Tail相位差(红)** + **频偏纠正后各符号CP-Tail相位差(蓝)** |
| figure(6) | 2 行 — 复基带频谱(0Hz居中) + 搬移到100MHz载波的等效通带频谱 |
| figure(7) | 柱状图 — BER/FER 结果 |
| figure(8) | 2 行 semilogy — BER vs SNR + FER vs SNR (ZF vs MMSE 对比) |
| figure(9) | 2×2 — 均衡前星座图 + ZF均衡星座图 + MMSE均衡星座图 + 信道频响(幅值+相位) |

- 全局参数区可切换调制方式 (`mod_type = 'QPSK'|'16QAM'|'64QAM'`)
- 全局参数 `cfo_hz = 10` 控制 CFO 注入 (0=关闭, 模拟 0.1ppm@100MHz)
- 所有 fprintf 输出使用英文，避免 MATLAB 控制台中文乱码

## 待实现模块

| # | 模块 |
|---|------|
| 16 | MIMO 扩展 (2×2, 正交导频 LS) |
| 17 | GUI 封装 |

## 接收端已实现模块

| # | 模块 | 文件 | 参数 |
|---|------|------|------|
| 1 | 时间同步 | `ofdm_time_sync.m` | 互相关, PN训练序列(rng=7) |
| 2 | 频率同步 | `ofdm_freq_sync.m` | CP相位差, 多符号平均 |
| 3 | MMSE信道估计 | `channel_estimate_mmse.m` | LS初估→MMSE平滑, R_HH from PDP, σ² from guard band |
| 4 | OFDM解调 | `ofdm_rx_demod.m` | 去CP→512 FFT→提取400有效子载波 |
| 5 | ZF均衡 | `channel_equalize.m` | 逐子载波除法, 可选MMSE |
| 6 | 符号解调 | `demodulate.m` | QPSK/16QAM/64QAM 硬判决 |
| 7 | 解交织 | `deinterleave.m` | 随机解交织(同一perm) |
| 8 | Viterbi译码 | `channel_decode.m` | K=7 R=1/2 [171,133], tblen=35 |
| 9 | CRC校验+BER | `crc16_check.m` | 逐帧CRC-16验证, BER/FER统计 |
| 10 | SNR-BER曲线 | `run_ber_curve.m` | 遍历 SNR 0:2:25 dB, ZF vs MMSE 均衡对比, BER/FER 曲线 + 星座图 |

## 关键技术决策记录

- **CRC 选 16 而非 32**: 后续有卷积码兜底，CRC-16 是通信标配
- **卷积码而非 Turbo/LDPC**: 实现简单，MATLAB 自带函数，课程设计重点在同步和信道估计
- **随机交织而非块交织**: 相干带宽 400 kHz 涵盖 200 子载波，块交织频域打散不够
- **调制用 bi2de/de2bi 而非 qammod 'bit' 模式**: 'bit' 模式在 2D/1D 矩阵间转换有对齐陷阱，整数方式更可靠
- **多普勒 5.6 Hz 很小**: Δf=1.95 kHz ≫ fd，ICI 可忽略
- **时间同步用互相关**: 本地重建训练符号(PN序列,rng=7)与接收信号做 xcorr，峰值定位帧起点
- **频率同步用 CP 相位差, 跳过多径ISI污染样本**: 多径最大时延 2μs 污染 CP 前 2 样本，跳过(cp_skip=2) 只用干净 6 样本做 angle(Σ tail·cp*)/(2π·N_fft/fs)
- **CFO 注入模拟晶振偏差**: 全局参数 cfo_hz=10Hz (0.1ppm@100MHz)，信道输出后注入 exp(j2π·cfo·t)，频率同步模块再估计并纠正
- **信道估计用 MMSE 而非 LS**: 军用需抗干扰，利用已知 PDP 构建频域相关矩阵 R_HH，从保护带估计 σ²，MMSE 抑制噪声
- **均衡用 ZF**: 逐子载波除法，均衡模块支持切换到 MMSE（需传入 σ²）
- **PPT 汇报文件**: `汇报_VHF_OFDM_系统设计.pptx` (**19 页, 浅色调 + 4张代码幻灯片**，含 OFDM 调制/同步/信道估计/译码 关键代码)

## 历史

- 快速原型: `C:\Users\Lenovo1\Desktop\vhf_ofdm_system\` (15 个 .m 文件, 含 GUI, 有 bug)
- 2026-05-24 决定从基础重新逐步搭建
