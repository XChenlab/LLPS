%% 批处理：分析一个文件夹中的所有图片
% 说明：
% 0. 保证待处理的文件夹中只有.tif文件(该程序.m文件不用放在图片文件夹里)
%     运行前调试：对于原图照明较好(整体较亮的图)，程序无需改动；
%                            对于照明较差的图(整体较暗)，将第30行'sobel'改为'canny'；
%     sobel和canny是两个边缘检测算子，后者更适于检测弱边缘(照明不好的情况)
%    调试时需查看每一个图片的图像处理情况(使粉色覆盖部分尽量与液滴相符)，取消第55-60行注释，再运行一遍
%    (取消注释方法：鼠标选择55-60行文字，按快捷键Ctrl+T；恢复注释为Ctrl+R)
%    (运行时不需要看每一步图像的话，注释掉显示图片步骤，运行速度会快一些)
% 1. 运行该程序(快捷键F5)，按弹出提示选择图片文件所在文件夹
% 2. 等待运行结束，在Command Window中弹出所有结果
% 3. 可将command window中结果复制粘贴至Excel，数据分栏以处理(分隔符为英文冒号)
%% choosing the folder
file_path = uigetdir();
img_path_list = dir(file_path);
img_num = length(img_path_list);

%% vectors for output
disp(['Figure No.:        ','File Name:        ','Num of drops:        ','Total Area:        ', ...
    'Mean Area:        ','Std:        ']);

%% data processing
if img_num > 2
    for j = 3: img_num
        image_name = img_path_list(j).name;
        image = imread(strcat(file_path,'\', image_name));
       %% Data for processing
        Gray = rgb2gray(image);  % trasform to gray img
       %% processing
        BW1 = edge(Gray, 'sobel',[],'nothinning');     % edge detection using sobel
        se90 = strel('line', 10, 90);
        se0 = strel('line', 10, 0);
        BWdil = imdilate(BW1, [se90 se0]);     % dilate to close edges
        BWfill = imfill(BWdil, 'holes');     % fill holes
        D = -bwdist(~BWfill);    % Euclidean transformation, cells white
        DD = imhmin(D,1);    % inhibiting watershed oversegmentation
        L = watershed(DD);    % watershed segmentation
        BWfill(L == 0) = 0;    % setting watershed areas to 0
        % BWfill = bwareaopen(BWfill, 100);    % deleting small areas (unecessary for clean background)
        seD = strel('disk', 6);
        BWero = imerode(BWfill, seD);     % erode
        % figure, imshow(BWdil)
        % figure, imshow(BWfill)

       %% calculations
        Calculations = regionprops(BWero, 'Area');
        Area_List = cell2mat(struct2cell(Calculations));     % List of areas
        Total_Area = sum(Area_List);     % total area of all liquid drops
        Mean_Area = mean(Area_List);     % average area of all drops
        Num_drops = length(Area_List);     % number of liquid drops
        Std_Area = std(Area_List);     % standard deviation of liquid drop areas
        
       %% display
        warning('off', 'images:initSize:adjustingMag');
        figure, imshowpair(Gray, BWero)     % magneta as calculated area
        title([num2str(Num_drops), 'Drops: ', ...
            'Total=', num2str(Total_Area), ...
            '; Mean=', num2str(Mean_Area), ...
            '; Std=', num2str(Std_Area)]);
        xlabel(strcat(image_name));
        disp([num2str(j-2),':   ', strcat(image_name), ':   ', num2str(Num_drops), ':   ', ...
             num2str(Total_Area), ':   ',  num2str(Mean_Area), ':   ',  num2str(Std_Area)]);
        
    end
end
