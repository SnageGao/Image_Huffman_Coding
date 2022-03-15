% 输入：Filepath (String) 为编码文件路径
% 输出：Image_final [m*n (double)] 为还原图像且为黑白图像
% 函数功能：将路径对应文件进行哈夫曼变长解码，还原出图像
function Image_final = Huffman_decode( Filepath)

% 读取文件
File = fopen( Filepath,'r');    % 以读模式打开文件
Code = fread( File,'*uint8');   % 以uint8读入文件内容
fclose( File);


% 提取文件头得到图像信息
Code_info = double( Code(1:6));     % 先提取前6个数
head_length = Code_info(1)*256 + Code_info(2);  % 得到文件头长度
Image_H =  Code_info(3)*256 + Code_info(4);     % 得到图像高度
Image_W =  Code_info(5)*256 + Code_info(6);     % 得到图像宽度


% 从文件头中获取编码表
Code_table = Code( 7: head_length); % 根据文件头长度提取出编码表的信息
Uint_table = repmat( uint8(0), 1, length( Code_table)*8);
for index = 0: length( Code_table)-1
    Uint_table( index*8 + (1:8)) = bitget( Code_table(index+1),(8:-1:1));
end             % 将编码表byte按位展开为bit序列

% 生成解码表
Table_inverse = uint8([]);  % 定义解码表
point = 1;        % 定义指针
value = uint8(1); % 定义解码表的值
while point < length( Code_table)
    len = double( Code_table( point));      % 获取当前值对应码字的长度
    table = Uint_table( point*8+1: point*8+len);    % 根据码字长度提取码字
    index = double( [1,table]) * (2.^(len:-1:0))';  % 根据码字得到解码表索引
    Table_inverse( index) = value;          % 给解码表对应位置赋值
    
    point = point + ceil( len/8) + 1;   % 指针平移
    value = value + 1;                  % 值自加
end

% 从编码主题中获取图像
Code_image = Code( head_length+1: end); % 获取主体序列
Uint_image = repmat( uint8(0), 1, length( Code_image)*8);
for index = 0: length( Code_image)-1
    Uint_image( index*8 + (1:8)) = bitget( Code_image(index+1),(8:-1:1));
end             % 将图像byte按位展开为bit序列

Image = repmat( uint8(0), 1, Image_H*Image_W);  % 定义图像一维序列
im_point = 1;   % 定义指针
code_value = 1; % 定义码字值
for bit_point = 1: length( Uint_image)
    if im_point > Image_H*Image_W
        break   % 如果图像矩阵已填满则退出
    end
    code_value = code_value * 2 + double( Uint_image( bit_point));
            % 读一位bit并加到码字后面
    im_value = Table_inverse( code_value);  % 从解码表读取码字索引对应的值
    if im_value ~= 0
        Image( im_point) = im_value - 1;
        im_point = im_point + 1;
        code_value = 1;
        % 如果不为0则这个码字读取完毕，将值填充到图像矩阵，并重置指针和码字
    end
        % 如果为0则继续读取bit
end

Image_final = reshape( Image, Image_H, Image_W);    % 将一维图形根据长宽二维化
