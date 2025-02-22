import numpy as np
import csv

def rgb2opp_mat(red_shift, green_shift):
    # Import + interpolate LMS data
    file = open('../data_tables/LMS_data.csv', 'r')
    reader = csv.reader(file)
    LMS_cmf = [] # N x 4 array, column 0 is wavelength, columns 1-3 are L, M, S
    for row in reader:
        LMS_cmf.append(list(map(float, row)))
    LMS_cmf = np.matrix(LMS_cmf)

    desired_wavelengths = np.array(range(390, 830, 1))
    wavelength_data = np.asarray(LMS_cmf[:,0]).flatten()
    l_data = np.asarray(LMS_cmf[:,1]).flatten()
    m_data = np.asarray(LMS_cmf[:,2]).flatten()
    s_data = np.asarray(LMS_cmf[:,3]).flatten()

    l_new_data = np.interp(desired_wavelengths, wavelength_data, l_data) # note: linear interpolation, not cubic
    m_new_data = np.interp(desired_wavelengths, wavelength_data, m_data)
    s_new_data = np.interp(desired_wavelengths, wavelength_data, s_data)

    # Shift LMS data using equations from paper
    areaL = np.sum(l_new_data)
    areaM = np.sum(m_new_data)
    alpha = (20 + red_shift) / 20.0
    beta = (20 - green_shift) / 20.0

    l_cvd = None
    if red_shift != 0:
        l_cvd = 0.96 * (areaL / areaM) * ((alpha * l_new_data) + ((1 - alpha) * m_new_data))
        # normalize new CVD values
        max_val = np.max(l_cvd)
        l_cvd /= max_val
    else:
        l_cvd = l_new_data

    m_cvd = None
    if green_shift != 0:
        m_cvd = (1 / 0.96) * (areaM / areaL) * ((beta * m_new_data) + ((1 - beta) * l_new_data))
        # normalize new CVD avlues
        max_val = np.max(m_cvd)
        m_cvd /= max_val
    else:
        m_cvd = m_new_data
    

rgb2opp_mat(1, 1)