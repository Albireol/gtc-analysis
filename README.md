# GTC Data Analysis - Python 重构

基于 MATLAB GTC Data Processing GUI 的 Python 现代化重构

## 📁 项目结构

```
gtc-analysis/
├── main.py                     # GUI 主入口
├── history_panel.py            # History 分析面板
├── snapshot_panel.py           # Snapshot 分析面板
├── equilibrium_panel.py        # Equilibrium 分析面板
├── requirements.txt            # Python 依赖
├── README.md                   # 项目说明
├── .gitignore                  # Git 忽略规则
├── gtc/                        # 核心 Python 包
│   ├── __init__.py
│   ├── context.py              # 上下文管理器
│   ├── equilibrium_reader.py   # 平衡数据读取
│   ├── gtc_reader.py           # GTC 参数读取
│   ├── history_plotter.py      # History 绘图
│   ├── history_reader.py       # History 数据读取
│   └── snapshot_reader.py      # Snapshot 数据读取
├── data/                       # 数据文件目录
├── examples/                   # 示例脚本
└── matlab/                     # MATLAB 参考代码
```

## 🚀 快速开始

### Windows 一键启动

双击 `start.bat` 即可启动 GUI。

### 手动启动

```bash
cd gtc-analysis
.\venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

## 📊 功能模块

### 1. History Analysis (📈)

分析 `history.out` 文件，提供以下功能：

- **场变量分析**：ϕ (Phi), A‖ (A-para), nₑ (fluidne)
  - 时间序列图
  - RMS 图
- **模式分析**：Mode 1-8
  - 实部/虚部时间演化
  - 对数振幅历史（含线性拟合）
  - 增长率归一化信号
  - FFT 功率谱
- **粒子诊断**：Ion/Electron/EP
  - Density, Entropy, Momentum
  - Energy, Particle/Momentum/Energy Flux

**增长率计算**：
- 自动检测线性增长区域（R²阈值法）
- 单位：R₀/Cₛ
- 频率计算：FFT 频谱分析

### 2. Snapshot Analysis (📊)

分析 `snap*.out` 文件，提供以下功能：

- **粒子剖面**：Ion/Electron/EP
  - Density, Flow, Energy
  - PDF in Energy/Pitch Angle
- **场变量分析**：Phi/A-para/Fluidne
  - Flux Surface 等高线图
  - Poloidal/SParallel Spectrum
  - 极向截面图
  - 径向剖面 (r/a)
- **综合谱分析** (Spectrum 按钮)
  - 极向谱 (Poloidal Spectrum)
  - 平行谱 (Parallel Spectrum)
  - 模式结构 δφ̃_m(r)
  - 点值径向剖面
  - RMS 径向剖面
  - 2D 模式谱 (m vs r/a)

### 3. Equilibrium Analysis (⚖️)

分析 `profile.dat` 和 `spdata.dat` 文件，提供以下功能：

- **密度剖面**：ne, ni, nf, nα
- **温度剖面**：Te, Ti, Tf, Tα
- **压力剖面**：Pe, Pi, Pf, Pα
- **平衡参数**：
  - q Profile & Magnetic Shear
  - Beta Profiles (β_e, β_i, β_f, β_α, β_total)
- **汇总图**：所有密度和温度剖面

## 📖 使用示例

### 加载 History 数据

1. 切换到 "📈 History Analysis" 标签页
2. 点击 "📁 Browse" 选择包含 `history.out` 和 `gtc.out` 的目录
3. 点击 "📥 Load Data" 加载数据
4. 点击任意按钮打开分析图窗

### 加载 Snapshot 数据

1. 切换到 "📊 Snapshot Analysis" 标签页
2. 点击 "📁 Browse" 选择包含 `snap*.out` 的目录
3. 点击 "📥 Load Data" 加载数据
4. 点击任意按钮打开分析图窗

### 加载 Equilibrium 数据

1. 切换到 "⚖️ Equilibrium Analysis" 标签页
2. 点击 "📁 Browse" 选择包含 `profile.dat` 和 `spdata.dat` 的目录
3. 点击 "📥 Load Data" 加载数据
4. 点击任意按钮打开分析图窗

### 图窗操作

每个图窗都有以下功能按钮：

- **💾 Save** - 保存为 PNG/PDF/SVG 格式
- **📋 Copy** - 复制到剪贴板（可直接粘贴到 Word/PPT）
- **⛶ Fullscreen** - 全屏切换
- **❌ Close** - 关闭窗口

## 📊 MATLAB vs Python 对照

| MATLAB 文件 | Python 模块 | 功能 |
|------------|------------|------|
| `history.m` | `gtc/history_reader.py` + `history_plotter.py` | History 数据读取和绘图 |
| `snapshot.m` | `gtc/snapshot_reader.py` + `snapshot_panel.py` | Snapshot 数据读取和绘图 |
| `read_para.m` | `gtc/gtc_reader.py` | GTC 参数解析 |
| `cal_gamma.m` | `gtc/history_reader.py` | 增长率计算 |
| `cal_omega_fft.m` | `gtc/history_reader.py` | FFT 频谱分析 |
| `read_prodata.m` | `gtc/equilibrium_reader.py` | Profile 数据读取 |
| `read_spdata.m` | `gtc/equilibrium_reader.py` | Spdata 数据读取 |
| `setpath.m` | `gtc/context.py` | 路径和数据管理 |

## 🔧 主要特性

### 1. 浅色主题
- 白色背景，适合科学出版
- 高对比度颜色方案
- 统一的视觉风格

### 2. 自动计算
- 增长率自动检测线性区域
- 频率 FFT 分析
- 磁剪切计算

### 3. 多窗口支持
- 每个按钮打开独立窗口
- 支持多窗口同时查看
- 全屏模式便于展示

### 4. 导出功能
- 保存为 PNG/PDF/SVG
- 复制到剪贴板
- 高分辨率输出 (150 DPI)

## ⚠️ 注意事项

1. **数据兼容性**: 支持 GTC 4.4-4.6 版本输出
2. **单位系统**: 默认使用模拟单位 (R₀/cₛ)
3. **时间单位**: 横坐标为 R₀/cₛ，通过 `dt = dt0 * ndiag` 计算

## 🙏 致谢

- 原始 MATLAB: Hua-sheng XIE, Yuehao Ma
- Python 重构：Albireo

## 📄 License

MIT License
