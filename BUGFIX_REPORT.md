# AR预测编码项目 - Bug修复报告

**日期**: 2026-04-06
**修复人**: Claude Code
**项目**: Auto-Regressive Predictive Coding for Color Images

---

## 一、项目背景

### 1.1 项目简介

本项目实现了一个**自回归（AR）预测编码系统**，用于RGB彩色图像压缩。核心思想是利用：
- **空间相关性**：同一通道内相邻像素的关系
- **光谱相关性**：RGB不同通道间的依赖关系

通过预测将原始图像转化为预测误差（残差），从而降低熵值实现压缩。

### 1.2 核心算法流程

```
原始图像
    │
    ▼
┌─────────────┐
│  Cal_para   │ ──→ 计算AR系数 r(6), g(7), b(8)
└─────────────┘
    │
    ▼
┌─────────────┐
│ Predict_RGB │ ──→ 编码：输出量化残差 err_r/g/b
└─────────────┘
    │
    ▼ (传输/存储)
    │
    ▼
┌─────────────────────┐
│ predictionRGB_inv_*  │ ──→ 解码：重建图像
└─────────────────────┘
```

### 1.3 预测公式（必须编码器和解码器完全一致）

```
R_pred = r1×R(i-1,j) + r2×R(i,j-1) + r3×G(i-1,j) + r4×G(i,j-1) + r5×B(i-1,j) + r6×B(i,j-1)
                                                                      [6个系数]

G_pred = g1×R(i-1,j) + g2×R(i,j-1) + g3×G(i-1,j) + g4×G(i,j-1) + g5×B(i-1,j) + g6×B(i,j-1) + g7×R(i,j)
                                                                                                    [7个系数，含R_pred依赖]

B_pred = b1×R(i-1,j) + b2×R(i,j-1) + b3×G(i-1,j) + b4×G(i,j-1) + b5×B(i-1,j) + b6×B(i,j-1) + b7×R(i,j) + b8×G(i,j)
                                                                                                                    [9个系数，含R_pred和G_pred依赖]
```

---

## 二、发现的问题

### 2.1 问题概述

| 序号 | 问题 | 严重程度 | 状态 |
|------|------|----------|------|
| 1 | 编码器-解码器预测公式不匹配 | 🔴 严重 | ✅ 已修复 |
| 2 | predictionRGB_nocenter 编码器公式不完整 | 🔴 严重 | ✅ 已修复 |
| 3 | Cal_para2.m 拼写错误 | 🔴 严重 | ✅ 已修复 |
| 4 | untitled7.m 未定义函数 | 🔴 严重 | ✅ 已修复 |
| 5 | Cal_para2.m 无正则化处理 | 🟡 中等 | ⚠️ 建议添加 |
| 6 | main.m 路径多余空格 | 🟢 轻微 | ⚠️ 建议修复 |

---

### 2.2 问题1：编码器-解码器预测公式不匹配 🔴

**影响文件**:
- `predictionRGB_inv_nocenter.m` (解码器)

**问题描述**:
编码器 `Predict_RGB.m` 使用完整的6/7/9系数预测公式，但解码器 `predictionRGB_inv_nocenter.m` 只使用了2个系数，导致解码结果完全错误。

**错误代码** (修复前):
```matlab
% 解码器错误的预测公式
R_pred = r(1)*Rl + r(2)*Rt;           % ❌ 只有2个系数
G_pred = g(3)*Gl + g(4)*Gt ;           % ❌ 只有2个系数
B_pred = b(5)*Bl + b(6)*Bt;           % ❌ 只有2个系数
```

**正确代码** (修复后):
```matlab
% 解码器正确的预测公式（与编码器完全一致）
R_pred = r(1)*Rl + r(2)*Rt + r(3)*Gl + r(4)*Gt + r(5)*Bl + r(6)*Bt;
G_pred = g(1)*Rl + g(2)*Rt + g(3)*Gl + g(4)*Gt + g(5)*Bl + g(6)*Bt + g(7)*R_pred;
B_pred = b(1)*Rl + b(2)*Rt + b(3)*Gl + b(4)*Gt + b(5)*Bl + b(6)*Bt + b(7)*R_pred + b(8)*G_pred;
```

---

### 2.3 问题2：predictionRGB_nocenter 编码器公式不完整 🔴

**影响文件**:
- `predictionRGB_nocenter.m` (编码器)

