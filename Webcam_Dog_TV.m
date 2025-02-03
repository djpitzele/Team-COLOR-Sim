clear all; close all; clc; 

% Settings
red_shift = -10; % negative
green_shift = 0; % positive
size1 = 240;
size2 = 320;

% Generate matrices + get resources
cam = webcam;
rgb2opp_cvd = gen_rgb2opp_mat(red_shift, green_shift);
opp2rgb = (gen_rgb2opp_mat(0, 0))^-1;
img_opp = zeros(size1, size2, 3);
mod_RGB = zeros(size1, size2, 3);
cam.Resolution = strcat(int2str(size2), "x", int2str(size1));

while (1)
    frame = snapshot(cam);

    frame = im2double(frame);
    frame = rgb2lin(frame);

    % Apply CVD shift to image
%     for x = 1:size1
%         img_opp(x, :, :) = rgb2opp_cvd * squeeze(frame(x, :, :));
%         mod_RGB(x, :, :) = opp2rgb * squeeze(img_opp(x, :, :));
%     end
%     img_opp = applycform(frame, rgb2opp_cvd);
%     mod_RGB = applycform(frame, opp2rgb);
    for x = 1:size1
        for y = 1:size2
            img_opp(x,y,:) = rgb2opp_cvd * squeeze(frame(x,y,:));
            mod_RGB(x,y,:) = opp2rgb * squeeze(img_opp(x,y,:));
        end
    end

    mod_sRGB = lin2rgb(mod_RGB);
    imshow(mod_sRGB);
end