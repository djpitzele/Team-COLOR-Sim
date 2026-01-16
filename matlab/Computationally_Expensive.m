clear all; close all;
%%Reading in Image

image_name = "SS_1.png";

img_RGB = imread(image_name);

red_shift = 0;
green_shift = 0;

%XYZ CMF data points
XYZ_cmf = table2array(readtable('XYZ_data.csv'));
LMS_cmf = table2array(readtable('LMS_data.csv'));

% normRGB = normalize(img_RGB);

%%sRGB to linRGB
img_RGB = rgb2lin(img_RGB);

%% Normalization - verify xyz?
x_data = XYZ_cmf(:,2);
y_data = XYZ_cmf(:,3);
z_data = XYZ_cmf(:,4);

sum_cmfs =  x_data + y_data + z_data;
x_data = x_data ./ sum_cmfs;
y_data = y_data ./ sum_cmfs;
z_data = z_data ./ sum_cmfs;
%
img_RGB = im2double(img_RGB);

% RGB to XYZ (CIE 1931 edition)
img_XYZ = rgb2xyz(img_RGB);

% Normalize data points themselves
sum_points =  img_XYZ(:,1) + img_XYZ(:,2) + img_XYZ(:,3);
img_XYZ(:,1) = img_XYZ(:,1) ./ sum_points;
img_XYZ(:,2) = img_XYZ(:,2) ./ sum_points;
img_XYZ(:,3) = img_XYZ(:,3) ./ sum_points;

distArr = zeros(441,1);

%creating of the matrix representing the wavelengths that correspond to
%each pixel

sz_img_rows = size(img_XYZ,1);
sz_img_cols = size(img_XYZ,2);
img_Matrix = zeros(sz_img_rows, sz_img_cols);

%Loops through all pixels in the image
for pix_R = 1: sz_img_rows
    
    for pix_C = 1: sz_img_cols

        %Loops through all the wavelengths
        for i = 1:441
        pix_X_val = img_XYZ(pix_R,pix_C,1);
        pix_Y_val = img_XYZ(pix_R,pix_C,2);
        pix_Z_val = img_XYZ(pix_R,pix_C,3);

        pix_XYZcoord = [pix_X_val,  pix_Y_val, pix_Z_val];
            
            wavelength_XYZ = [x_data(i),y_data(i),z_data(i)];
        
            %creates a 2*3 matrix; row 1 has the XYZ values pixels
            %row 2 has the correponding XYZ cmf values
            compPoints = [pix_XYZcoord; wavelength_XYZ];
        
            %Ask Rebecca 
            temp_dif = pix_XYZcoord - wavelength_XYZ;
            temp_dif = temp_dif .^ 2;
            temp_dif = sum(temp_dif); 

            %dist = pdist(compPoints, 'euclidean');
            distArr(i) = temp_dif;
        end

        %locate the minimum within the DistArr
       [min_distance, min_index] = min(distArr);

        %Necessary?
        closest_WL = XYZ_cmf(min_index,1); 

        if pix_R == 1 && pix_C == 1
            closest_WL
        end
       
        % %for j = 1:441
        % 
        %     if (distArr(j) < min_distance) 
        %         min_distance = distArr(j);
        %         closest_WL = XYZ_cmf(j,1);
        % 
        %     end
        % %end

        %store the closet wavelength corresponding to current pixel
        img_Matrix(pix_R, pix_C) = closest_WL;
    end
end

%% Computing LMS_CVD Coords (Applying the CVD shift)

% Interpolate LMS data
desired_wavelengths = 390:1:830;
% turning desired_wavelength into a column vector
desired_wavelengths = desired_wavelengths';
wavelength_data = LMS_cmf(:,1);
l_data = LMS_cmf(:,2);
m_data = LMS_cmf(:,3);
s_data = LMS_cmf(:,4);
l_new_data = interp1(wavelength_data, l_data, desired_wavelengths, 'cubic');
m_new_data = interp1(wavelength_data, m_data, desired_wavelengths, 'cubic');
s_new_data = interp1(wavelength_data, s_data, desired_wavelengths, 'cubic');
LMS_new_cmf = [desired_wavelengths, l_new_data, m_new_data, s_new_data];

% Shift LMS response data (apply colorblindness)
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

%% Manually map wavelength to LMS_CVD Coords

image_LMS_CVD = zeros(size(img_XYZ));

for pix_R = 1: sz_img_rows
    for pix_C = 1: sz_img_cols

        %Instead of using for loop we will index the XYZ matrix to swap
        %these values instead

        intended_wl = img_Matrix(pix_R,pix_C) - 389;
        image_LMS_CVD(pix_R, pix_C,1) = LMS_new_cmf(intended_wl, 2);
        image_LMS_CVD(pix_R, pix_C,2) = LMS_new_cmf(intended_wl, 3);
        image_LMS_CVD(pix_R, pix_C,3) = LMS_new_cmf(intended_wl, 4);

        % for lms_wl = 1: size(LMS_new_cmf,1)
        %     if (img_Matrix(pix_R,pix_C) == LMS_new_cmf(lms_wl,1))
        %         image_LMS_CVD(pix_R,pix_C,1) = LMS_new_cmf(lms_wl,2);
        %         image_LMS_CVD(pix_R,pix_C,2) = LMS_new_cmf(lms_wl,3);
        %         image_LMS_CVD(pix_R,pix_C,3) = LMS_new_cmf(lms_wl,4);
        %     end
        % end

    end
end

xyz_to_lms = [0.38971 0.68898 -0.07868;
              -0.22981 1.18340 0.04641;
              0 0 1];

% different one from wikipedia
%xyz_to_lms = [0.210576 0.855098 -0.0396983;
%    -0.417076 1.177260 0.0786283;
%              0 0 0.516835];

image_XYZ_CVD = zeros(size(image_LMS_CVD));
lms2xyz = xyz_to_lms^-1;

for x = 1: sz_img_rows
    for y = 1: sz_img_cols
    
        image_XYZ_CVD(x,y,:) = lms2xyz * squeeze(image_LMS_CVD(x,y,:));

    end
end

 final_image = xyz2rgb(image_XYZ_CVD);

 imshowpair(img_RGB,final_image,'montage')

%CVD_lms_to_XYZ = inv(xyz_to_lms) * transpose(img_LMS_CVD(:,3));



%Tentative Normalization of CMFs

