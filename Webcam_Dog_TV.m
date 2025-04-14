clear all; close all; clc; 

% Settings
red_shift = 0; % negative
green_shift = 10; % positive
size1 = 360; % smaller
size2 = 640; % larger
% 1920x1080, 960x540, 640x360, 320x180

% Generate matrices + get resources
cam = webcam;
rgb2opp_cvd = gen_rgb2opp_mat(red_shift, green_shift);
opp2rgb = (gen_rgb2opp_mat(0, 0))^-1;
mod_RGB = zeros(size1, size2, 3);
cam.Resolution = strcat(int2str(size2), "x", int2str(size1));
step_1 = zeros(size1 * size2, 3);

while (1)
    frame = snapshot(cam);
    frame = im2double(frame);
    frame = rgb2lin(frame);
    frame = flip(frame, 2);

    % Apply CVD shift to image
    step_1 = reshape(frame, size1 * size2, 3) * rgb2opp_cvd' * opp2rgb';
    mod_RGB = reshape(step_1, size1, size2, 3);

    mod_sRGB = lin2rgb(mod_RGB);

    image(mod_sRGB);
    daspect([1, 1, 1]);
    axis off;
end