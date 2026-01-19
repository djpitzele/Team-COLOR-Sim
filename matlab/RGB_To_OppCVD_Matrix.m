% Testing the construction of a matrix that moves data from RGB all the way
% to colorblind opponent space. Tests this on real images.

% File name
% image_name = "forest.jpg";
% image_name = "butterflies.jpg";
image_name = "color_wheel.png";
red_shift = 0;
green_shift = 0;

% Directory to file
% directory = "C:\Users\YOUR USER HERE\Desktop\test_images";
% directory = "/Users/rqueen/Programming/Team_Color_sim/Team-COLOR-SIM";
% directory = "C:\Users\dpitz\color-sim\Team-COLOR-Sim\test_images";

%% Full directory to image
% full_directory = fullfile(directory, image_name);

%% Load in csvs
XYZ_cmf = readtable('../data_tables/XYZ_data.csv');
LMS_cmf = readtable('../data_tables/LMS_data.csv');

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
    l_cvd = alpha * l_new_data + (1 - alpha) * 0.96 * (AreaL / AreaM) * m_new_data;
    % l_cvd = (0.96)*(AreaL/AreaM)*((alpha*l_new_data)+((1-alpha)*m_new_data));
    % normalize new CVD values
    max_val = max(l_cvd);
    l_cvd = l_cvd ./ max_val;
else
    l_cvd = l_new_data;
end

if green_shift ~= 0
    m_cvd = beta * m_new_data + (1 - beta) * (1 / 0.96) * (AreaM / AreaL) * l_new_data;
    % m_cvd = (1/0.96)*(AreaM/AreaL)*((beta*m_new_data)+((1-beta)*l_new_data));
    % normalize new CVD values
    max_val = max(m_cvd);
    m_cvd = m_cvd ./ max_val;
else
    m_cvd = m_new_data;
end

%% CVD LMS data -> CVD Opponent Space
% Paper equation 1
paperMatrix = [0.6 0.4 0;
               0.24 0.105 -0.7;
               1.2 -1.6 .4];


opp_new_data = zeros(length(s_new_data), 3);

for i = 1:length(s_new_data)
    opp_new_data(i,:) = paperMatrix * [l_cvd(i); m_cvd(i); s_new_data(i)];
end

%% Construct power distributions from standard graph data
r_spd = readtable('../data_tables/LED_SPD_R.csv');
g_spd = readtable('../data_tables/LED_SPD_G.csv');
b_spd = readtable('../data_tables/LED_SPD_B.csv');

r_spd = interp1(r_spd{:,1}, r_spd{:,2}, desired_wavelengths, 'linear');
g_spd = interp1(g_spd{:,1}, g_spd{:,2}, desired_wavelengths, 'linear');
b_spd = interp1(b_spd{:,1}, b_spd{:,2}, desired_wavelengths, 'linear');

%% Element-wise multiplication to simulate integration

% x_data = XYZ_cmf{:,2};      % x column data.
% y_data = XYZ_cmf{:,3};      % y column data.
% z_data = XYZ_cmf{:,4};      % z column data.

% normalize relative to RGB CMFs
% sum_cmfs = x_data + y_data + z_data;
% x_data = x_data ./ sum_cmfs;
% y_data = y_data ./ sum_cmfs;
% z_data = z_data ./ sum_cmfs;

% X point integrals
RBW_int = sum(r_spd .* opp_new_data(:, 1));
RBY_int = sum(r_spd .* opp_new_data(:, 2));
RRG_int = sum(r_spd .* opp_new_data(:, 3));

% Y point integrals
GBW_int = sum(g_spd .* opp_new_data(:, 1));
GBY_int = sum(g_spd .* opp_new_data(:, 2));
GRG_int = sum(g_spd .* opp_new_data(:, 3));

% Z point integrals
BBW_int = sum(b_spd .* opp_new_data(:, 1));
BBY_int = sum(b_spd .* opp_new_data(:, 2));
BRG_int = sum(b_spd .* opp_new_data(:, 3));


%% Normalization
sum_BWs = RBW_int + GBW_int + BBW_int;
sum_BYs = RBY_int + GBY_int + BBY_int;
sum_RGs = RRG_int + GRG_int + BRG_int;

RBW_int = RBW_int / sum_BWs;
GBW_int = GBW_int / sum_BWs;
BBW_int = BBW_int / sum_BWs;
RBY_int = RBY_int / sum_BYs;
GBY_int = GBY_int / sum_BYs;
BBY_int = BBY_int / sum_BYs;
RRG_int = RRG_int / sum_RGs;
GRG_int = GRG_int / sum_RGs;
BRG_int = BRG_int / sum_RGs;

rgb2cvd_opp = [RBW_int, GBW_int, BBW_int;
               RBY_int, GBY_int, BBY_int;
               RRG_int, GRG_int, BRG_int];

original_img_sRGB = imread("../test_images/" + image_name);
original_img_sRGB = im2double(original_img_sRGB);
% sRGB to linear RGB
img_RGB = rgb2lin(original_img_sRGB);



%% RGB to XYZ (CIE 1931 edition)
% img_XYZ = rgb2xyz(img_RGB);


% XYZ to LMS
% wikipedia
% xyz_to_lms = [0.38971 0.68898 -0.07868;
%               -0.22981 1.18340 0.04641;
%               0 0 1];
% xyz_to_lms = [0.4260 0.5151 0.0589;
%               0.3289 0.5548 0.1164;
%               0.1486 0.0414 0.8099];
% XYZ to Opponent (generated by us with a 0,0 shift as described in paper)
rgb2opp = [0.1572 0.7710 0.0719;
           -1.0174 -3.7365 5.7540;
           -1.8462 4.0223 -1.1761];

%% Apply CVD shift to image
size1 = size(img_RGB,1);
size2 = size(img_RGB,2);
img_opp = zeros(size1,size2,3);
mod_RGB = zeros(size1,size2,3);
for x = 1:size1
    for y = 1:size2
        img_opp(x,y,:) = rgb2cvd_opp * squeeze(img_RGB(x,y,:));
        % disp(img_LMS(x,y,:))
        % img_LMS(x,y,2) = 0;
        mod_RGB(x,y,:) = (rgb2opp^-1) * squeeze(img_opp(x,y,:));
    end
end

%% going back
mod_sRGB = lin2rgb(mod_RGB);

% for i = 1:size(mod_sRGB, 1)
%     for j = 1:size(mod_sRGB, 2)
%         if (round(mod_sRGB(i, j) - original_img_sRGB(i, j), 2, 'significant') > 0.02)
%             display("wrong " + i + " " + j)
%             display(round(mod_sRGB(i, j) - original_img_sRGB(i, j), 2, 'significant'))
%             display(mod_sRGB(i, j))
%             display(original_img_sRGB(i, j))
%            
%         end
%     end
% end

figure
imshowpair(original_img_sRGB,mod_sRGB,'montage')