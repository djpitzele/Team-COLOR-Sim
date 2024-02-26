% File name
image_name = "butterflies.jpg";

% Directory to file
% directory = "C:\Users\YOUR USER HERE\Desktop\test_images";
directory = "C:\Users\dpitz\color-sim\Team-COLOR-Sim\test_images";

% Full directory to image
full_directory = fullfile(directory, image_name);

% Load in image
img_RGB = imread(full_directory);
imshow(img_RGB)
whos

% RGB to LMS
% https://arxiv.org/pdf/1711.10662.pdf
rgb_to_lms = [17.8824 43.5161 4.1194; 3.4557 27.1554 3.8671; 0.0300 0.1843 1.4671];

img_RGB = double(img_RGB);
size1 = size(img_RGB,1);
size2 = size(img_RGB,2);
img_LMS = zeros(size1,size2,3);
size(img_LMS,3)
whos
for x = 1:size1
    for y = 1:size2
        img_LMS(x,y) = img_RGB(x,y) * rgb_to_lms
    end
end

% why is is erroring?