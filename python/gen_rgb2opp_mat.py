import numpy as np
import csv

def read_table(path : str):
    file = open(path, 'r')
    reader = csv.reader(file)
    arr = []
    for row in reader:
        arr.append(list(row))
    
    return np.array(arr).astype('float64')

def rgb2opp_mat(red_shift, green_shift):
    # Import + interpolate LMS data
    LMS_cmf = read_table('../data_tables/LMS_data.csv') # N x 4 array, column 0 is wavelength, columns 1-3 are L, M, S

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
        l_cvd = alpha * l_new_data + (1 - alpha) * 0.96 * (areaL / areaM) * m_new_data
        # normalize new CVD values
        max_val = np.max(l_cvd)
        l_cvd /= max_val
    else:
        l_cvd = l_new_data

    m_cvd = None
    if green_shift != 0:
        m_cvd = beta * m_new_data + (1 - beta) * (1 / 0.96) * (areaM / areaL) * l_new_data
        # normalize new CVD avlues
        max_val = np.max(m_cvd)
        m_cvd /= max_val
    else:
        m_cvd = m_new_data
    
    # CVD LMS data -> CVD Opponent Space
    # Paper equation 1
    paperMatrix1 = np.array([[0.6, 0.4, 0], [0.24, 0.105, -0.7], [1.2, -1.6, 0.4]])
    cvd_data_stacked = np.stack((l_cvd, m_cvd, s_new_data), axis=-1)
    opp_new_data = np.zeros((s_new_data.shape[0], 3))

    for i in range(cvd_data_stacked.shape[0]):
        opp_new_data[i] = np.matmul(paperMatrix1, cvd_data_stacked[i])

    # Construct power distributions from standard graph data
    r_spd = read_table('../data_tables/LED_SPD_R.csv')
    g_spd = read_table('../data_tables/LED_SPD_G.csv')
    b_spd = read_table('../data_tables/LED_SPD_B.csv')

    r_spd = np.interp(desired_wavelengths, r_spd[:,0], r_spd[:,1])
    g_spd = np.interp(desired_wavelengths, g_spd[:,0], g_spd[:,1])
    b_spd = np.interp(desired_wavelengths, b_spd[:,0], b_spd[:,1])

    # Normalize SPD data
    r_spd = r_spd / np.max(r_spd)
    g_spd = g_spd / np.max(g_spd)
    b_spd = b_spd / np.max(b_spd)

    # Element-wise multiplication to simulate integration
    RBW_int = np.sum(r_spd * opp_new_data[:, 0])
    RBY_int = np.sum(r_spd * opp_new_data[:, 1])
    RRG_int = np.sum(r_spd * opp_new_data[:, 2])

    GBW_int = np.sum(g_spd * opp_new_data[:, 0])
    GBY_int = np.sum(g_spd * opp_new_data[:, 1])
    GRG_int = np.sum(g_spd * opp_new_data[:, 2])

    BBW_int = np.sum(b_spd * opp_new_data[:, 0])
    BBY_int = np.sum(b_spd * opp_new_data[:, 1])
    BRG_int = np.sum(b_spd * opp_new_data[:, 2])

    # Normalization
    sum_BWs = RBW_int + GBW_int + BBW_int
    sum_BYs = RBY_int + GBY_int + BBY_int
    sum_RGs = RRG_int + GRG_int + BRG_int

    RBW_int = RBW_int / sum_BWs
    GBW_int = GBW_int / sum_BWs
    BBW_int = BBW_int / sum_BWs
    RBY_int = RBY_int / sum_BYs
    GBY_int = GBY_int / sum_BYs
    BBY_int = BBY_int / sum_BYs
    RRG_int = RRG_int / sum_RGs
    GRG_int = GRG_int / sum_RGs
    BRG_int = BRG_int / sum_RGs

    rgb2opp_cvd = np.array([[RBW_int, GBW_int, BBW_int], [RBY_int, GBY_int, BBY_int], [RRG_int, GRG_int, BRG_int]])

    return rgb2opp_cvd

print(rgb2opp_mat(0, 0))