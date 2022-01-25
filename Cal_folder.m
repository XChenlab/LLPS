%% ����������һ���ļ����е�����ͼƬ
% ˵����
% 0. ��֤��������ļ�����ֻ��.tif�ļ�(�ó���.m�ļ����÷���ͼƬ�ļ�����)
%     ����ǰ���ԣ�����ԭͼ�����Ϻ�(���������ͼ)����������Ķ���
%                            ���������ϲ��ͼ(����ϰ�)������30��'sobel'��Ϊ'canny'��
%     sobel��canny��������Ե������ӣ����߸����ڼ������Ե(�������õ����)
%    ����ʱ��鿴ÿһ��ͼƬ��ͼ�������(ʹ��ɫ���ǲ��־�����Һ�����)��ȡ����55-60��ע�ͣ�������һ��
%    (ȡ��ע�ͷ��������ѡ��55-60�����֣�����ݼ�Ctrl+T���ָ�ע��ΪCtrl+R)
%    (����ʱ����Ҫ��ÿһ��ͼ��Ļ���ע�͵���ʾͼƬ���裬�����ٶȻ��һЩ)
% 1. ���иó���(��ݼ�F5)����������ʾѡ��ͼƬ�ļ������ļ���
% 2. �ȴ����н�������Command Window�е������н��
% 3. �ɽ�command window�н������ճ����Excel�����ݷ����Դ���(�ָ���ΪӢ��ð��)
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
