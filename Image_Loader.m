% File name
image_name = "butterflies.jpg";

% Directory to file
% directory = "C:\Users\YOUR USER HERE\Desktop\test_images";
directory = "C:\Users\dpitz\color-sim\Team-COLOR-Sim\test_images";

% Full directory to image
full_directory = fullfile(directory, image_name);

% Load in image
img_RGB = imread(full_directory);


% sRGB to linear RGB
img_RGB = rgb2lin(img_RGB);
img_RGB = im2double(img_RGB);

% RGB to XYZ (CIE 1931 edition)
img_XYZ = rgb2xyz(img_RGB);


% XYZ to LMS
xyz_to_lms = [0.38971 0.68898 -0.07868;
              -0.22981 1.18340 0.04641;
              0 0 1];

size1 = size(img_RGB,1);
size2 = size(img_RGB,2);
img_LMS = zeros(size1,size2,3);
mod_XYZ = zeros(size1,size2,3);
for x = 1:size1
    for y = 1:size2
        img_LMS(x,y,:) = xyz_to_lms * squeeze(img_XYZ(x,y,:));
        img_LMS(x,y,1) = 0;
        mod_XYZ(x,y,:) = squeeze(img_LMS(x,y,:));
    end
end

% going back
mod_RGB = xyz2rgb(mod_XYZ);
imshowpair(img_RGB,mod_RGB,'montage')