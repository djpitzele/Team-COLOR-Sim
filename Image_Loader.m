% File name
image_name = "butterflies.jpg";
red_shift = -20;
green_shift = 0;

% Directory to file
% directory = "C:\Users\YOUR USER HERE\Desktop\test_images";
directory = "/Users/rqueen/Programming/Team_Color_sim/Team-COLOR-SIM";

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

% X point integrals
XL_integeral = x_data .* l_new_data;
XM_integeral = x_data .* m_new_data;
XS_integeral = x_data .* s_new_data;

% Y point integrals
YL_integeral = y_data .* l_new_data;
YM_integeral = y_data .* m_new_data;
YS_integeral = y_data .* s_new_data;

% Z point integrals
ZL_integeral = z_data .* l_new_data;
ZM_integeral = z_data .* m_new_data;
ZS_integeral = z_data .* s_new_data;


%% Normalization


img_RGB = imread(full_directory);
% sRGB to linear RGB
img_RGB = rgb2lin(img_RGB);
img_RGB = im2double(img_RGB);



%% RGB to XYZ (CIE 1931 edition)
img_XYZ = rgb2xyz(img_RGB);


%% XYZ to LMS
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
        img_LMS(x,y,:) = xyz_to_lms * squeeze(img_XYZ(x,y,:));
        img_LMS(x,y,3) = 0;
        mod_XYZ(x,y,:) = squeeze(img_LMS(x,y,:));
    end
end

%% going back
mod_RGB = xyz2rgb(mod_XYZ);
imshowpair(img_RGB,mod_RGB,'montage')