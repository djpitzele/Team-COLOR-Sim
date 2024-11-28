% File name
clear all; close all; clc; %#ok

% Generate CVD simulation matrix
blue_shift = 0;
red_shift = 0;
green_shift = 0;
rgb2opp_norm = gen_rgb2opp_mat( 0 , 0 , 0 );
opp_norm2rgb = inv(rgb2opp_norm);
rgb2opp_cvd = gen_rgb2opp_mat( red_shift , green_shift , blue_shift );
rgb2rgb_cvd = opp_norm2rgb * rgb2opp_cvd; %#ok

% Load image
original_image = imread("test_images/color_wheel.png");

% Modify image
cvd_image = original_image;
cvd_image = rgb2lin(cvd_image);
cvd_image = im2double(cvd_image);
image_dims = size(cvd_image);
rows = image_dims(1);
cols = image_dims(2);
for i = 1 : rows
    for j = 1 : cols
        cvd_image(i,j,:) = rgb2rgb_cvd * squeeze( cvd_image(i,j,:) );
    end
end
cvd_image = uint8(cvd_image * 256);
cvd_image = lin2rgb(cvd_image);

% Display original and modified image
figure;
imshowpair(original_image,cvd_image,'montage')


% linear RGB to color opponent space matrix generation
% based on anomalous shifts in cone fundamentals
function rgb2opp = gen_rgb2opp_mat( red_shift , green_shift , blue_shift )

    % Load in LMS cone sensitivity functions and interpolate data
    LMS_cmf = readtable('LMS_data.csv');
    wavelengths = 390:1:830;
    l_data = interp1(LMS_cmf{:,1}, LMS_cmf{:,2}, wavelengths, 'cubic');
    m_data = interp1(LMS_cmf{:,1}, LMS_cmf{:,3}, wavelengths, 'cubic');
    s_data = interp1(LMS_cmf{:,1}, LMS_cmf{:,4}, wavelengths, 'cubic');
    
    % Load in RGB SPD and interpolate data
    r_spd = readtable('LED_SPD_R.csv');
    g_spd = readtable('LED_SPD_G.csv');
    b_spd = readtable('LED_SPD_B.csv');
    r_spd = interp1(r_spd{:,1}, r_spd{:,2}, wavelengths, 'linear');
    g_spd = interp1(g_spd{:,1}, g_spd{:,2}, wavelengths, 'linear');
    b_spd = interp1(b_spd{:,1}, b_spd{:,2}, wavelengths, 'linear');
    
    % Shift cone fundamentals data
    AreaL = sum(l_data);
    AreaM = sum(m_data);
    alpha = ( 20 + red_shift ) / 20;
    beta = ( 20 - green_shift ) / 20;
    l_cvd = alpha * l_data + ( 1 - alpha ) * 0.96 * ( AreaL / AreaM ) * m_data;
    m_cvd = beta * m_data + ( 1 - beta) * ( 1 / 0.96 ) * ( AreaM / AreaL ) * l_data;
    l_cvd = l_cvd / max(l_cvd);
    m_cvd = m_cvd / max(m_cvd);
    s_cvd = [ zeros(1, blue_shift) s_data(1:end-blue_shift)];

    % Use opponent color functions to generate CVD opponent color space
    lms2opp =   [
                0.6 0.4 0;
                0.24 0.105 -0.7;
                1.2 -1.6 .4
                ];
    opp_data = zeros(length(s_data), 3);
    for i = 1 : length(wavelengths)
        opp_data(i,:) = lms2opp * [l_cvd(i); m_cvd(i); s_cvd(i)];
    end
    
    % Create rgb2opp matrix
    WS_data = opp_data(:,1)';
    YB_data = opp_data(:,2)';
    RG_data = opp_data(:,3)';

    int_WS_R = sum( r_spd .* WS_data );
    int_WS_G = sum( g_spd .* WS_data );
    int_WS_B = sum( b_spd .* WS_data );
    int_YB_R = sum( r_spd .* YB_data );
    int_YB_G = sum( g_spd .* YB_data );
    int_YB_B = sum( b_spd .* YB_data );
    int_RG_R = sum( r_spd .* RG_data );
    int_RG_G = sum( g_spd .* RG_data );
    int_RG_B = sum( b_spd .* RG_data );
    

    rho_WS = 1 ./ ( int_WS_R + int_WS_G + int_WS_B );
    rho_YB = 1 ./ ( int_YB_R + int_YB_G + int_YB_B );
    rho_RG = 1 ./ ( int_RG_R + int_RG_G + int_RG_B );
    
    WS_R = int_WS_R * rho_WS;
    WS_G = int_WS_G * rho_WS;
    WS_B = int_WS_B * rho_WS;
    YB_R = int_YB_R * rho_YB;
    YB_G = int_YB_G * rho_YB;
    YB_B = int_YB_B * rho_YB;
    RG_R = int_RG_R * rho_RG;
    RG_G = int_RG_G * rho_RG;
    RG_B = int_RG_B * rho_RG;
    
    rgb2opp =   [
                WS_R WS_G WS_B;
                YB_R YB_G YB_B;
                RG_R RG_G RG_B;
                ];

end
