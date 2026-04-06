function [err_r, err_g, err_b, Rmed, Gmed, Bmed] = Predict_RGB(filename, r, g, b, delta)

% Predicts the image and quantizes the
% function outputs the residuals and the average of the pixels in each layer.

img = double(imread(filename));
R = img(:,:,1); G = img(:,:,2); B = img(:,:,3);
[M,N] = size(R);

% calculate the mean value
Rmed = mean(R(:));
Gmed = mean(G(:));
Bmed = mean(B(:));
Rz = R - Rmed; Gz = G - Gmed; Bz = B - Bmed;

% initial error matrix
err_r = zeros(M,N);
err_g = zeros(M,N);
err_b = zeros(M,N);

% initial prediction
Rrec = zeros(M,N);
Grec = zeros(M,N);
Brec = zeros(M,N);

for i = 1:M
    for j = 1:N
        % boundary
        Rl = Rrec(max(i-1,1), j);
        Rt = Rrec(i, max(j-1,1));
        Gl = Grec(max(i-1,1), j);
        Gt = Grec(i, max(j-1,1));
        Bl = Brec(max(i-1,1), j);
        Bt = Brec(i, max(j-1,1));

        % predict
        R_pred = r(1)*Rl + r(2)*Rt + r(3)*Gl + r(4)*Gt + r(5)*Bl + r(6)*Bt;
        G_pred = g(1)*Rl + g(2)*Rt + g(3)*Gl + g(4)*Gt + g(5)*Bl + g(6)*Bt + g(7)*R_pred;
        B_pred = b(1)*Rl + b(2)*Rt + b(3)*Gl + b(4)*Gt + b(5)*Bl + b(6)*Bt + b(7)*R_pred + b(8)*G_pred;

        %
        r_val = Rz(i,j);
        g_val = Gz(i,j);
        b_val = Bz(i,j);

        % calculate error and quantize
        err_r(i,j) = round((r_val - R_pred) / delta);
        err_g(i,j) = round((g_val - G_pred) / delta);
        err_b(i,j) = round((b_val - B_pred) / delta);

        % update the rec
        Rrec(i,j) = R_pred + delta * err_r(i,j);
        Grec(i,j) = G_pred + delta * err_g(i,j);
        Brec(i,j) = B_pred + delta * err_b(i,j);
    end
end
end
