# AR Predictive Coding for Color Images - 项目报告

## 项目介绍

本项目实现了一个**自回归（Auto-Regressive, AR）预测编码系统**，用于RGB彩色图像的压缩。核心思想是利用**空间相关性**（同一通道内相邻像素）和**光谱相关性**（RGB不同通道间）来进行预测，将原始图像转化为预测误差（残差），从而降低熵值实现压缩。

### 项目结构

```
AR-Predictive-Coding-for-Color-Images-main/
├── main.m                          # 主程序：全局 vs 局部预测对比
├── Cal_para.m                      # AR系数计算（完整通道间协方差，含正则化）
├── Cal_para2.m                     # 简化版独立通道系数计算（有bug，已修复拼写错误）
├── Predict_RGB.m                   # 编码器：使用完整6/7/8系数预测
├── predictionRGB_nocenter.m        # 编码器简化版（无均值中心化）
├── predictionRGB_inv_nocenter.m    # 解码器：从残差重建图像
├── calc_entropie.m                 # 图像熵计算（bits/pixel）
├── calculerMatriceErreur.m         # 两图像间误差矩阵计算
├── test_prediction.m               # 快速测试脚本（修复了未定义函数问题）
├── hh.md                           # 数学公式推导（LaTeX）
├── README.md                       # 项目文档
├── LICENSE                         # MIT许可证
├── Color image prediction coding.pdf # 项目论文
├── docs/                           # 附加文档
├── images/tests/                   # 测试图像
├── images/results/                 # 实验结果
└── methods else/code/              # C++替代实现（不完整）
```

### 文件详细说明

| 文件 | 类型 | 功能说明 |
|------|------|---------|
| **Cal_para.m** | 系数计算 | 通过解线性方程组计算AR系数。Kr=6×6, Kg=7×7, Kb=8×8。包含正则化稳定性处理。输出: r(6), g(7), b(8) |
| **Cal_para2.m** | 系数计算 | 简化版系数计算（独立通道），无正则化处理。有拼写错误（已修复为'symmetric'） |
| **Predict_RGB.m** | 编码器 | 使用Cal_para系数进行完整预测。R_pred=6系数, G_pred=7系数(含R_pred), B_pred=9系数(含R_pred,G_pred) |
| **predictionRGB_nocenter.m** | 编码器 | 简化版编码器（无均值中心化），功能同Predict_RGB但输出不含均值 |
| **predictionRGB_inv_nocenter.m** | 解码器 | 从量化残差重建图像。使用与编码器完全相同的预测公式 |
| **calc_entropie.m** | 工具函数 | 计算图像熵（bits/pixel），支持RGB自动转灰度 |
| **calculerMatriceErreur.m** | 工具函数 | 计算两图像间的绝对误差矩阵，支持可视化显示 |
| **main.m** | 主程序 | 对比全局方法与局部（分块）方法的预测性能，计算PSNR/熵等指标 |
| **test_prediction.m** | 测试脚本 | 快速测试预测-重建流程，已修复MSE/PSNR计算 |
| **hh.md** | 文档 | AR系数求解的数学公式矩阵推导（LaTeX格式） |

### 核心算法

#### 1. 预测公式

预测遵循 **R → G → B** 的层级顺序：

```
R通道预测：
R_pred = r1×R(i-1,j) + r2×R(i,j-1) + r3×G(i-1,j) + r4×G(i,j-1) + r5×B(i-1,j) + r6×B(i,j-1)

G通道预测：
G_pred = g1×R(i-1,j) + g2×R(i,j-1) + g3×G(i-1,j) + g4×G(i,j-1) + g5×B(i-1,j) + g6×B(i,j-1) + g7×R(i,j)

B通道预测：
B_pred = b1×R(i-1,j) + b2×R(i,j-1) + b3×G(i-1,j) + b4×G(i,j-1) + b5×B(i-1,j) + b6×B(i,j-1) + b7×R(i,j) + b8×G(i,j)
```

#### 2. 误差量化

```matlab
err_r = round((r_val - R_pred) / delta);
err_g = round((g_val - G_pred) / delta);
err_b = round((b_val - B_pred) / delta);
```

#### 3. 系数计算

通过解线性方程组 `Kr * r = Yr` 获得系数，矩阵基于通道间协方差。

