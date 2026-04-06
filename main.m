%% main.m
% Project: Auto-Regressive Predictive Coding for RGB Images

% This script implements both global and local AR predictive coding
% strategies and compares their performance.

clear; close all; clc;

addpath(pwd);

%load package
pkg load image

%% Configuration Parameters
config = struct();
config.image_path = 'images/tests/pic_tag.jpg    ';  % Change to your test image
config.block_size = 32;                      % Block size for local method
config.overlap = 0;                          % Block overlap (0 = no overlap)
config.delta = 10;                           % Quantization step size
config.save_results = true;                  % Save results to files
config.show_plots = true;                    % Display visualization plots

% Output directories
if ~exist('images/results/', 'dir')
    mkdir('images/results/');
end

fprintf('AR Predictive Coding for Color Images\n');
fprintf('=====================================\n\n');

%% Load and Prepare Image
fprintf('Loading image: %s\n', config.image_path);

try
    original_img = imread(config.image_path);
    if size(original_img, 3) ~= 3
        error('Image must be RGB color image');
    end
    original_img = double(original_img);
    [height, width, ~] = size(original_img);

    fprintf('Image loaded: %dx%d pixels\n', height, width);
    fprintf('Quantization delta: %d\n', config.delta);
catch ME
    error('Failed to load image: %s', ME.message);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GLOBAL METHOD - Single coefficient set for entire image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n GLOBAL METHOD\n');
fprintf('================\n');

tic;
fprintf('Calculating global AR coefficients...\n');

% Calculate global coefficients using Cal_para function
[r_global, g_global, b_global] = Cal_para(config.image_path);

fprintf('Global coefficients calculated (%.2f seconds)\n', toc);

% Display global coefficients
fprintf('\nGlobal AR Coefficients:\n');
fprintf('R: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', r_global);
fprintf('G: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', g_global);
fprintf('B: [%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f]\n', b_global);

tic;
fprintf('\n Performing global prediction...\n');

% Perform global prediction using Predict_RGB function
[err_r_global, err_g_global, err_b_global, Rmed_global, Gmed_global, Bmed_global] = ...
    Predict_RGB(config.image_path, r_global, g_global, b_global, config.delta);

% Reconstruct predicted image from errors and means
predicted_global = zeros(size(original_img));
predicted_global(:,:,1) = err_r_global * config.delta + Rmed_global;
predicted_global(:,:,2) = err_g_global * config.delta + Gmed_global;
predicted_global(:,:,3) = err_b_global * config.delta + Bmed_global;
predicted_global = min(max(predicted_global, 0), 255); % Clamp values

