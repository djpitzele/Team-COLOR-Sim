function plot_LMS_OPP_curves(red_shift , green_shift , blue_shift , fsize, lwidth, width, height)
    % Load in LMS cone sensitivity functions and interpolate data
    LMS_cmf = readtable('../data_tables/LMS_data.csv');
    wavelengths = 390:1:830;
    l_data = interp1(LMS_cmf{:,1}, LMS_cmf{:,2}, wavelengths, 'cubic');
    m_data = interp1(LMS_cmf{:,1}, LMS_cmf{:,3}, wavelengths, 'cubic');
    s_data = interp1(LMS_cmf{:,1}, LMS_cmf{:,4}, wavelengths, 'cubic');
    
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
    
    % Extract Opponent Process Curves
    YB_data = opp_data(:,2)';
    RG_data = opp_data(:,3)';

    % Plot and export data
    outputfolder = fullfile(pwd,"plots");
    if ~isfolder("plots")
        mkdir("plots");
    end
    figure('Position', [100, 100, width, height]);
    xlabel('Wavelength (nm)')
    ylabel('Relative Sensitivity')
    hold on;
    grid on;
    plot(wavelengths, l_cvd, 'r', DisplayName="L", LineWidth=lwidth)
    plot(wavelengths, m_cvd, 'g', DisplayName="M", LineWidth=lwidth)
    plot(wavelengths, s_cvd, 'b', DisplayName="S", LineWidth=lwidth)
    title_str1 = strcat("LMS Cone Sensitivity, \lambda_{rs} = ", ...
        num2str(red_shift), ", \lambda_{gs} = ", ...
        num2str(green_shift));
    title(title_str1);
    legend;
    xlim([min(wavelengths) max(wavelengths)])
    ylim([0 1.05])
    fontsize(gcf, fsize, 'points')
    fname1 = strcat("LMS_PLOT_R", num2str(red_shift), "_G", num2str(green_shift), ".png");
    fname1 = fullfile(outputfolder, fname1);
    exportgraphics(gcf, fname1);

    figure('Position', [100, 100, width, height]);
    xlabel('Wavelength (nm)')
    ylabel('Chromatic Response')
    hold on;
    grid on;
    p1 = yline(0, 'k--', LineWidth=lwidth);
    p2 = plot(wavelengths, RG_data, 'r', DisplayName="Red-Green", LineWidth=lwidth);
    p3 = plot(wavelengths, YB_data, 'b', DisplayName="Yellow-Blue", LineWidth=lwidth);
    title_str1 = strcat("Opponent Color Space Chromatic Reponse, \lambda_{rs} = ", ...
        num2str(red_shift), ", \lambda_{gs} = ", ...
        num2str(green_shift));
    title(title_str1)
    legend([p2 p3]);
    xlim([min(wavelengths) max(wavelengths)])
    fontsize(gcf, fsize, 'points')
    fname2 = strcat("OPP_PLOT_R", num2str(red_shift), "_G", num2str(green_shift), ".png");
    fname2 = fullfile(outputfolder, fname2);
    exportgraphics(gcf, fname2);
end