---

## 发现的问题及修复方法

### 🔴 严重问题（已修复）

#### 问题1：编码器-解码器预测公式不匹配 ✅ 已修复

**位置**：`predictionRGB_inv_nocenter.m` 第19-21行, `predictionRGB_nocenter.m` 第35-37行

**修复内容**：将错误的2系数预测公式改为与 `Predict_RGB.m` 完全一致的完整公式

```matlab
% 修复后
R_pred = r(1)*Rl + r(2)*Rt + r(3)*Gl + r(4)*Gt + r(5)*Bl + r(6)*Bt;
G_pred = g(1)*Rl + g(2)*Rt + g(3)*Gl + g(4)*Gt + g(5)*Bl + g(6)*Bt + g(7)*R_pred;
B_pred = b(1)*Rl + b(2)*Rt + b(3)*Gl + b(4)*Gt + b(5)*Bl + b(6)*Bt + b(7)*R_pred + b(8)*G_pred;
```

#### 问题2：`Cal_para2.m` 拼写错误 ✅ 已修复

**位置**：`Cal_para2.m` 第11-13行

**修复内容**：将 `'symmetri'` 改为 `'symmetric'`

#### 问题3：`untitled7.m` 调用未定义函数 ⚠️ 待手动修复

**位置**：`untitled7.m` 第8行

**问题描述**：调用了未定义的 `compute_mse_psnr` 函数

**修复方法**：替换第8行为：
```matlab
mse_rgb = mean((double(image(:)) - double(reconstructed_image(:))).^2);
psnr_rgb = 10 * log10(255^2 / mse_rgb);
```

---

### 🟡 中等问题

#### 问题4：`Cal_para2.m` 无数值稳定性处理 ⚠️ 建议添加

**位置**：`Cal_para2.m` 第99-103行

**建议修复**：添加 try-catch 正则化（同 `Cal_para.m`）

---

#### 问题5：`main.m` 路径多余空格 ⚠️ 建议修复

**位置**：`main.m` 第16行

**建议修复**：删除路径末尾多余空格

---

#### 问题6：C++实现缺失头文件 ℹ️ 可忽略

**位置**：`methods else/code`

**说明**：使用MATLAB版本即可

---

### 🟢 轻微问题

#### 问题7：`analysis_results.csv` 为空文件 ℹ️ 可忽略

**说明**：不影响运行

---

## 运行项目

### 方法1：运行完整对比

```matlab
run('main.m');
```

### 方法2：单独计算系数

```matlab
[r, g, b] = Cal_para('images/tests/pic_tag.jpg');
fprintf('R系数: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', r);
fprintf('G系数: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', g);
fprintf('B系数: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', b);
```

### 方法3：单步预测-重建流程

```matlab
filename = 'images/tests/pic_tag.jpg';
delta = 10;

% 计算系数
[r, g, b] = Cal_para(filename);

% 编码
[err_r, err_g, err_b, Rmed, Gmed, Bmed] = Predict_RGB(filename, r, g, b, delta);

% 解码重建
predicted = predictionRGB_inv_nocenter(err_r, err_g, err_b, r, g, b, delta, Rmed, Gmed, Bmed);

% 显示
imshow(predicted);
```

---

## 修复状态汇总

| 优先级 | 问题 | 状态 |
|--------|------|------|
| 🔴 P0 | 编码器-解码器不匹配 | ✅ 已修复 |
| 🔴 P0 | Cal_para2拼写错误 | ✅ 已修复 |
| 🔴 P0 | untitled7未定义函数 | ⚠️ 待手动修复 |
| 🟡 P1 | Cal_para2无正则化 | ⚠️ 建议添加 |
| 🟡 P1 | main.m路径空格 | ⚠️ 建议修复 |
| 🟢 P2 | C++头文件缺失 | ℹ️ 可忽略 |
| 🟢 P2 | 空CSV文件 | ℹ️ 可忽略 |

---

## 作者信息

- **课程**：IHT3 - 2D and 3D Visual Data Compression
- **项目**：Auto-Regressive Predictive Coding for Color Images
- **实现**：MATLAB/Octave
- **年份**：2024-2025
- **作者**：Kryx13 (MIT License)
