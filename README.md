# AR Predictive Coding for Color Images

[![IHT3](https://img.shields.io/badge/Course-IHT3-blue.svg)](https://github.com)
[![Language](https://img.shields.io/badge/Language-MATLAB-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Project Overview

This project implements **Auto-Regressive (AR) Predictive Coding for RGB Color Images** using inter-plane prediction and causal windows. The implementation provides **both global and local (block-based) approaches** and exploits spatial and spectral correlations between RGB channels to achieve efficient image compression through prediction.

### 🎯 Key Objectives

- **Inter-plane AR prediction**: Exploit correlations between R, G, B channels using optimal coefficients
- **Global vs Local strategies**: Compare single coefficient set vs block-adaptive approaches
- **Causal window processing**: Use symmetric boundary extension and raster-scan order
- **Optimal coefficient calculation**: Compute AR parameters using covariance matrices and least squares
- **Performance analysis**: Comprehensive entropy, MSE, and PSNR evaluation
- **Quantization analysis**: Study impact of quantization step size on compression performance

### 🔧 Core Features

- ✅ **Dual Implementation Strategies**: Global (single coeffs) and Local (block-adaptive coeffs)
- ✅ **Robust AR Coefficient Calculation**: Numerical stability with regularization
- ✅ **Advanced Inter-plane Prediction**: Hierarchical R→G→B correlation exploitation
- ✅ **Symmetric Boundary Extension**: Proper handling of image borders using mirroring
- ✅ **Comprehensive Performance Analysis**: Entropy, MSE, PSNR, and visual quality metrics
- ✅ **Quantization Error Analysis**: Detailed study of quantization effects
- ✅ **Results Export**: CSV files and MAT files for further analysis
- ✅ **Visualization Suite**: Complete plotting and comparison tools

---

## 🗺️ Implementation Structure

### 🧮 **Phase 1: AR Coefficient Calculation**

#### **`Cal_para.m` - Advanced Coefficient Calculator**
- **Full Inter-channel Correlation**: Complete covariance matrix construction
- **Numerical Stability**: Automatic regularization for ill-conditioned matrices
- **Input Flexibility**: Supports both image files and matrix data
- **Error Handling**: Robust validation and fallback mechanisms
- **Channel-specific Models**:
  - **R Channel**: 6 coefficients (spatial neighbors from R, G, B)
  - **G Channel**: 7 coefficients (6 spatial + current R pixel)  
  - **B Channel**: 8 coefficients (6 spatial + current R + current G pixels)

#### **`Cal_para2.m` - Simplified Independent Channels**
- **Diagonal Block Structure**: Treats R, G, B channels independently
- **Reduced Complexity**: Simplified coefficient calculation
- **Educational Purpose**: Demonstrates channel-independent approach

### 🔍 **Phase 2: RGB Prediction Implementation**

#### **`Predict_RGB.m` - Full Inter-plane Prediction**
- **Hierarchical Prediction**:
  - R: Uses spatial neighbors from all RGB channels
  - G: Adds dependency on current R pixel
  - B: Adds dependencies on current R and G pixels
- **Mean Removal/Addition**: Handles DC component separately
- **Quantization Integration**: Built-in delta quantization

#### **`predictionRGB_nocenter.m` / `predictionRGB_inv_nocenter.m`**
- **Encoder/Decoder Pair**: Complete round-trip implementation
- **Full Inter-plane Prediction**: Same prediction formula as Predict_RGB.m
- **No Mean Removal**: Simplified approach (mean handled separately)

### 📊 **Phase 3: Comprehensive Analysis**

#### **`main.m` - Complete Performance Comparison**
- **Global Method**: Single coefficient set for entire image
- **Local Method**: Block-adaptive coefficients (configurable block size)
- **Performance Metrics**:
  - Entropy analysis (original, predicted, residual, quantized errors)
  - Quality metrics (MSE, PSNR)
  - Compression potential evaluation
- **Visualization**: Multiple plots for visual comparison
- **Results Export**: CSV and MAT file generation

#### **Analysis Functions**
- **`calc_entropie.m`**: Robust entropy calculation with RGB support
- **`calculerMatriceErreur.m`**: Error matrix computation with visualization
- **Automatic fallbacks**: Handles edge cases and different MATLAB versions

---

## 🛠️ Technologies Used

### Programming Environment
- **MATLAB R2020b+**: Core implementation and matrix operations
- **GNU Octave**: Compatible with `pkg load image` for open-source usage
- **Image Processing Toolbox**: Image I/O and visualization

### Mathematical Framework
- **Linear Algebra**: Covariance matrices and regularized least squares
- **Information Theory**: Entropy calculation for compression analysis  
- **Signal Processing**: Symmetric boundary extension and causal filtering
- **Numerical Methods**: Condition number monitoring and regularization

---

## 📁 Project Structure

```
AR-PREDICTIVE-CODING-FOR-COLOR-IMAGES/
├── main.m                           # 🎯 Main comparison script (Global vs Local)
├── Cal_para.m                       # 🧮 Advanced AR coefficient calculation
├── Cal_para2.m                      # 🧮 Simplified independent channel coeffs
├── Predict_RGB.m                    # 🔍 Full inter-plane RGB prediction
├── predictionRGB_nocenter.m         # 🔍 Simplified prediction (no mean removal)
├── predictionRGB_inv_nocenter.m     # 🔍 Simplified reconstruction
├── calc_entropie.m                  # 📊 Robust entropy calculation
├── calculerMatriceErreur.m          # 📊 Error matrix computation
├── test_prediction.m                # 🧪 Quick test script
├── analysis_results.csv             # 📈 Performance data
├── hh.md                           # 📐 Mathematical formulation (LaTeX)
├── Color image prediction coding.pdf # 📑 Project documentation
├── LICENSE                          # ⚖️ MIT License
├── README.md                        # 📖 This documentation
├── docs/                           # 📚 Documentation and references
│   ├── Color image prediction coding.pdf
│   ├── Roadmap_Color_Image_Predictive_Coding.pdf
│   └── Sujets-controle_assigned.pdf
├── images/                         # 📷 Test images and comprehensive results
│   ├── tests/                      # Input test images
│   │   ├── Foyer.jpg
│   │   ├── LargeTrainingSet.jpg
│   │   ├── pic_tag.jpg
│   │   ├── wallpaper la nuit étoilé.jpg
│   │   └── wallpaper_ia.jpg
│   └── results/                    # Organized experimental results
│       ├── LargeTrainingSet/       # Results for large training dataset
│       ├── pic_tag_8/              # Results with 8×8 block size
│       ├── pic_tag_16/             # Results with 16×16 block size
│       │   ├── overlap/            # Results with block overlap
│       │   │   ├── delta q 1/      # Quantization step δ=1
│       │   │   ├── delta q 4/      # Quantization step δ=4
│       │   │   └── delta q 8/      # Quantization step δ=8
│       │   └── without overlap/    # Results without block overlap
│       └── pic_tag_32/            # Results with 32×32 block size
└── methods else/                   # Alternative methods and comparisons
    ├── code                       # Alternative implementation codes
    ├── entropy and L2 norm of error # Performance analysis data
    ├── image/                     # Reconstructed images from different methods
    ├── image_dpcm_1&error/        # DPCM method 1 results and errors
    ├── image_dpcm_2&error/        # DPCM method 2 results and errors
    ├── image_dpcm_3&error/        # DPCM method 3 results and errors
    └── image_dpcm_4&error/        # DPCM method 4 results and errors
```

---

## 🚀 Getting Started

### Prerequisites
- MATLAB R2020b+ or GNU Octave 6.0+
- Image Processing Toolbox (MATLAB) or `pkg load image` (Octave)
- Test RGB images (recommended: natural images, 256×256 or larger)

### Quick Start - Complete Analysis

```matlab
%% Run complete global vs local comparison
% Configure your settings in main.m
config.image_path = 'path/to/your/image.jpg';
config.block_size = 32;           % Block size for local method
config.delta = 10;                % Quantization step
config.save_results = true;       % Export results
config.show_plots = true;         % Display visualizations

% Run complete analysis
run('main.m');
```

### Individual Component Usage

#### 1. Calculate AR Coefficients
```matlab
% Advanced method with full inter-channel correlation
[r_coeffs, g_coeffs, b_coeffs] = Cal_para('your_image.jpg');

% Simplified method (independent channels)
[r_simple, g_simple, b_simple] = Cal_para2('your_image.jpg');

% Display results
fprintf('Advanced R coeffs: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', r_coeffs);
fprintf('Simple R coeffs: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', r_simple);
```

#### 2. Perform Prediction
```matlab
% Full inter-plane prediction with mean handling
[err_r, err_g, err_b, Rmean, Gmean, Bmean] = Predict_RGB('image.jpg', r_coeffs, g_coeffs, b_coeffs, 10);

% Simplified prediction without mean removal
[err_r2, err_g2, err_b2, Rm2, Gm2, Bm2] = predictionRGB_nocenter('image.jpg', r_coeffs, g_coeffs, b_coeffs, 10);

% Reconstruct from errors (decoder)
reconstructed = predictionRGB_inv_nocenter(err_r, err_g, err_b, r_coeffs, g_coeffs, b_coeffs, 10, Rmean, Gmean, Bmean);
```

#### 3. Quick Test
```matlab
% Run quick prediction test
test_prediction('image.jpg', 10);  % filename and delta
```

#### 3. Analyze Performance
```matlab
% Load original and reconstruct predicted
original = imread('image.jpg');
predicted = cat(3, err_r*10 + Rmean, err_g*10 + Gmean, err_b*10 + Bmean);
predicted = uint8(min(max(predicted, 0), 255));

% Calculate performance metrics
H_original = calc_entropie(original);
H_predicted = calc_entropie(predicted);
error_matrix = calculerMatriceErreur(original, predicted, 'show', true);
mse = mean((double(original(:)) - double(predicted(:))).^2);
psnr = 10 * log10(255^2 / mse);

fprintf('Original entropy: %.3f bits/pixel\n', H_original);
fprintf('MSE: %.2f, PSNR: %.2f dB\n', mse, psnr);
```

---

## 🔬 Mathematical Formulation

### 1. Enhanced AR Coefficient Matrices

**R Channel (6×6 matrix) - Full Inter-channel Correlation:**
```matlab
Kr = [RR00 RR11 RG00 RG11 RB00 RB11;
      RR11 RR00 GR11 RG00 BR11 RB00;
      RG00 GR11 GG00 GG11 GB00 GB11;
      RG11 RG00 GG11 GG00 BG11 GB00;
      RB00 BR11 GB00 BG11 BB00 BB11;
      RB11 RB00 GB11 GB00 BB11 BB00];
```

**G Channel (7×7 matrix):** Extends R matrix with current R pixel terms

**B Channel (8×8 matrix):** Extends G matrix with current R and G pixel terms

### 2. Hierarchical Prediction Equations

```matlab
% R prediction (uses spatial neighbors from all channels)
R̂(i,j) = r₁×R(i-1,j) + r₂×R(i,j-1) + r₃×G(i-1,j) + r₄×G(i,j-1) + r₅×B(i-1,j) + r₆×B(i,j-1)

% G prediction (adds current R pixel dependency)
Ĝ(i,j) = g₁×R(i-1,j) + g₂×R(i,j-1) + g₃×G(i-1,j) + g₄×G(i,j-1) + g₅×B(i-1,j) + g₆×B(i,j-1) + g₇×R(i,j)

% B prediction (adds current R and G pixel dependencies)
B̂(i,j) = b₁×R(i-1,j) + b₂×R(i,j-1) + b₃×G(i-1,j) + b₄×G(i,j-1) + b₅×B(i-1,j) + b₆×B(i,j-1) + b₇×R(i,j) + b₈×G(i,j)
```

### 3. Numerical Stability Enhancement

```matlab
% Regularized solution for ill-conditioned matrices
try
    r = Kr \ Yr;
catch
    lambda = 1e-6;  % Regularization parameter
    r = (Kr + lambda * eye(size(Kr))) \ Yr;
end
```

---

## 📊 Performance Analysis

### Evaluation Metrics
1. **Entropy Analysis**: Original vs predicted vs quantized error entropy
2. **Quality Metrics**: MSE and PSNR for both methods
3. **Compression Potential**: Bit rate reduction estimation
4. **Visual Quality**: Subjective assessment of prediction accuracy
5. **Coefficient Stability**: Analysis of AR parameter consistency

### Comprehensive Experimental Results
The `images/results/` directory contains extensive experimental data with systematic variations:
- **Block Sizes**: 8×8, 16×16, 32×32 pixel blocks
- **Quantization Steps**: δ = 1, 4, 8 for detailed compression analysis
- **Block Processing**: With and without overlap for boundary handling
- **Multiple Test Images**: Different image characteristics and complexities

---

## 🔬 Implementation Details

### **Block-based Local Method**
```matlab
% Configurable block processing with comprehensive analysis
config.block_size = [8, 16, 32];    # Multiple block sizes tested
config.overlap = [0, with_overlap];  # With and without overlap
config.delta = [1, 4, 8];          # Multiple quantization steps

% Automatic fallback for small blocks
if block_width < 8 || block_height < 8
    % Use global coefficients for small blocks
    local_coeffs = global_coeffs;
end
```

### **Systematic Experimental Design**
```matlab
% Comprehensive parameter space exploration
test_images = {'pic_tag.jpg', 'LargeTrainingSet.jpg', 'Foyer.jpg'};
block_sizes = [8, 16, 32];
delta_values = [1, 4, 8];
overlap_modes = {'with_overlap', 'without_overlap'};

% Results organized by configuration
for each combination:
    % Generate complete analysis with CSV exports
    % Save visualizations and performance metrics
end
```

### **Alternative Methods Comparison**
The `methods else/` directory contains comparative analysis with other predictive coding approaches including multiple DPCM variants, providing benchmarking against established methods.

---

## 📖 Academic References

### Core Theory
1. **Makhoul, J. (1975)** - "Linear Prediction: A Tutorial Review", Proc. IEEE
2. **Jain, A.K. (1981)** - "Image data compression: A review", Proc. IEEE
3. **Netravali, A.N. & Limb, J.O. (1980)** - "Picture coding: A review", Proc. IEEE

### Inter-plane Prediction
4. **"Interplane prediction for RGB video coding"** - IEEE Conference
5. **"High-Fidelity RGB Video Coding Using Adaptive Inter-Plane Weighted Prediction"** - IEEE Journals
6. **"A lossless image coding technique exploiting spectral correlation on the RGB space"** - IEEE Conference

### Block-based Adaptive Methods
7. **"Adaptive block-based image coding using predictive techniques"** - Signal Processing
8. **"Local vs global prediction in image compression"** - IEEE Image Processing

---

## ⚠️ Important Notes

### 🔴 **Numerical Stability**
The covariance matrices can become ill-conditioned for certain image types. The implementation includes automatic regularization to handle these cases.

### 🔶 **Block Size Selection**
For local method, block size affects the trade-off between adaptation and statistical reliability. Recommended range: 16×16 to 64×64.

### 🔵 **Memory Management**
Large images with small block sizes can generate many temporary files. Ensure sufficient disk space and automatic cleanup.

### 🟡 **Quantization Impact**
The delta parameter significantly affects both compression ratio and quality. Lower values preserve quality but reduce compression.

---

## 🤝 Contributing

### Development Guidelines
- Follow MATLAB/Octave coding standards
- Add comprehensive comments and documentation
- Include error handling and input validation
- Test with various image types and sizes
- Update this README for significant changes

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🔗 Quick Navigation

- [🚀 Quick Start](#-getting-started)
- [📊 Performance Analysis](#-performance-analysis)
- [🔬 Mathematical Details](#-mathematical-formulation)
- [📁 File Structure](#-project-structure)
- [🔬 Implementation Details](#-implementation-details)

---

**Course**: IHT3 - 2D and 3D Visual Data Compression  
**Project**: Auto-Regressive Predictive Coding for Color Images  
**Implementation**: MATLAB/Octave with Global and Local Strategies  
**Academic Year**: 2024-2025