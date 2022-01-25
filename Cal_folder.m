%% Batch analysis for quantification of liqid droplets area in imaging assay.
%    For analysing all images in the same folder
%    Only *.tif files should be in the selected folder path
%    In Line 25: 
%    For images with decent singal-to-background ratio, using "sobel" for edge detection;
%    For images with lower singal-to-background ratio, using "canny" for edge detection.
%    Line 48-57 is for checking the performance of the analysis
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
