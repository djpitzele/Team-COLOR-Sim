% File name
image_name = "thing.png";

% Directory to file
directory = "C:\Users\YOUR USER HERE\Desktop\test_images";

% Full directory to image
full_directory = fullfile(directory, image_name);

% Load in image
my_image = imread(full_directory);