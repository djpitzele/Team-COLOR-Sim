%%Reading in Image

image_name = "butterflies.jpg";

img_RGB = imread("butterflies.jpg");

red_shift = 0;
green_shift = 0;

%XYZ CMF data points
XYZ_cmf = table2array(readtable('XYZ_data.csv'));
LMS_cmf = table2array(readtable('LMS_data.csv'));

normXYZ_CMF = normalize(XYZ_cmf);

%normRGB = normalize(img_RGB);

%%sRGB to linRGB
img_RGB = rgb2lin(img_RGB);

%% Normalization - verify xyz?

%%
img_RGB = im2double(img_RGB);

% RGB to XYZ (CIE 1931 edition)
img_XYZ = rgb2xyz(img_RGB);


hex1 = img_XYZ(1,1,1)
hex2 = img_XYZ(1,1,2)
hex3 = img_XYZ(1,1,3)

pix_X_val = img_XYZ(1,1,1);
pix_Y_val = img_XYZ(1,1,2);
pix_Z_val = img_XYZ(1,1,3);

pix_XYZcoord = [pix_X_val,  pix_Y_val, pix_Z_val]

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
        
            %
            wavelength_XYZ = [XYZ_cmf(i,2),XYZ_cmf(i,3),XYZ_cmf(i,4)];
        
            %creates a 2*3 matrix; row 1 has the XYZ values pixels
            %row 2 has the correponding XYZ cmf values
            compPoints = [pix_XYZcoord; wavelength_XYZ];
        
            dist = pdist(compPoints, 'euclidean');
            distArr(i) = dist;
        end

        %locate the minimum within the DistArr
        min_distance = distArr(1);

        %Necessary?
        closest_WL = XYZ_cmf(1,1); 

        for j = 1:441
        
            if (distArr(j) < min_distance) 
                min_distance = distArr(j);
                closest_WL = XYZ_cmf(j,1);

            end
        end

        %store the closet wavelength corresponding to current pixel
        img_Matrix(pix_R, pix_C) = closest_WL;
    end
end

%% Computing LMS_CVD Coords (Applying the CVD shift)

% Interpolate LMS data
desired_wavelengths = 390:1:830;
desired_wavelengths = desired_wavelengths';
wavelength_data = LMS_cmf{:,1};         % turning desired_wavelength into a column vector
l_data = LMS_cmf{:,2};
m_data = LMS_cmf{:,3};
s_data = LMS_cmf{:,4};
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

        for lms_wl = 1: size(LMS_new_cmf,1)
            if (img_Matrix(pix_R,pix_C) == LMS_new_cmf(lms_wl,1))
                img_LMS_CVD(pix_R,pix_C,1) = LMS_new_cmf(lms_wl,2);
                img_LMS_CVD(pix_R,pix_C,2) = LMS_new_cmf(lms_wl,3);
                img_LMS_CVD(pix_R,pix_C,3) = LMS_new_cmf(lms_wl,4);
            end
        end

    end
end

xyz_to_lms = [0.38971 0.68898 -0.07868;
              -0.22981 1.18340 0.04641;
              0 0 1];

CVD_lms_to_XYZ = inv(xyz_to_lms) * img_LMS_CVD(:,3);


%Tentative Normalization of CMFs

