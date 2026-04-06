function [r,g,b] = Cal_para2(filename)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
img = imread(filename);
img = double(img);

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
[M,N] = size(R);
Rp = padarray(R, [1,1], 'symmetric');
Gp = padarray(G, [1,1], 'symmetric');
Bp = padarray(B, [1,1], 'symmetric');

R_left = Rp(2:M+1, 1:N);
R_top = Rp(1:M,2:N+1);
G_left = Gp(2:M+1, 1:N);
G_top = Gp(1:M,2:N+1);
B_left = Bp(2:M+1, 1:N);
B_top = Bp(1:M,2:N+1);

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
%15
% alulate the ovariane terms for R, G, and B
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


%18
Kr = [RR00,RR11,0,0,0,0;
      RR11,RR00,0,0,0,0;
      0,0,GG00,GG11,0,0;
      0,0,GG11,GG00,0,0;
      0,0,0,0,BB00,BB11;
      0,0,0,0,BB11,BB00];

Kg =[RR00,RR11,0,0,0,0;
     RR11,RR00,0,0,0,0;
     0,0,GG00,GG11,0,0,;
     0,0,GG11,GG00,0,0;
     0,0,0,0,BB00,BB11;
     0,0,0,0,BB11,BB00];


Kb =[RR00,RR11,0,0,0,0;
     RR11,RR00,0,0,0,0;
     0,0,GG00,GG11,0,0;
     0,0,GG11,GG00,0,0;
     0,0,0,0,BB00,BB11;
     0,0,0,0,BB11,BB00,];


Yr = [RR10,RR01,RG10,RG01,RB10,RB01]';
Yg = [GR10,GR01,GG10,GG01,GB10,GB01]';
Yb = [BR10,BR01,BG10,BG01,BB10,BB01]';


r = Kr \ Yr;

g = Kg \ Yg;

b = Kb \ Yb;
end