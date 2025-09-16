clc; clear; close all;

%Enter red or green shift
red_shift = 0; % negative
green_shift = 0; % positive

%Color Shifting matrix
rgb2opp_cvd = gen_rgb2opp_mat(red_shift, green_shift);

opp2rgb = gen_rgb2opp_mat(0, 0)^-1;

rgb2rgb_cvd = opp2rgb * rgb2opp_cvd;
%Read the csv values
hue_data = readtable('data_tables/munsell_hex_40.csv', 'Delimiter', ',');
hex_colors = hue_data{:,2};

% disp(hex_colors);
%Convert to RGB and Hex
cvd_rgb = zeros(size(hue_data, 1), 3);
cvd_hex = strings(size(hue_data, 1), 1);

new_rgb = zeros(size(hex_colors, 1), 3);
new_hex = strings(size(hex_colors, 1), 1);

shiftHue = zeros(40, 1); 

for i = 1:length(hex_colors)
 % Convert hex to RGB (0-1)
    hex_str = strtrim(string(hex_colors(i,:))); % Converts row to string
    
    % disp(hex_str);
    rgb = sscanf(hex_str, '%2x%2x%2x', [1 3]) / 255;
    % disp(rgb);
    % Apply the color shift matrix
    shifted_rgb = (rgb2rgb_cvd * rgb')';
    % Clip values to [0,1]
    shifted_rgb = max(0, min(1, shifted_rgb));
    shifted_rgb = reshape(shifted_rgb, 1, 3);
    % disp(size(shifted_rgb));

    % Store new RGB and hex
    new_rgb(i, :) = shifted_rgb;

    % Convert back to hex
    hexR = upper(dec2hex(round(shifted_rgb(1)*255),2));
    hexG = upper(dec2hex(round(shifted_rgb(2)*255),2));
    hexB = upper(dec2hex(round(shifted_rgb(3)*255),2));
    new_hex(i) = string(strcat('#', hexR, hexG, hexB)); % or strcat('#', hexR, hexG, hexB) for a leading #

    shiftHue(i, :) = new_hex(i);
end

disp(new_hex);

%write new values into munsell_hex_shifted.csv
hue_data.NewRGB = new_rgb;
hue_data.NewHex = new_hex;

writematrix(new_hex, 'data_tables/munsell_hex_noShift.csv');


