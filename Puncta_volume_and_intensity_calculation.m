% This code is for the calculation of size (change) of individual puncta in
% Figure 3E
% A filepath containing an interested Z-stack tif file should be filled
% into line 10 (subfolder), while the names of the stack tif files in the timelapse should be filed into
% line 8 (name1).And the bin of the stack images should be manually filed
% into line 2. The threshold values for cell mask and puncta mask (in Line 47 and 55) should be changed related to the intensity and signal-to-background ratio of fluorescence signals
% 
%
clear all
%% Import the image stack and the parameters
name1 = '561nm_100ms_2V_T3';% filed the file names of the stack images to the different time points in timelapse imaging
bin = 2;% filed the bin
subfolder = 'D:\Yifei Du backup\20210505 Yifei Du\WT peptide\Cell 3\084923_stack\';% filed the file path
basepath = '';
pathname = [basepath subfolder];
mkdir([pathname 'analysis\' name1]);
% import tif file
FileTif=[pathname name1 '.tif'];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
mov=zeros(nImage,mImage,NumberImages,'uint16');
start_frame = 1;

TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
    TifLink.setDirectory(i);
    mov(:,:,i)=TifLink.read();
end
TifLink.close();
bkg = 100*power(bin,2);          % background due to camera bias (100 for bin 1x1)

[~,position_crop] = imcrop(max(mov,[],3));% Select the Crop region (Select a region¡ú right click-crop image, default contrast = [0 1]
mov = double(mov);
mov_crop = [];
for n  = 1:size(mov,3)
    mov_crop(:,:,n) = imcrop(mov(:,:,n),position_crop);% fill in the movie
end

%% set the threshhold for the BW image, and calculate the pixels belonging to the puncta and total intensity of these pixels 
volume = zeros(size(mov_crop,3),1);
intensity = zeros(size(mov_crop,3),1);
% stack-by-stack analysis
for n = 1:size(mov_crop,3);
I = uint16(mov_crop(:,:,n));
graythreshold_cell = 75;% Here is a threshold to the 16-bit images for a cell mask. For our experiments, it should be 50-200
graythreshold_cell_ratio = graythreshold_cell/65535;
I = I-min(I(:))+1;
BW = im2bw(I,graythreshold_ratio);
[L,~] = bwlabel(BW,8); 
L(L~=0) = 1;
pixel_in = I.*uint16(L); 
average_ROI =sum(pixel_in(:))/sum(L(:)) %calculate the average intensity in the selected BW cell mask
Thresh_over_average = 2;% Here is a threshold to the 16-bit images for the puncta mask from the cell mask.
graythreshold_puncta_ratio = Thresh_over_average*average_ROI/65535;
BW = im2bw(I,graythreshold_puncta_ratio);%
[L_puncta,~] = bwlabel(BW,8);  % N¼´ÎªÄ¿±ê¸öÊý

% Dislay the cropped region of interest and the selected puncta in each
% image
figure
subplot(3,1,1)
imshow(max(mov,[],3),[]);hold on
rectangle('Position',position_crop, 'LineWidth',2,'EdgeColor','r');
title('Puncta: selected region')
subplot(3,1,2)
imshow(I,[])
title('Puncta: cropped image')
subplot(3,1,3)
imshow(L_puncta,[])
title(['Puncta: Binarizied image, threshold = ' num2str(Thresh_over_average) 'x average'])
saveas(gca,[[pathname 'analysis\' name1] '\Binarizied image_z = ' num2str(n) '.fig'])
saveas(gca,[[pathname 'analysis\' name1] '\Binarizied image_z = ' num2str(n) '.png'])
close(gcf)

 %calculate the total pixles and average intensity in the selected puncta
 %mask, and write in to the vectors (intensity, volume)
[L_puncta,~] = bwlabel(BW,8);
L_puncta(L_puncta~=0) = 1;
pixel_in = I.*uint16(L_puncta);
intensity(n) = sum(pixel_in(:));
volume(n) = sum(L_puncta(:));
clear I L L_puncta BW
end
% Here calculate the total intensity and pixel number (volume) of the
% selected puntca in all stack images
intensity_total = sum(intensity);
volume_total = sum(volume);
%% export the results to a EXCEL file
xlswrite([pathname 'data_analysis.xlsx'],{'Z order','Volume','Intensity','Total volume','Total intensity','Threshold of the cell','Crop_position','Threshold of the mask over cell average'},name1,['A1']);
xlswrite([pathname 'data_analysis.xlsx'],[1:1:size(mov_crop,3)]',name1,['A2']);
xlswrite([pathname 'data_analysis.xlsx'],volume,name1,['B2']);
xlswrite([pathname 'data_analysis.xlsx'],intensity,name1,['C2']);
xlswrite([pathname 'data_analysis.xlsx'],volume_total,name1,['D2']);
xlswrite([pathname 'data_analysis.xlsx'],intensity_total,name1,['E2']);
xlswrite([pathname 'data_analysis.xlsx'],graythreshold_cell,name1,['F2']);
xlswrite([pathname 'data_analysis.xlsx'],position_crop',name1,['G2']);
xlswrite([pathname 'data_analysis.xlsx'],Thresh_over_average',name1,['H2']);
