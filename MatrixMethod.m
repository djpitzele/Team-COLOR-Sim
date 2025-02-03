clear all; close all; clc;
% Constructs a matrix that moves data from RGB all the way
% to colorblind opponent space. Applies this matrix to real images to
% simulate how a colorblind person would see them.

%% Settings
% image_name = "color_wheel.png";
image_name = "butterflies.jpg";
red_shift = 0; % negative
green_shift = 0; % positive

%% Shifting the image
original_img_sRGB = imread("test_images/" + image_name);
original_img_sRGB = im2double(original_img_sRGB);
% sRGB -> linear RGB
img_RGB = rgb2lin(original_img_sRGB);

% Apply CVD shift to image
opp2rgb = (gen_rgb2opp_mat(0, 0))^-1;
rgb2opp_cvd = gen_rgb2opp_mat(red_shift, green_shift);
size1 = size(img_RGB,1);
size2 = size(img_RGB,2);
img_opp = zeros(size1,size2,3);
mod_RGB = zeros(size1,size2,3);

for x = 1:size1
    for y = 1:size2
        img_opp(x,y,:) = rgb2opp_cvd * squeeze(img_RGB(x,y,:));
        mod_RGB(x,y,:) = opp2rgb * squeeze(img_opp(x,y,:));
    end
end

% linear RGB -> sRGB
mod_sRGB = lin2rgb(mod_RGB);

% Numerically test difference of images
% for i = 1:size(mod_sRGB, 1)
%     for j = 1:size(mod_sRGB, 2)
%         if (round(mod_sRGB(i, j) - original_img_sRGB(i, j), 2, 'significant') > 0.02)
%             display("wrong " + i + " " + j)
%             display(round(mod_sRGB(i, j) - original_img_sRGB(i, j), 2, 'significant'))
%             display(mod_sRGB(i, j))
%             display(original_img_sRGB(i, j))
%            
%         end
%     end
% end

figure
imshowpair(original_img_sRGB,mod_sRGB,'montage')