function rgb2opp_cvd = gen_rgb2opp_mat(red_shift, green_shift)
    LMS_cmf = readtable('../data_tables/LMS_data.csv');
    
    % Interpolate LMS data
    desired_wavelengths = 390:1:740; % was 830
    desired_wavelengths = desired_wavelengths';
    wavelength_data = LMS_cmf{:,1};
    l_data = LMS_cmf{:,2};
    m_data = LMS_cmf{:,3};
    s_data = LMS_cmf{:,4};
    l_new_data = interp1(wavelength_data, l_data, desired_wavelengths, 'cubic');
    m_new_data = interp1(wavelength_data, m_data, desired_wavelengths, 'cubic');
    s_new_data = interp1(wavelength_data, s_data, desired_wavelengths, 'cubic');

    % Shift LMS data using equations from paper
    AreaL = sum(l_new_data);
    AreaM = sum(m_new_data);
    alpha = (20 + red_shift) / 20;
    beta = (20 - green_shift) / 20;
    if red_shift ~= 0
        l_cvd = alpha * l_new_data + (1 - alpha) * 0.96 * (AreaL / AreaM) * m_new_data;
        % normalize new CVD values
        max_val = max(l_cvd);
        l_cvd = l_cvd ./ max_val;
    else
        l_cvd = l_new_data;
    end
    
    if green_shift ~= 0
        m_cvd = beta * m_new_data + (1 - beta) * (1 / 0.96) * (AreaM / AreaL) * l_new_data;
        % normalize new CVD values
        max_val = max(m_cvd);
        m_cvd = m_cvd ./ max_val;
    else
        m_cvd = m_new_data;
    end

    % CVD LMS data -> CVD Opponent Space
    % Paper equation 1
    paperMatrix1 = [0.6 0.4 0;
                   0.24 0.105 -0.7;
                   1.2 -1.6 .4];
    
    
    opp_new_data = zeros(length(s_new_data), 3);
    
    for i = 1:length(s_new_data)
        opp_new_data(i,:) = paperMatrix1 * [l_cvd(i); m_cvd(i); s_new_data(i)];
    end

    % Construct power distributions from standard graph data
    % r_spd1 = readtable('../data_tables/Daniel_Red_SPD.csv');
    % g_spd1 = readtable('../data_tables/Daniel_Green_SPD.csv');
    % b_spd1 = readtable('../data_tables/Daniel_Blue_SPD.csv');
    r_spd = readtable('../data_tables/LED_SPD_R.csv');
    g_spd = readtable('../data_tables/LED_SPD_G.csv');
    b_spd = readtable('../data_tables/LED_SPD_B.csv');
    
    r_spd = interp1(r_spd{:,1}, r_spd{:,2}, desired_wavelengths, 'linear');
    g_spd = interp1(g_spd{:,1}, g_spd{:,2}, desired_wavelengths, 'linear');
    b_spd = interp1(b_spd{:,1}, b_spd{:,2}, desired_wavelengths, 'linear');

    % r_spd1 = interp1(r_spd1{:,1}, r_spd1{:,2}, desired_wavelengths, 'linear');
    % g_spd1 = interp1(g_spd1{:,1}, g_spd1{:,2}, desired_wavelengths, 'linear');
    % b_spd1 = interp1(b_spd1{:,1}, b_spd1{:,2}, desired_wavelengths, 'linear');

    % Normalize SPD data
    r_spd = r_spd / max(r_spd);
    g_spd = g_spd / max(g_spd);
    b_spd = b_spd / max(b_spd);

    % r_spd1 = r_spd1 / max(r_spd1);
    % g_spd1 = g_spd1 / max(g_spd1);
    % b_spd1 = b_spd1 / max(b_spd1);

    % figure
    % hold on
    % grid on
    % plot(desired_wavelengths, r_spd)
    % plot(desired_wavelengths, r_spd1)
    % plot(desired_wavelengths, g_spd)
    % plot(desired_wavelengths, g_spd1)
    % plot(desired_wavelengths, b_spd)
    % plot(desired_wavelengths, b_spd1)
    
    % Element-wise multiplication to simulate integration
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
    
    % Normalization
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
    
    rgb2opp_cvd = [RBW_int, GBW_int, BBW_int;
                   RBY_int, GBY_int, BBY_int;
                   RRG_int, GRG_int, BRG_int];
end