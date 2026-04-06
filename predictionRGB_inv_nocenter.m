function RGB_rec = predictionRGB_inv_nocenter(err_r, err_g, err_b, r, g, b, delta, Rmed, Gmed, Bmed)
    [M,N] = size(err_r);

    R_rec = zeros(M,N);
    G_rec = zeros(M,N);
    B_rec = zeros(M,N);

    for i = 1:M
        for j = 1:N
            % 邻域像素（已恢复）
            Rl = R_rec(max(i-1,1), j);
            Rt = R_rec(i, max(j-1,1));
            Gl = G_rec(max(i-1,1), j);
            Gt = G_rec(i, max(j-1,1));
            Bl = B_rec(max(i-1,1), j);
            Bt = B_rec(i, max(j-1,1));

            % 预测（必须与编码器完全一致）
            R_pred = r(1)*Rl + r(2)*Rt + r(3)*Gl + r(4)*Gt + r(5)*Bl + r(6)*Bt;
            G_pred = g(1)*Rl + g(2)*Rt + g(3)*Gl + g(4)*Gt + g(5)*Bl + g(6)*Bt + g(7)*R_pred;
            B_pred = b(1)*Rl + b(2)*Rt + b(3)*Gl + b(4)*Gt + b(5)*Bl + b(6)*Bt + b(7)*R_pred + b(8)*G_pred;


            % 恢复像素值
            R_rec(i,j) = R_pred + delta * err_r(i,j);
            G_rec(i,j) = G_pred + delta * err_g(i,j);
            B_rec(i,j) = B_pred + delta * err_b(i,j);
        end
    end

%decentralization
R = R_rec + Rmed;
G = G_rec + Gmed;
B = B_rec + Bmed;
RGB_rec = cat(3, min(max(R,0),255), min(max(G,0),255), min(max(B,0),255));
RGB_rec = uint8(RGB_rec);
end