fprintf(' Global prediction completed (%.2f seconds)\n', toc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL METHOD - Block-based coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n LOCAL METHOD\n');
fprintf('===============\n');
fprintf(' Block size: %dx%d pixels\n', config.block_size, config.block_size);

tic;

% Initialize local prediction result
predicted_local = zeros(size(original_img));
error_local = struct('r', zeros(height, width), 'g', zeros(height, width), 'b', zeros(height, width));
means_local = struct('r', zeros(height, width), 'g', zeros(height, width), 'b', zeros(height, width));

% Calculate number of blocks
num_blocks_h = ceil(height / config.block_size);
num_blocks_w = ceil(width / config.block_size);

fprintf(' Processing %d blocks (%dx%d grid)...\n', num_blocks_h * num_blocks_w, num_blocks_h, num_blocks_w);

% Store coefficients for each block
block_coeffs = cell(num_blocks_h, num_blocks_w);

for block_i = 1:num_blocks_h
    for block_j = 1:num_blocks_w
        % Calculate block boundaries
        row_start = (block_i - 1) * config.block_size + 1;
        row_end = min(block_i * config.block_size, height);
        col_start = (block_j - 1) * config.block_size + 1;
        col_end = min(block_j * config.block_size, width);

        % Extract block and save as temporary file for Predict_RGB
        block_img = original_img(row_start:row_end, col_start:col_end, :);
        temp_filename = sprintf('temp_block_%d_%d.png', block_i, block_j);
        imwrite(uint8(block_img), temp_filename);

        % Skip blocks that are too small (less than 8x8)
        if size(block_img, 1) < 8 || size(block_img, 2) < 8
            % Use global coefficients for small blocks
            r_local = r_global;
            g_local = g_global;
            b_local = b_global;
        else
            % Calculate local coefficients for this block
            try
                [r_local, g_local, b_local] = Cal_para(temp_filename);
            catch
                % Fallback to global coefficients if calculation fails
                r_local = r_global;
                g_local = g_global;
                b_local = b_global;
            end
        end

        % Store coefficients
        block_coeffs{block_i, block_j} = struct('r', r_local, 'g', g_local, 'b', b_local);

        % Perform local prediction for this block
        [err_r_block, err_g_block, err_b_block, Rmed_block, Gmed_block, Bmed_block] = ...
            Predict_RGB(temp_filename, r_local, g_local, b_local, config.delta);

        % Store error results
        error_local.r(row_start:row_end, col_start:col_end) = err_r_block;
        error_local.g(row_start:row_end, col_start:col_end) = err_g_block;
        error_local.b(row_start:row_end, col_start:col_end) = err_b_block;

        % Store means (for reconstruction)
        means_local.r(row_start:row_end, col_start:col_end) = Rmed_block;
        means_local.g(row_start:row_end, col_start:col_end) = Gmed_block;
        means_local.b(row_start:row_end, col_start:col_end) = Bmed_block;

        % Reconstruct local prediction
        predicted_local(row_start:row_end, col_start:col_end, 1) = err_r_block * config.delta + Rmed_block;
        predicted_local(row_start:row_end, col_start:col_end, 2) = err_g_block * config.delta + Gmed_block;
        predicted_local(row_start:row_end, col_start:col_end, 3) = err_b_block * config.delta + Bmed_block;

        % Clean up temporary file
        delete(temp_filename);

        % Progress indicator
        if mod((block_i-1)*num_blocks_w + block_j, 10) == 0
            fprintf('Processed %d/%d blocks\n', (block_i-1)*num_blocks_w + block_j, num_blocks_h * num_blocks_w);
        end
    end
end

predicted_local = min(max(predicted_local, 0), 255); % Clamp values
fprintf(' Local prediction completed (%.2f seconds)\n', toc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PERFORMANCE ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n PERFORMANCE ANALYSIS\n');
fprintf('=======================\n');

% Calculate errors (residuals)
residual_global = calculerMatriceErreur(original_img, predicted_global);
residual_local = calculerMatriceErreur(original_img, predicted_local);

% Calculate entropy values
H_original = calc_entropie(uint8(original_img));
H_pred_global = calc_entropie(uint8(predicted_global));
H_pred_local = calc_entropie(uint8(predicted_local));
H_residual_global = calc_entropie(residual_global);
H_residual_local = calc_entropie(residual_local);

% Calculate entropy of quantized errors
H_err_r_global = calc_entropie(uint8(err_r_global + 128)); % Shift for positive values
H_err_g_global = calc_entropie(uint8(err_g_global + 128));
H_err_b_global = calc_entropie(uint8(err_b_global + 128));
H_err_r_local = calc_entropie(uint8(error_local.r + 128));
H_err_g_local = calc_entropie(uint8(error_local.g + 128));
H_err_b_local = calc_entropie(uint8(error_local.b + 128));

H_quantized_global = (H_err_r_global + H_err_g_global + H_err_b_global) / 3;
H_quantized_local = (H_err_r_local + H_err_g_local + H_err_b_local) / 3;

% Calculate MSE
mse_global = mean((original_img(:) - predicted_global(:)).^2);
mse_local = mean((original_img(:) - predicted_local(:)).^2);

% Calculate PSNR
psnr_global = 10 * log10(255^2 / mse_global);
psnr_local = 10 * log10(255^2 / mse_local);

% Display results
fprintf('\nEntropy Analysis:\n');
fprintf('Original image:        %.3f bits/pixel\n', H_original);
fprintf('Global prediction:     %.3f bits/pixel\n', H_pred_global);
fprintf('Local prediction:      %.3f bits/pixel\n', H_pred_local);
fprintf('Global residual:       %.3f bits/pixel\n', H_residual_global);
fprintf('Local residual:        %.3f bits/pixel\n', H_residual_local);
fprintf('Global quantized err:  %.3f bits/pixel\n', H_quantized_global);
fprintf('Local quantized err:   %.3f bits/pixel\n', H_quantized_local);

fprintf('\nQuality Metrics:\n');
fprintf('Global MSE:            %.2f\n', mse_global);
fprintf('Local MSE:             %.2f\n', mse_local);
fprintf('Global PSNR:           %.2f dB\n', psnr_global);
fprintf('Local PSNR:            %.2f dB\n', psnr_local);

fprintf('\nCompression Potential:\n');
fprintf('Global method (residual):   %.1f%% entropy reduction\n', (1 - H_residual_global/H_original) * 100);
fprintf('Local method (residual):    %.1f%% entropy reduction\n', (1 - H_residual_local/H_original) * 100);
fprintf('Global method (quantized):  %.1f%% entropy reduction\n', (1 - H_quantized_global/H_original) * 100);
fprintf('Local method (quantized):   %.1f%% entropy reduction\n', (1 - H_quantized_local/H_original) * 100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if config.show_plots
    fprintf('\n VISUALIZATION\n');
    fprintf('================\n');

    % Main comparison figure
    figure('Name', 'AR Predictive Coding Results', 'Position', [100, 100, 1200, 800]);

    subplot(2, 3, 1);
    imshow(uint8(original_img));
    title('Original Image');

    subplot(2, 3, 2);
    imshow(uint8(predicted_global));
    title(sprintf('Global Prediction\nPSNR: %.2f dB', psnr_global));

    subplot(2, 3, 3);
    imshow(uint8(predicted_local));
    title(sprintf('Local Prediction\nPSNR: %.2f dB', psnr_local));

    subplot(2, 3, 4);
    error_img_global = uint8(abs(original_img - predicted_global) * 3); % Amplify for visibility
    imshow(error_img_global);
    title(sprintf('Global Error (×3)\nMSE: %.2f', mse_global));

    subplot(2, 3, 5);
    error_img_local = uint8(abs(original_img - predicted_local) * 3); % Amplify for visibility
    imshow(error_img_local);
    title(sprintf('Local Error (×3)\nMSE: %.2f', mse_local));

    subplot(2, 3, 6);
    comparison_data = [H_original, H_quantized_global, H_quantized_local, H_residual_global, H_residual_local];
    bar(comparison_data);
    set(gca, 'XTickLabel', {'Original', 'Global Quant', 'Local Quant', 'Global Res', 'Local Res'});
    ylabel('Entropy (bits/pixel)');
    title('Entropy Comparison');
    grid on;

    % Quantized error visualization
    figure('Name', 'Quantized Errors', 'Position', [200, 200, 1000, 600]);

    subplot(2, 3, 1);
    imshow(uint8(err_r_global + 128)); % Shift for display
    title('Global R Channel Errors');

    subplot(2, 3, 2);
    imshow(uint8(err_g_global + 128));
    title('Global G Channel Errors');

    subplot(2, 3, 3);
    imshow(uint8(err_b_global + 128));
    title('Global B Channel Errors');

    subplot(2, 3, 4);
    imshow(uint8(error_local.r + 128));
    title('Local R Channel Errors');

    subplot(2, 3, 5);
    imshow(uint8(error_local.g + 128));
    title('Local G Channel Errors');

    subplot(2, 3, 6);
    imshow(uint8(error_local.b + 128));
    title('Local B Channel Errors');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if config.save_results
    fprintf('\n SAVING RESULTS\n');
    fprintf('=================\n');

    % Save predicted images
    imwrite(uint8(predicted_global), 'images/results/predicted_global.png');
    imwrite(uint8(predicted_local), 'images/results/predicted_local.png');
    imwrite(uint8(abs(original_img - predicted_global)), 'images/results/error_global.png');
    imwrite(uint8(abs(original_img - predicted_local)), 'images/results/error_local.png');

    % Save quantized errors
    imwrite(uint8(err_r_global + 128), 'images/results/quantized_error_r_global.png');
    imwrite(uint8(err_g_global + 128), 'images/results/quantized_error_g_global.png');
    imwrite(uint8(err_b_global + 128), 'images/results/quantized_error_b_global.png');
    imwrite(uint8(error_local.r + 128), 'images/results/quantized_error_r_local.png');
    imwrite(uint8(error_local.g + 128), 'images/results/quantized_error_g_local.png');
    imwrite(uint8(error_local.b + 128), 'images/results/quantized_error_b_local.png');

    % Save numerical results
    results = struct();
    results.config = config;
    results.entropy = struct('original', H_original, 'global_pred', H_pred_global, ...
                           'local_pred', H_pred_local, 'global_residual', H_residual_global, ...
                           'local_residual', H_residual_local, 'global_quantized', H_quantized_global, ...
                           'local_quantized', H_quantized_local);
    results.quality = struct('mse_global', mse_global, 'mse_local', mse_local, ...
                           'psnr_global', psnr_global, 'psnr_local', psnr_local);
    results.coefficients = struct('global', struct('r', r_global, 'g', g_global, 'b', b_global), ...
                                'local', block_coeffs);
    results.errors = struct('global', struct('r', err_r_global, 'g', err_g_global, 'b', err_b_global), ...
                          'local', error_local);
    results.means = struct('global', struct('r', Rmed_global, 'g', Gmed_global, 'b', Bmed_global), ...
                         'local', means_local);

    save('images/results/analysis_results.mat', 'results');

    % Export entropy data to CSV
    entropy_data = [H_original; H_pred_global; H_pred_local; H_residual_global; H_residual_local; H_quantized_global; H_quantized_local];
    entropy_labels = {'Original'; 'Global_Pred'; 'Local_Pred'; 'Global_Residual'; 'Local_Residual'; 'Global_Quantized'; 'Local_Quantized'};

    % Create CSV content
    fid = fopen('images/results/entropy_analysis.csv', 'w');
    fprintf(fid, 'Method,Entropy_bits_per_pixel\n');
    for i = 1:length(entropy_labels)
        fprintf(fid, '%s,%.6f\n', entropy_labels{i}, entropy_data(i));
    end
    fclose(fid);

    % Export quality metrics to CSV
    fid = fopen('images/results/quality_metrics.csv', 'w');
    fprintf(fid, 'Method,MSE,PSNR_dB\n');
    fprintf(fid, 'Global,%.6f,%.6f\n', mse_global, psnr_global);
    fprintf(fid, 'Local,%.6f,%.6f\n', mse_local, psnr_local);
    fclose(fid);

    fprintf('Results saved to images/results/\n');
    fprintf('CSV files created: entropy_analysis.csv, quality_metrics.csv\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SUMMARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n SUMMARY\n');
fprintf('==========\n');
fprintf('Image: %dx%d pixels, Delta: %d\n', height, width, config.delta);
fprintf('Global method - PSNR: %.2f dB, Quantized entropy reduction: %.1f%%\n', ...
        psnr_global, (1 - H_quantized_global/H_original) * 100);
fprintf('Local method  - PSNR: %.2f dB, Quantized entropy reduction: %.1f%%\n', ...
        psnr_local, (1 - H_quantized_local/H_original) * 100);

if psnr_local > psnr_global
    fprintf(' Local method performs better (+%.2f dB PSNR)\n', psnr_local - psnr_global);
else
    fprintf(' Global method performs better (+%.2f dB PSNR)\n', psnr_global - psnr_local);
end

fprintf('\n Analysis complete!\n');
