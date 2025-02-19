import numpy as np
import csv

def rgb2opp_mat(red_shift, green_shift):
    # Import + interpolate LMS data
    file = open('../data_tables/LMS_data.csv', 'r')
    reader = csv.reader(file)
    LMS_cmf = [] # N x 4 array, column 1 is wavelength, columns 2-4 are L, M, S
    for row in reader:
        LMS_cmf.append(list(map(float, row)))
    LMS_cmf = np.matrix(LMS_cmf)

    desired_wavelengths = np.array(range(390, 830, 1))

    l_new_data = np.interp(desired_wavelengths, LMS_cmf[0], LMS_cmf[1]) # note: linear interpolation, not cubic
    m_new_data = np.interp(desired_wavelengths, LMS_cmf[0], LMS_cmf[2])
    s_new_data = np.interp(desired_wavelengths, LMS_cmf[0], LMS_cmf[3])

    # Shift LMS data using equations from paper
    

rgb2opp_mat(0, 0)