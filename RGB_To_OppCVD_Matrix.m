% Testing the construction of a matrix that moves data from RGB all the way
% to colorblind opponent space. Tests this on real images.

% File name
% image_name = "forest.jpg";
% image_name = "butterflies.jpg";
image_name = "color_wheel.png";
red_shift = -10;
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

%% Calculate shifting matrix / shift LMS response data
% if red_shift ~= 0
%     for i = 1:(size(l_new_data) + red_shift)
%         l_new_data(i) = l_new_data(i - red_shift);
%     end
%     for i = (size(l_new_data) + red_shift + 1):(size(l_new_data))
%         l_new_data(i) = 0;
%     end
% end

% green shift for negative value
% if green_shift ~= 0
%     for i = 1:(size(m_new_data) + green_shift)
%         m_new_data(i) = m_new_data(i - green_shift);
%     end
%     for i = (size(m_new_data) + green_shift + 1):(size(m_new_data))
%         m_new_data(i) = 0;
%     end
% end

% green shift for positive value
% if green_shift ~= 0
%     for i = (green_shift+1):(size(m_new_data))
%         m_new_data(i) = m_new_data(i - green_shift);
%     end
%     for i = 1:green_shift
%         m_new_data(i) = 0;
%     end
% end

% nikolai method
% if red_shift ~= 0
%     l_new_data = [ l_new_data(-red_shift + 1 : end) ; zeros(-red_shift, 1) ];
% end

% if green_shift ~= 0
%     m_new_data = [ zeros(green_shift, 1) ; m_new_data( 1 : end - green_shift ) ];
% end

AreaL = sum(l_new_data);
AreaM = sum(m_new_data);
alpha = (20 + red_shift)/20;
beta = (20 - green_shift)/20;
if red_shift ~= 0
    l_cvd = (0.96)*(AreaL/AreaM)*((alpha*l_new_data)+((1-alpha)*m_new_data));
    % normalize new CVD values
    max_val = max(l_cvd);
    l_cvd = l_cvd ./ max_val;
else
    l_cvd = l_new_data;
end

if green_shift ~= 0
    m_cvd = (1/0.96)*(AreaM/AreaL)*((beta*m_new_data)+((1-beta)*l_new_data));
    % normalize new CVD values
    max_val = max(m_cvd);
    m_cvd = m_cvd ./ max_val;
else
    m_cvd = m_new_data;
end

% Original
paperMatrix = [0.6 0.4 0;
               0.24 0.105 -0.7;
               1.2 -1.6 .4];


opp_new_data = zeros(length(s_new_data), 3);

for i = 1:length(s_new_data)
    opp_new_data(i,:) = paperMatrix * [l_cvd(i); m_cvd(i); s_new_data(i)];
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
XL_int = sum(x_data .* l_cvd);
XM_int = sum(x_data .* m_cvd);
XS_int = sum(x_data .* s_new_data);

% Y point integrals
YL_int = sum(y_data .* l_cvd);
YM_int = sum(y_data .* m_cvd);
YS_int = sum(y_data .* s_new_data);

% Z point integrals
ZL_int = sum(z_data .* l_cvd);
ZM_int = sum(z_data .* m_cvd);
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

img_RGB = imread(full_directory);
% sRGB to linear RGB
img_RGB = rgb2lin(img_RGB);
img_RGB = im2double(img_RGB);



%% RGB to XYZ (CIE 1931 edition)
img_XYZ = rgb2xyz(img_RGB);


% XYZ to LMS
% wikipedia
% xyz_to_lms = [0.38971 0.68898 -0.07868;
%               -0.22981 1.18340 0.04641;
%               0 0 1];
xyz_to_lms = [0.4260 0.5151 0.0589;
              0.3289 0.5548 0.1164;
              0.1486 0.0414 0.8099];

%% Apply CVD shift to image
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
figure
imshowpair(img_RGB,mod_RGB,'montage')