% 输入：Image [m*n (double)] 为目标图像且为黑白图像
%       Filepath (String) 为编码文件保存路径
% 输出：Code [](uint8) 为哈夫曼编码的输出结果，为uint8的数组
%       Info (struct) 为计算得到的编码各指标分析数值结构体
% 函数功能：将输入的图像进行哈夫曼变长编码压缩，将编码结果写入路径文件，
%           并返回编码性能分析结果。
function [ Code, Info] = Huffman_code( Image, Filepath)
[ H, W] = size(Image);


% 计算直方图并排序
hist = imhist(Image) / (H*W);           % 计算图像的概率直方图
[ proba, index] = sort( hist);          % 对其从小到大排序并返回索引位置
Array_index = index( proba~=0 );
Array_proba = proba( proba~=0 );        % 保留序列的非零值及其索引
Array_index = num2cell( Array_index);   % 将索引转换为元胞类型


% 计算编码表
Table = cell( 256, 1);                  % 定义编码表
while length( Array_proba)>1    % 进入循环，直到概率直方序列相加为一个数
    index1 = Array_index{1};            
    index2 = Array_index{2};            % 获得当前的概率序列最小的两个索引元胞
    Table( index1) = cellfun(@(x) [x,uint8(0)], Table(index1), 'UniformOutput',false);
    Table( index2) = cellfun(@(x) [x,uint8(1)], Table(index2), 'UniformOutput',false);
            % 分别在这两个索引元胞的每个元素对应的编码序列后边加上‘1’或‘0’
    
    Array_proba = [sum(Array_proba(1:2));Array_proba(3:end)];
    Array_index = {[index1,index2],Array_index{3:end}};
            % 将最小的两个概率相加，将对应索引合并进一个元胞中
    
    [ Array_proba, order] = sort( Array_proba);
    Array_index = Array_index( order);
            % 对处理后的序列重新排序
end
Table = cellfun(@(x) x(end:-1:1), Table, 'UniformOutput', false);
        % 将得到的编码序列反转，生成前缀码


% 编码替换
Code_uint8 = [];
for Pixel = Image(:)    % 将图像一维化，然后逐一替换
    Code_uint8 = [ Code_uint8, Table{ Pixel+1}];
end
Code_str = getbytes( Code_uint8);   % 将生成的bit串合并成为byte（uint8）数组


% 创建文件头
Code_table = [];
Table_length = zeros(1,256);
for index = 1:256           % 将编码表打包进文件头，格式为 [ 码字1长度 码字1][ 码字2长度 码字2]……
    Table_length( index) = length( Table{ index});
    value = getbytes( Table{ index});
    Code_table = [Code_table, uint8( Table_length(index)), value];
end
length_head = uint16( length( Code_table)+6);   % 计算文件头的长度
Code_info = uint8([ bitshift(length_head,-8), mod(length_head,256)]);
Code_H = uint8([ bitshift(H,-8), mod(H,256)]);
Code_W = uint8([ bitshift(W,-8), mod(W,256)]);  % 将长度、图片的长宽信息转换为6个uint8
Code_head = [ Code_info, Code_H, Code_W, Code_table];   % 文件头合并


% 合并编码并写入文件
Code = [Code_head, Code_str];   % 将文件头和编码内容合并
File = fopen( Filepath,'w');    % 以写模式创建与打开文件
fwrite( File, Code, 'uint8');   % 以uint8的形式写入文件
fclose( File);


% 计算编码性能
Info.ACLength = Table_length * hist;    % 计算平均码长
Info.Entorpy = -log2( proba( proba~=0 )')* proba( proba~=0 );    % 计算信息熵
Info.CodeRate = Info.Entorpy / Info.ACLength;    % 计算编码效率
Info.CompRate = Info.ACLength / 8;      % 计算压缩比





% 输入：Uint [] (uint8) 为bit序列，每一个数为1或者0
% 输出：String [] (uint8) 为byte序列，每一个数范围为0~255
% 函数功能：将输入的bit序列密集化，每8个数合成一个数，生成byte序列。
function String = getbytes( Uint)

bit_num = length( Uint);        % 计算bit序列长度
byte_num = ceil( bit_num / 8);  % 计算byte序列长度
Uint = [Uint, uint8(ones(1,byte_num*8-bit_num))];   % 将bit序列长度补为8的整倍数
String = [];
for point = 0: byte_num-1       % 进入循环
    charac = uint8(0);
    for bit = 1: 8          % 取出8个数按照前后顺序合成一个数
        index = point*8 + bit;
        flag = bitshift( Uint(index), 8-bit, 'uint8');
        charac = bitor( charac, flag, 'uint8');
    end
    String( point+1) = charac;  % 将这个数加入序列
end
