function test_prediction(filename, delta)
% TEST_PREDICTION - 快速测试AR预测编码流程
%
%   test_prediction()           % 使用默认参数
%   test_prediction(filename)  % 指定图像文件
%   test_prediction(filename, delta)  % 指定图像和量化步长
%
% Input:
%   filename - 图像文件路径 (默认: 'Foyer.jpg')
%   delta    - 量化步长 (默认: 20)

if nargin < 1
    filename = 'Foyer.jpg';
end
if nargin < 2
    delta = 20;
end

image = imread(filename);
[r, g, b] = Cal_para(filename);
[err_r, err_g, err_b, Rmed, Gmed, Bmed] = predictionRGB_nocenter(filename, r, g, b, delta);
reconstructed_image = predictionRGB_inv_nocenter(err_r, err_g, err_b, r, g, b, delta, Rmed, Gmed, Bmed);

% 计算MSE和PSNR
mse_rgb = mean((double(image(:)) - double(reconstructed_image(:))).^2);
psnr_rgb = 10 * log10(255^2 / mse_rgb);

% 计算各通道熵
for c = 1:3
    channel = uint8(err_r(:,:,c));
    h = imhist(channel); p = h / sum(h);
    p = p(p > 0);
    Entropy_vals(c) = -sum(p .* log2(p));
end

% 显示结果
fprintf('MSE: %.2f\n', mse_rgb);
fprintf('PSNR: %.2f dB\n', psnr_rgb);
fprintf('Entropy - R: %.2f, G: %.2f, B: %.2f\n', Entropy_vals(1), Entropy_vals(2), Entropy_vals(3));

% 显示残差图像
err_img = cat(3, min(max(err_r,0),255), min(max(err_g,0),255), min(max(err_b,0),255));
figure;
imshow(err_img);
title('量化残差');

% 显示重建图像
figure;
imshow(reconstructed_image);
title('重建图像');
end
