function analysis_resolution(dataset, metadataset, Kx, Ky, legends, spectrum_method, data_type)

ndatasets = length(dataset);
for i=1:ndatasets
    high_freq = Inf;

    aux = textscan(metadataset(i).signal_carrier_frequency, '%f %s');
    signal_carrier_frequency = aux{1};

    aux = textscan(metadataset(i).adc_clock_sampling_harmonic, '%f %s');
    adc_clock_sampling_harmonic = aux{1};

    aux = textscan(metadataset(i).signal_carrier_harmonic_number, '%f %s');
    signal_carrier_harmonic_number = aux{1};

    aux = textscan(metadataset(i).dsp_data_rate_decimation_ratio, '%f %s');
    dsp_data_rate_decimation_ratio = aux{1};

    fadc = signal_carrier_frequency*adc_clock_sampling_harmonic/signal_carrier_harmonic_number;
    Fs = fadc/dsp_data_rate_decimation_ratio;

    abcd = dataset{i};

    if strcmpi(data_type, 'pos')
        data = calcpos(abcd, Kx, Ky);
    elseif strcmpi(data_type, 'abcd')
        data = abcd;
    end

    npts = size(data,1);
    if strcmpi(spectrum_method, 'rms') || strcmpi(spectrum_method, 'rms_reversed') || strcmpi(spectrum_method, 'psd')
        [~, spectrumdata, ~, freq] = psdrms(data, 1/Fs, 1, high_freq, hamming(floor(npts/10)), floor(npts/25), floor(npts/10), spectrum_method);
        freqset{i} = freq(2:end);
        spectrumset{i} = spectrumdata(2:end, :);
    elseif strcmpi(spectrum_method, 'dft')
        [fft_data, freq] = fourierseries(data, Fs, hamming(npts));
        freqset{i} = freq(3:end);
        spectrumset{i} = fft_data(3:end, :);
    end

end



% Plot function
handle_figure = figure;

lineclr = [lines(7); cool(5); copper(5)];
lineclr = [lineclr; lines(ndatasets-size(lineclr,2))];
linestyle = {'--', '-', ':', '-.'};
for i=1:ndatasets
    spectrumdata = spectrumset{i};
    freq = freqset{i};

    if strcmpi(spectrum_method, 'rms') || strcmpi(spectrum_method, 'rms_reversed')
        for j=1:size(spectrumdata,2)
            h(j) = loglog(freq, spectrumdata(:,j), 'Color', lineclr(i, :), 'LineStyle', linestyle{j}, 'LineWidth', 2);
            hold on;
            if j==2
                axis_with_legend(i) = h(j);
            end
        end
    elseif strcmpi(spectrum_method, 'dft') || strcmpi(spectrum_method, 'psd')
        for j=1:size(spectrumdata,2)
            handle_ax(j) = subplot(2, size(spectrumdata,2)/2, j);
            h(j) = semilogy(freq, spectrumdata(:,j), 'Color', lineclr(i, :), 'LineWidth', 2);
            hold on;
            grid on;
            if j==1
                axis_with_legend(i) = h(j);
            end
        end
        linkaxes(handle_ax, 'xy');
    end

    if strcmpi(data_type, 'abcd')
        data_type_name = 'ABCD amplitudes';
        plane = {'Atenna A', 'Atenna B', 'Atenna C', 'Atenna D'};
        y_unit = 'a.u.';
    elseif strcmpi(data_type, 'pos')
        data_type_name = 'Beam position';
        plane = {'Horizontal plane', 'Vertical plane'};
        y_unit = 'nm';
    end

    for j=1:length(h)
        userdata.plane = plane{j};

        if strcmpi(spectrum_method, 'rms') || strcmpi(spectrum_method, 'rms_reversed')
            userdata.spectrum_name = 'RMS';
            userdata.spectrum_unit = y_unit;
        elseif strcmpi(spectrum_method, 'psd')
            userdata.spectrum_name = 'PSD';
            userdata.spectrum_unit = [y_unit '^2/Hz'];
        elseif strcmpi(spectrum_method, 'dft')
            userdata.spectrum_name = 'Amplitude';
            userdata.spectrum_unit = y_unit;
        end

        userdata.legend = legends(i,:);
        set(h(j), 'UserData', userdata);
    end



    legend_text{i} = '';
    for j=1:size(legends,2)
        legend_text{i} = [legend_text{i} legends{i,j} ' / '];
    end

    dcm_obj = datacursormode(handle_figure);
    set(dcm_obj,'enable','on')
    set(dcm_obj,'UpdateFcn', @update_datatip)
end

% position/sqrt(Hz) reference plots
axis tight;
axlimits = axis;



grid on;
hold on;

if strcmpi(spectrum_method, 'rms') && strcmpi(data_type, 'pos')
    minx = axlimits(1);
    maxx = axlimits(2);

    f = linspace(minx, maxx, 1000);
    handle_ref = loglog(f, sqrt([1^2*f' 2^2*f' 4^2*f' 10^2*f' 100^2*f']), 'Color', [0.4 0.4 0.4], 'LineWidth', 2, 'LineStyle', ':');

    userdata.plane = 'Reference';
    userdata.spectrum_name = 'RMS';
    userdata.spectrum_unit = y_unit;
    userdata.legend = {''};

    set(handle_ref, 'UserData', userdata);


    text(1.05*f(end), sqrt(1^2*f(end)), '1 nm/sqrt(Hz)');
    text(1.05*f(end), sqrt(2^2*f(end)), '2 nm/sqrt(Hz)');
    text(1.05*f(end), sqrt(4^2*f(end)), '4 nm/sqrt(Hz)');
    text(1.05*f(end), sqrt(10^2*f(end)), '10 nm/sqrt(Hz)');
    text(1.05*f(end), sqrt(100^2*f(end)), '100 nm/sqrt(Hz)');
end


if strcmpi(spectrum_method, 'rms') || strcmpi(spectrum_method, 'rms_reversed')
    xlabel('Frequency [Hz]', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel(['Integrated RMS [' y_unit ']'], 'FontSize', 16, 'FontWeight', 'bold');
    title(['Integrated RMS - ' data_type_name], 'FontSize', 16, 'FontWeight', 'bold');
end

for i=1:length(plane)
    if strcmpi(spectrum_method, 'psd')
        subplot(2, size(spectrumdata,2)/2, i);
        ylabel(['PSD [' y_unit '^2/Hz]'], 'FontSize', 16, 'FontWeight', 'bold');
        title([plane{i} ' PSD'], 'FontSize', 16, 'FontWeight', 'bold');
    elseif strcmpi(spectrum_method, 'dft')
        subplot(2, size(spectrumdata,2)/2, i);
        ylabel(['Amplitude [' y_unit ']'], 'FontSize', 16, 'FontWeight', 'bold');
        title([plane{i} ' FFT'], 'FontSize', 16, 'FontWeight', 'bold');
    end
    xlabel('Frequency [Hz]', 'FontSize', 16, 'FontWeight', 'bold');
end

axis tight;

% Labels




if ~isempty(axis_with_legend) && ~isempty(legend_text)
    legend(axis_with_legend, legend_text, 'FontSize', 8, 'Location', 'NorthWest', 'Interpreter', 'none');
end