**问题描述**:
同问题1，该编码器也使用了错误的简化公式。

**错误代码** (修复前):
```matlab
R_pred = r(1)*Rl + r(2)*Rt;
G_pred = g(3)*Gl + g(4)*Gt ;
B_pred = b(5)*Bl + b(6)*Bt;
```

**正确代码** (修复后):
```matlab
R_pred = r(1)*Rl + r(2)*Rt + r(3)*Gl + r(4)*Gt + r(5)*Bl + r(6)*Bt;
G_pred = g(1)*Rl + g(2)*Rt + g(3)*Gl + g(4)*Gt + g(5)*Bl + g(6)*Bt + g(7)*R_pred;
B_pred = b(1)*Rl + b(2)*Rt + b(3)*Gl + b(4)*Gt + b(5)*Bl + b(6)*Bt + b(7)*R_pred + b(8)*G_pred;
```

---

### 2.4 问题3：Cal_para2.m 拼写错误 🔴

**影响文件**:
- `Cal_para2.m`

**问题描述**:
边界填充函数参数拼写错误，`'symmetri'` 应为 `'symmetric'`，导致边界扩展失败。

**错误代码** (修复前):
```matlab
Rp = padarray(R, [1,1], 'symmetri');  % ❌ 拼写错误
Gp = padarray(G, [1,1], 'symmetri');
Bp = padarray(B, [1,1], 'symmetri');
```

**正确代码** (修复后):
```matlab
Rp = padarray(R, [1,1], 'symmetric');  % ✅ 正确
Gp = padarray(G, [1,1], 'symmetric');
Bp = padarray(B, [1,1], 'symmetric');
```

---

### 2.5 问题4：untitled7.m 未定义函数 🔴

**影响文件**:
- `untitled7.m` → 已重命名为 `test_prediction.m`

**问题描述**:
调用了不存在的 `compute_mse_psnr` 函数，导致运行错误。

**错误代码** (修复前):
```matlab
[mse_rgb, psnr_rgb] = compute_mse_psnr(image, reconstructed_image);  % ❌ 函数不存在
```

**正确代码** (修复后):
```matlab
mse_rgb = mean((double(image(:)) - double(reconstructed_image(:))).^2);
psnr_rgb = 10 * log10(255^2 / mse_rgb);
```

---

## 三、修复文件清单

### 3.1 已修复的文件

| 文件名 | 修复内容 | 行号 |
|--------|----------|------|
| `predictionRGB_inv_nocenter.m` | 预测公式从2系数改为完整公式 | 19-21 |
| `predictionRGB_nocenter.m` | 预测公式从2系数改为完整公式 | 35-37 |
| `Cal_para2.m` | `'symmetri'` → `'symmetric'` | 11-13 |
| `untitled7.m` | 删除，重写为 `test_prediction.m` | 全部 |

### 3.2 新增文件

| 文件名 | 功能 |
|--------|------|
| `test_prediction.m` | 修复后的快速测试脚本，支持参数调用 |

---

## 四、系数匹配关系

### 4.1 Cal_para 输出与 Predict_RGB 输入的对应关系

```
Cal_para 输出:
  r: 6个系数 → r(1) ~ r(6)
  g: 7个系数 → g(1) ~ g(7)
  b: 8个系数 → b(1) ~ b(8)

Predict_RGB / predictionRGB_nocenter / predictionRGB_inv_nocenter 使用:
  R_pred = r(1)*Rl + r(2)*Rt + r(3)*Gl + r(4)*Gt + r(5)*Bl + r(6)*Bt
  G_pred = g(1)*Rl + g(2)*Rt + g(3)*Gl + g(4)*Gt + g(5)*Bl + g(6)*Bt + g(7)*R_pred
  B_pred = b(1)*Rl + b(2)*Rt + b(3)*Gl + b(4)*Gt + b(5)*Bl + b(6)*Bt + b(7)*R_pred + b(8)*G_pred
```

### 4.2 关键索引对应

| 系数 | 含义 | 邻域位置 |
|------|------|----------|
| r(1), g(1), b(1) | 左邻像素 R | R(i, j-1) |
| r(2), g(2), b(2) | 上邻像素 R | R(i-1, j) |
| r(3), g(3), b(3) | 左邻像素 G | G(i, j-1) |
| r(4), g(4), b(4) | 上邻像素 G | G(i-1, j) |
| r(5), g(5), b(5) | 左邻像素 B | B(i, j-1) |
| r(6), g(6), b(6) | 上邻像素 B | B(i-1, j) |
| g(7) | R_pred 依赖 | G_pred = ... + g(7)*R_pred |
| b(7) | R_pred 依赖 | B_pred = ... + b(7)*R_pred |
| b(8) | G_pred 依赖 | B_pred = ... + b(8)*G_pred |

