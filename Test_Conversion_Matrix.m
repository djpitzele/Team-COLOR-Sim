red_shift = 0;
green_shift = 0;

%% Load in csvs
XYZ_cmf = table2array(readtable('XYZ_data.csv'));
LMS_cmf = table2array(readtable('LMS_data.csv'));
our_matrix = table2array(readtable(strcat("red", int2str(red_shift), "green", int2str(green_shift), ".csv")));

lms_to_opp = [0.6, 0.4, 0;
              0.24, 0.105, -0.7;
              1.2, -1.6, 0.4];
test_our_matrix = lms_to_opp * our_matrix;

%% Applying our matrix to XYZ test data
xyz_vals = XYZ_cmf(:,2:4);
% lms_vals = LMS_cmf(:,2:4);
xyz_vals = transpose(xyz_vals);
% lms_vals = transpose(lms_vals);
our_opp_values = test_our_matrix * xyz_vals;

%% Interpolate LMS data
desired_wavelengths = 390:1:830;
desired_wavelengths = desired_wavelengths';
wavelength_data = LMS_cmf(:,1);         % turning desired_wavelength into a column vector
l_data = LMS_cmf(:,2);
m_data = LMS_cmf(:,3);
s_data = LMS_cmf(:,4);
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

%% Convert to color opponent process
new_lms_cmfs = transpose([l_new_data m_new_data s_new_data]);
ideal_opp_values = lms_to_opp * new_lms_cmfs;

figure
hold on
plot(transpose(ideal_opp_values));
figure
plot(transpose(our_opp_values));