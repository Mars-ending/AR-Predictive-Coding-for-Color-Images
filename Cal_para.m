function [r,g,b] = Cal_para(img)
% CAL_PARA - Calculate AR coefficients for RGB image
%
% Input:
%   img - Either:
%         * String/char: path to image file
%         * Matrix: RGB image data (HxWx3)
%
% Output:
%   r - R channel coefficients (6x1)
%   g - G channel coefficients (7x1)
%   b - B channel coefficients (8x1)

% Handle both file path and image data input
if ischar(img) || isstring(img)
    % If img is a filename, read it
    img = imread(img);
    img = double(img);
elseif isnumeric(img)
    % If img is already image data, use it directly
    img = double(img);
else
    error('Input must be either image filename (string) or image data (matrix)');
end

% Validate image format
if ndims(img) ~= 3 || size(img, 3) ~= 3
    error('Image must be RGB color image (HxWx3)');
end

% Extract RGB channels
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
[M,N] = size(R);

% Validate minimum size for coefficient calculation
if M < 3 || N < 3
    error('Image/block too small for AR coefficient calculation (minimum 3x3)');
end

% Mirror boundary extension
Rp = padarray(R, [1,1], 'symmetric');
Gp = padarray(G, [1,1], 'symmetric');
Bp = padarray(B, [1,1], 'symmetric');

% Extract neighbor pixels
R_left = Rp(2:M+1, 1:N);
R_top = Rp(1:M,2:N+1);
G_left = Gp(2:M+1, 1:N);
G_top = Gp(1:M,2:N+1);
B_left = Bp(2:M+1, 1:N);
B_top = Bp(1:M,2:N+1);

% Calculate autocorrelation terms
RR00 = mean(mean(R.^2));
RR01 = mean(mean(R.*R_top));
RR10 = mean(mean(R.*R_left));
RR11 = mean(mean(R_left .* R_top));

GG00 = mean(mean(G.^2));
GG01 = mean(mean(G.*G_top));
GG10 = mean(mean(G.*G_left));
GG11 = mean(mean(G_left .* G_top));

BB00 = mean(mean(B.^2));
BB01 = mean(mean(B.*B_top));
BB10 = mean(mean(B.*B_left));
BB11 = mean(mean(B_left .* B_top));

RG00 = mean(mean(R.*G));
RB00 = mean(mean(R.*B));
GB00 = mean(mean(G.*B));

% Calculate the covariance terms for R, G, and B
RG01 = mean(mean(R.*G_top));
RG10 = mean(mean(R.*G_left));
RG11 = mean(mean(R_left.* G_top));

RB01 = mean(mean(R.*B_top));
RB10 = mean(mean(R.*B_left));
RB11 = mean(mean(R_left.* B_top));

GR01 = mean(mean(G.*R_top));
GR10 = mean(mean(G.*R_left));
GB01 = mean(mean(G.*B_top));
GB10 = mean(mean(G.*B_left));
GR11 = mean(mean(R_top.* G_left));
GB11 = mean(mean(G_left.* B_top));

BR01 = mean(mean(B.*R_top));
BR10 = mean(mean(B.*R_left));
BG01 = mean(mean(B.*G_top));
BG10 = mean(mean(B.*G_left));
BR11 = mean(mean(R_top.* B_left));
BG11 = mean(mean(G_top.* B_left));

% Build coefficient matrices
Kr = [RR00,RR11,RG00,RG11,RB00,RB11;
      RR11,RR00,GR11,RG00,BR11,RB00;
      RG00,GR11,GG00,GG11,GB00,GB11;
      RG11,RG00,GG11,GG00,BG11,GB00;
      RB00,BR11,GB00,BG11,BB00,BB11;
      RB11,RB00,GB11,GB00,BB11,BB00];

Kg =[RR00,RR11,RG00,RG11,RB00,RB11,RR10;
     RR11,RR00,GR11,RG00,BR11,RB00,RR01;
     RG00,GR11,GG00,GG11,GB00,GB11,RG10;
     RG11,RG00,GG11,GG00,BG11,GB00,RG01;
     RB00,BR11,GB00,BG11,BB00,BB11,RB10;
     RB11,RB00,GB11,GB00,BB11,BB00,RB01;
     RR10,RR01,RG10,RG01,RB10,RB01,RR00];

Kb =[RR00,RR11,RG00,RG11,RB00,RB11,RR10,GR10;
     RR11,RR00,GR11,RG00,BR11,RB00,RR01,GR01;
     RG00,GR11,GG00,GG11,GB00,GB11,RG10,RG10;
     RG11,RG00,GG11,GG00,BG11,GB00,RG01,GG01;
     RB00,BR11,GB00,BG11,BB00,BB11,RB10,GB10;
     RB11,RB00,GB11,GB00,BB11,BB00,RB01,GB01;
     RR10,RR01,RG10,RG01,RB10,RB01,RR00,RG00;
     GR10,GR01,GG10,GG01,GB10,GB01,RG00,GG00];

% Build right-hand side vectors
Yr = [RR10,RR01,RG10,RG01,RB10,RB01]';
Yg = [GR10,GR01,GG10,GG01,GB10,GB01,RG00]';
Yb = [BR10,BR01,BG10,BG01,BB10,BB01,RB00,GB00]';

% Solve for coefficients with numerical stability check
try
    r = Kr \ Yr;
    g = Kg \ Yg;
    b = Kb \ Yb;
catch ME
    if contains(ME.message, 'singular') || contains(ME.message, 'badly conditioned')
        % Add small regularization for numerical stability
        lambda = 1e-6;
        fprintf('Warning: Adding regularization for numerical stability\n');
        r = (Kr + lambda * eye(size(Kr))) \ Yr;
        g = (Kg + lambda * eye(size(Kg))) \ Yg;
        b = (Kb + lambda * eye(size(Kb))) \ Yb;
    else
        rethrow(ME);
    end
end

end
