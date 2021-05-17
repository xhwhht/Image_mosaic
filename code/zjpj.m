clc;clear;close all;


%����ԭͼ ���� �ң�
img1=imread('a1.jpg');
img2=imread('a2.jpg');



%�������ǵ�SIFT����,������ƥ����
[des1, des2] = siftMatch(img1, img2);

%Ϊ��Ӧ�������ƥ��׼������
pts1=des1';
pts2=des2';
%��Ӧ�������ƥ��
[Ht, matchs] = findHomography(pts1,pts2);
pts1=pts1(:,matchs);%ȡ���ڵ�
pts2=pts2(:,matchs);
des1=pts1';%��ʽת��
des2=pts2';
%%
%����Ransac�㷨���ƥ���
img3 = appendimages(img1,img2);
figure('Position', [100 100 size(img3,2) size(img3,1)]);
colormap('gray');
imagesc(img3);
title('ϸƥ��')
hold on;
cols1 = size(img1,2);
for i = 1: size(des1,1)
    line([des1(i,1) des2(i,1)+cols1], ...
         [des1(i,2) des2(i,2)], 'Color', 'c');
end

%%
[~,W,~]=size(img1);      %ͼ���С
l_r=W-des1(2,1)+des2(2,1);%ֻȡˮƽ���򣨵�һ��ƥ��㣩�ص����

%ֱ��ƴ��%
[H,W,~]=size(img1);
L=round(W+1-l_r);             %������
R=round(W);                   %�ұ�β��
n=round(R-L+1);               %�ص����, n=ƴ���;
im=[img1,img2(:,n:W,:)];      %1ȫͼ+2�ĺ��沿��
% figure;imshow(im);title('ֱ��ƴ��ͼ');


%����֮ǰH�����ҵ�������ͼ���ص���l_r������
A=img1(:,L:R,:);
B=img2(:,1:n,:);
%A��B �Ƕ�Ӧ������ͼ�е��ص�����
[ma,na,ka]=size(A);
I1=rgb2gray(A);%ת��Ϊ�Ҷ�ͼ��
I1=double(I1);%ת��Ϊ˫����
v1=0;
I2= rgb2gray(B);
I2=double(I2);
v2=0;
for i=1:ma
    for j=1:na
    v1=v1+I1(i,j);%��������ֵ��ӣ��ͣ�
    v2=v2+I2(i,j);
    end
end

%���ȱ������������������ڶ���ͼ
k=v1/v2;
BB2=img2(:,n:W,:)*k;       %�˱�ֵ
im2=[img1,BB2];            %ƴ��

%�õĽ��뽥���ںϼ�������Ȩ���ں�%
D=im2;%�̳�ǰͼ�����ȣ�                                
for j=1:n
d=1-(j)/n;%disp(d);% ����Ȩ��
D(1:H,L+j,:)=d*A(1:H,j,:)+(1-d)*B(1:H,j,:)*k;
end
D=uint8(D);
figure;imshow(D);title('����������Ӧ������ͶӰ�ĵ������Ⱥ��뽥���ں�ƴ��ͼ');%4

