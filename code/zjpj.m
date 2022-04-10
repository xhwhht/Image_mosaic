Copyright (c) 2011, Edward Wiggin
All rights reserved.
Copyright (c) 2021 Macrad

clc;clear;close all;


%读入原图 （左 右）
img1=imread('a1.jpg');
img2=imread('a2.jpg');



%查找它们的SIFT特征,并返回匹配点对
[des1, des2] = siftMatch(img1, img2);

%为单应矩阵过滤匹配准备参数
pts1=des1';
pts2=des2';
%单应矩阵过滤匹配
[Ht, matchs] = findHomography(pts1,pts2);
pts1=pts1(:,matchs);%取出内点
pts2=pts2(:,matchs);
des1=pts1';%格式转回
des2=pts2';
%%
%画出Ransac算法后的匹配对
img3 = appendimages(img1,img2);
figure('Position', [100 100 size(img3,2) size(img3,1)]);
colormap('gray');
imagesc(img3);
title('细匹配')
hold on;
cols1 = size(img1,2);
for i = 1: size(des1,1)
    line([des1(i,1) des2(i,1)+cols1], ...
         [des1(i,2) des2(i,2)], 'Color', 'c');
end

%%
[~,W,~]=size(img1);      %图像大小
l_r=W-des1(2,1)+des2(2,1);%只取水平方向（第一个匹配点）重叠宽度

%直接拼接%
[H,W,~]=size(img1);
L=round(W+1-l_r);             %左边起点
R=round(W);                   %右边尾点
n=round(R-L+1);               %重叠宽度, n=拼缝宽;
im=[img1,img2(:,n:W,:)];      %1全图+2的后面部分
% figure;imshow(im);title('直接拼接图');


%根据之前H矩阵找到的两幅图的重叠（l_r）部分
A=img1(:,L:R,:);
B=img2(:,1:n,:);
%A、B 是对应在两幅图中的重叠区域
[ma,na,ka]=size(A);
I1=rgb2gray(A);%转换为灰度图像
I1=double(I1);%转换为双精度
v1=0;
I2= rgb2gray(B);
I2=double(I2);
v2=0;
for i=1:ma
    for j=1:na
    v1=v1+I1(i,j);%所有亮度值相加（和）
    v2=v2+I2(i,j);
    end
end

%亮度比例，并按比例调整第二个图
k=v1/v2;
BB2=img2(:,n:W,:)*k;       %乘比值
im2=[img1,BB2];            %拼接

%用的渐入渐出融合即：距离权重融合%
D=im2;%继承前图（亮度）                                
for j=1:n
d=1-(j)/n;%disp(d);% 距离权重
D(1:H,L+j,:)=d*A(1:H,j,:)+(1-d)*B(1:H,j,:)*k;
end
D=uint8(D);
figure;imshow(D);title('（亮度自适应）柱面投影的调整亮度后渐入渐出融合拼接图');%4

