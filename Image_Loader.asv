% File name
% image_name = "forest.jpg";
image_name = "butterflies.jpg";
red_shift = 0;
green_shift = 0;

% Directory to file
% directory = "C:\Users\YOUR USER HERE\Desktop\test_images";
% directory = "/Users/rqueen/Programming/Team_Color_sim/Team-COLOR-SIM";
directory = "C:\Users\dpitz\color-sim\Team-COLOR-Sim\test_images";

%% Full directory to image
full_directory = fullfile(directory, image_name);

%% Load in csvs
XYZ_cmf = readtable('XYZ_data.csv');
LMS_cmf = readtable('LMS_data.csv');

%% Interpolate LMS data
desired_wavelengths = 390:1:830;
desired_wavelengths = desired_wavelengths';
wavelength_data = LMS_cmf{:,1};         % turning desired_wavelength into a column vector
l_data = LMS_cmf{:,2};
m_data = LMS_cmf{:,3};
s_data = LMS_cmf{:,4};
l_new_data = interp1(wavelength_data, l_data, desired_wavelengths, 'cubic');
m_new_data = interp1(wavelength_data, m_data, desired_wavelengths, 'cubic');
s_new_data = interp1(wavelength_data, s_data, desired_wavelengths, 'cubic');
% LMS_new_cmf = [desired_wavelengths, l_new_data, m_new_data, s_new_data];

%% Shift LMS response data (apply colorblindness)
if red_shift ~= 0
    for i = 1:(size(l_new_data) + red_shift)
        l_new_data(i) = l_new_data(i - red_shift);
    end
    for i = (size(l_new_data) + red_shift + 1):(size(l_new_data))
        l_new_data(i) = 0;
    end
end

if green_shift ~= 0
    for i = (green_shift+1):(size(m_new_data))
        m_new_data(i) = m_new_data(i - green_shift);
    end
    for i = 1:green_shift
        m_new_data(i) = 0;
    end
end


%% Element-wise multiplication to simulate integration

x_data = XYZ_cmf{:,2};      % x column data.
y_data = XYZ_cmf{:,3};      % y column data.
z_data = XYZ_cmf{:,4};      % z column data.

% normalize relative to RGB CMFs
% sum_cmfs = x_data + y_data + z_data;
% x_data = x_data ./ sum_cmfs;
% y_data = y_data ./ sum_cmfs;
% z_data = z_data ./ sum_cmfs;

% X point integrals
XL_int = sum(x_data .* l_new_data);
XM_int = sum(x_data .* m_new_data);
XS_int = sum(x_data .* s_new_data);

% Y point integrals
YL_int = sum(y_data .* l_new_data);
YM_int = sum(y_data .* m_new_data);
YS_int = sum(y_data .* s_new_data);

% Z point integrals
ZL_int = sum(z_data .* l_new_data);
ZM_int = sum(z_data .* m_new_data);
ZS_int = sum(z_data .* s_new_data);


%% Normalization
sum_Ls = XL_int + YL_int + ZL_int;
sum_Ms = XM_int + YM_int + ZM_int;
sum_Ss = XS_int + YS_int + ZS_int;

XL_int = XL_int / sum_Ls;
YL_int = YL_int / sum_Ls;
ZL_int = ZL_int / sum_Ls;
XM_int = XM_int / sum_Ms;
YM_int = YM_int / sum_Ms;
ZM_int = ZM_int / sum_Ms;
XS_int = XS_int / sum_Ss;
YS_int = YS_int / sum_Ss;
ZS_int = ZS_int / sum_Ss;

xyz2cvd_lms = [XL_int, YL_int, ZL_int;
               XM_int, YM_int, ZM_int;
               XS_int, YS_int, ZS_int];

writematrix(xyz2cvd_lms, strcat("red", int2str(red_shift), "green", int2str(green_shift), ".csv"));

img_RGB = imread(full_directory);
% sRGB to linear RGB
img_RGB = rgb2lin(img_RGB);
img_RGB = im2double(img_RGB);



%% RGB to XYZ (CIE 1931 edition)
img_XYZ = rgb2xyz(img_RGB);


% XYZ to LMS
% wikipedia
xyz_to_lms = [0.38971 0.68898 -0.07868;
              -0.22981 1.18340 0.04641;
              0 0 1];

%% LMS shift (or map to 0)
size1 = size(img_RGB,1);
size2 = size(img_RGB,2);
img_LMS = zeros(size1,size2,3);
mod_XYZ = zeros(size1,size2,3);
for x = 1:size1
    for y = 1:size2
        img_LMS(x,y,:) = xyz2cvd_lms * squeeze(img_XYZ(x,y,:));
        % disp(img_LMS(x,y,:))
        % img_LMS(x,y,2) = 0;
        mod_XYZ(x,y,:) = (xyz_to_lms^-1) * squeeze(img_LMS(x,y,:));
    end
end

%% going back
mod_RGB = xyz2rgb(mod_XYZ);
imshowpair(img_RGB,mod_RGB,'montage')