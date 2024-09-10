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

paperMatrix = [0.6 0.4 0;
               0.24 0.105 -0.7;
               1.2 -1.6 .4];

opp_new_data = zeros(length(s_new_data), 3);

for i = 1:length(s_new_data)
    opp_new_data(i,:) = paperMatrix * [l_new_data(i); m_new_data(i); s_new_data(i)];
end

figure
hold on
plot(390:830, opp_new_data);
xlim([390 830]);