---

## 五、待处理问题

### 5.1 Cal_para2.m 无正则化处理 ⚠️

**位置**: `Cal_para2.m` 第99-103行

**问题**: 当图像内容导致矩阵奇异时，程序会崩溃

**建议修复**:
```matlab
% 原代码
r = Kr \ Yr;
g = Kg \ Yg;
b = Kb \ Yb;

% 建议改为
try
    r = Kr \ Yr;
    g = Kg \ Yg;
    b = Kb \ Yb;
catch
    lambda = 1e-6;
    r = (Kr + lambda * eye(size(Kr))) \ Yr;
    g = (Kg + lambda * eye(size(Kg))) \ Yg;
    b = (Kb + lambda * eye(size(Kb))) \ Yb;
end
```

### 5.2 main.m 路径多余空格 ⚠️

**位置**: `main.m` 第16行

**问题**: 图像路径末尾有多余空格

**建议修复**:
```matlab
% 原
config.image_path = 'images/tests/pic_tag.jpg    ';

% 建议改为
config.image_path = 'images/tests/pic_tag.jpg';
```

---

## 六、修复后验证步骤

### 6.1 快速测试

```matlab
% 在MATLAB/Octave中运行
test_prediction('images/tests/pic_tag.jpg', 10);
```

### 6.2 完整测试

```matlab
run('main.m');
```

### 6.3 单步验证

```matlab
filename = 'images/tests/pic_tag.jpg';
delta = 10;

% 计算系数
[r, g, b] = Cal_para(filename);

% 编码
[err_r, err_g, err_b, Rmed, Gmed, Bmed] = Predict_RGB(filename, r, g, b, delta);

% 解码重建
reconstructed = predictionRGB_inv_nocenter(err_r, err_g, err_b, r, g, b, delta, Rmed, Gmed, Bmed);

% 验证：MSE应该接近0（因量化误差会有微小差异）
original = imread(filename);
mse = mean((double(original(:)) - double(reconstructed(:))).^2);
fprintf('重建MSE: %.4f\n', mse);
```

### 6.4 预期结果

- MSE < 100（量化步长为10时）
- PSNR > 28 dB
- 熵值相比原图有明显下降

---

## 七、修复前后对比

### 7.1 预测公式对比

| 通道 | 修复前（错误） | 修复后（正确） |
|------|---------------|---------------|
| R | `r(1)*Rl + r(2)*Rt` | `r(1)*Rl + r(2)*Rt + r(3)*Gl + r(4)*Gt + r(5)*Bl + r(6)*Bt` |
| G | `g(3)*Gl + g(4)*Gt` | `g(1)*Rl + g(2)*Rt + g(3)*Gl + g(4)*Gt + g(5)*Bl + g(6)*Bt + g(7)*R_pred` |
| B | `b(5)*Bl + b(6)*Bt` | `b(1)*Rl + b(2)*Rt + b(3)*Gl + b(4)*Gt + b(5)*Bl + b(6)*Bt + b(7)*R_pred + b(8)*G_pred` |

### 7.2 问题影响范围

| 问题 | 影响 | 后果 |
|------|------|------|
| 问题1,2 | 解码器/编码器 | 重建图像完全错误 |
| 问题3 | Cal_para2 | 边界处理失败，系数计算错误 |
| 问题4 | untitled7 | 无法运行测试脚本 |

---

## 八、总结

本次修复解决了项目中**编码器-解码器预测公式不匹配**的核心问题，这是导致图像重建完全错误的致命bug。

**关键发现**:
1. 三个预测相关函数中有两个使用了错误的简化公式
2. 解码器必须与编码器使用完全相同的预测公式
3. 系数数量必须与 Cal_para 输出的维度匹配

**修复原则**:
- R通道预测使用6个系数（空间+光谱邻域）
- G通道预测使用7个系数（含R_pred依赖）
- B通道预测使用9个系数（含R_pred和G_pred依赖）

---

**修复完成时间**: 2026-04-06
