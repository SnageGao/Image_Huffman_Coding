% clear all;
% 定义参数
I = rgb2gray(imread( '0x0002.png'));		% 读取图像
Filepath = 'Huffman_image.bin';         % 存储文件路径

% 编码
[ Code, Info] = Huffman_code( I, Filepath);
% 解码
J = Huffman_decode( Filepath);

% 画图
figure(1);
subplot(1,3,1);imshow(I);title('原始图像');
subplot(1,3,2);imhist(I);title('原始图像直方图');
subplot(1,3,3);imshow(J);title('最终图像');

% 显示编码信息
disp( ['平均码长为: Lavg = ',num2str( Info.ACLength)]);
disp( ['信息熵为:   H(u) = ',num2str( Info.Entorpy)]);
disp( ['编码效率为: η =   ',num2str( Info.CodeRate)]);
disp( ['压缩比为:   C =    ',num2str( Info.CompRate)]);