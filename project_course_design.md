---
name: project-course-design
description: 移动通信课程设计 — VHF OFDM 系统 MATLAB 仿真，第2组，SISO + MIMO 2×2 Alamouti 完整实现
metadata:
  type: project
  originSessionId: 50fe77a9-7712-4d46-9e97-1ff0bb501b6f
---

# 移动通信课程设计 — VHF 无线通信系统

## 当前状态 (2026-05-28)

**当前电脑**: QIANJUNYANG
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

## OFDM 参数

| 参数 | 值 | 理由 |
|------|------|------|
| FFT 点数 N_fft | 512 | 符号 512 μs |
| 有效子载波 | 400 | DC(1)+左保护带(55)+右保护带(55)+Nyquist(1)=112 空 |
| 子载波间隔 Δf | 1.95 kHz | ≫ 多普勒 5.6 Hz |
| CP 长度 | 8 μs (8 样本) | 覆盖 2 μs 时延 |
| 符号总长 | 520 μs | 512 + 8 |
| 周期导频间隔 | 40 符号 (20.8 ms) | < Tc/4 ≈ 22.5 ms |

## SISO 全链路模块

| # | 模块 | 文件 | 参数 |
|---|------|------|------|
| 1 | 信源 | `generate_source.m` | uniform random |
| 2 | CRC-16 | `crc16_encode.m` / `crc16_check.m` | CRC-16-CCITT (0x1021) |
| 3 | 信道编码 | `channel_encode.m` / `channel_decode.m` | 卷积码 K=7 R=1/2 [171,133], 软判决 Viterbi |
| 4 | 交织 | `interleave.m` / `deinterleave.m` | 随机交织 (rng=42), 跨帧全排列 |
| 5 | 符号调制 | `modulate.m` / `demodulate.m` | QPSK/16QAM/64QAM, 软判决LLR + 硬判决 |
| 6 | OFDM 调制/解调 | `ofdm_config.m` / `ofdm_tx_symbol.m` / `ofdm_rx_demod.m` | 512 FFT, CP=8 |
| 7 | OFDM 帧组装 | `ofdm_assemble_frame.m` | 周期导频 (spacing=40) |
| 8 | 信道模型 | `vhf_channel.m` / `rayleigh_fading.m` | 5径, fd=5.56Hz |
| 9 | AWGN | `add_awgn.m` | SNR (dB) → 复高斯噪声 |
| 10 | 时间同步 | `ofdm_time_sync.m` | 互相关, PN训练(rng=7) |
| 11 | 频率同步 | `ofdm_freq_sync.m` | 频域 training vs pilot 相位差 |
| 12 | 信道估计 | `channel_estimate_mmse.m` / `channel_estimate_interp.m` | MMSE平滑 + 周期导频插值 |
| 13 | 均衡 | `channel_equalize.m` | ZF / MMSE 可选 |
| 14 | 全链路主程序 | `main.m` | 合并 test_all + test_all_mimo，天线方案选择 + 自适应调制 |

## MIMO 2×2 Alamouti 模块

| # | 模块 | 文件 |
|---|------|------|
| 1 | MIMO帧组装 | `mimo_ofdm_assemble_frame.m` (时分训练+导频, Alamouti编码) |
| 2 | MIMO信道 | `mimo_channel.m` (4条独立SISO VHF链路) |
| 3 | MIMO同步 | `ofdm_mimo_sync.m` (双天线时间+频率同步) |
| 4 | MIMO信道估计 | `mimo_channel_est.m` (时分正交导频, MMSE+插值) |
| 5 | Alamouti解码 | `alamouti_decode.m` (2×2合并, 4阶分集) |

## GUI 应用程序

| 文件 | 功能 |
|------|------|
| `vhf_ofdm_app.m` | 程序化 GUI：参数配置 + SNR扫描(BER/FER) + 链路观察(全可视化) |
| `main.m` | 统一入口：SISO/MIMO选择 + 自适应调制(QPSK/16QAM/64QAM) + 全可视化 |
| `run_test_wrapper.m` | GUI调用 main() 的桥接 (传递天线方案/SNR/N参数) |
| `test_all.m` | [已合并] SISO单点测试（保留备用） |
| `test_all_mimo.m` | [已合并] MIMO单点测试（保留备用） |
| `app2.mlapp` | App Designer 版本 (实验性) |

## 关键技术决策

- **频域频偏估计**：用 training 和 pilot 符号的频域相位差，替代时域 CP 方法，避免多径交叉干扰
- **软判决**：QPSK 直接从 I/Q 分量取软值 (±1)，Viterbi `unquant` 模式，比硬判决增益 2-3 dB
- **MMSE 均衡 + 软判决**：天然置信度加权，深衰落子载波被压制→软值接近 0→Viterbi 不给权重
- **周期导频**：每 40 符号插入导频 (20.8ms < Tc/4)，MMSE 估计 + 线性插值，解决信道老化
- **Alamouti 4 阶分集**：2×2 MIMO 提供 |H11|²+|H12|²+|H21|²+|H22|² 合并，BER ~ 1/SNR⁴
- **随机数种子**：rng(42) 交织, rng(7/77) 训练, rng(13/131) 导频。衰落无显式种子（继承全局状态）
- **过采样**：figure(2) 包络使用 10× spline 插值光滑显示

## MIMO 性能 (5 dB QPSK, 100万bit)

| 判决 | BER | FER |
|------|-----|-----|
| 软判决 | < 10⁻⁶ (>4dB 零误码) | ~10⁻³ |
| 硬判决 | ~3×10⁻³ | ~3×10⁻³ |

## 可视化 (SISO, 链路观察)

| Figure | 内容 |
|--------|------|
| Fig 1 | 5行 bit 流水线 (信源→CRC→编码→交织→解交织) |
| Fig 2 | 功率延迟谱 + 过采样包络对比 |
| Fig 3 | QPSK I/Q stem |
| Fig 4 | OFDM 时域(CP+Body) + 频域子载波 |
| Fig 5 | 时间同步相关峰 + **导频子载波相位漂移(校正前/后)** |
| Fig 6 | 信道估计 (真实 vs MMSE, 幅值+相位) |
| Fig 7 | 均衡前后星座 + 理想QPSK对比 |
| Fig 8 | BER/FER 柱状图 (软 vs 硬) |

## 历史

- 快速原型: `C:\Users\Lenovo1\Desktop\vhf_ofdm_system\` (15 个 .m 文件, 有 bug)
- 2026-05-24 决定从基础重新逐步搭建
- 2026-05-27 完成 SISO + MIMO 全链路、周期导频、频域频偏估计
- 2026-05-28 GUI 封装、链路观察可视化、打包准备
