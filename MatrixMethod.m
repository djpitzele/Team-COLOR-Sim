clear all; close all; clc;
% Constructs a matrix that moves data from RGB all the way
% to colorblind opponent space. Applies this matrix to real images to
% simulate how a colorblind person would see them.

%% Settings
image_name = "color_wheel.png";
% image_name = "butterflies.jpg";
red_shift = 0; % negative
green_shift = 10; % positive

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
mod_RGB1 = zeros(size1,size2,3);

for x = 1:size1
    for y = 1:size2
        img_opp(x,y,:) = rgb2opp_cvd * squeeze(img_RGB(x,y,:));
        mod_RGB1(x,y,:) = opp2rgb * squeeze(img_opp(x,y,:));
    end
end

step_1 = reshape(img_RGB, size1 * size2, 3) * rgb2opp_cvd';
step_2 = step_1 * opp2rgb';
mod_RGB2 = reshape(step_2, size1, size2, 3);

% linear RGB -> sRGB
mod_sRGB1 = lin2rgb(mod_RGB1);
mod_sRGB2 = lin2rgb(mod_RGB2);

% Numerically test difference of images
image_diff(mod_sRGB1, mod_sRGB2)

figure
imshowpair(original_img_sRGB,mod_sRGB1,'montage')