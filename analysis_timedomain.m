function analysis_timedomain(dataset, metadataset, Kx, Ky, legends, data_type)

data_bundle = [];
data_bundle_ac = [];
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
    
    data_bundle = [data_bundle; data; ones(1,size(data,2))*NaN];
    data_bundle_ac = [data_bundle_ac; data-repmat(mean(data), size(data,1), 1); ones(1,size(data,2))*NaN]; 
end








if strcmpi(data_type, 'abcd')
    data_type_name = 'ABCD amplitudes';
    plane = {'A', 'B', 'C', 'D'};
    y_unit = 'a.u.';
elseif strcmpi(data_type, 'pos')
    data_type_name = 'Beam position';
    plane = {'Horizontal plane', 'Vertical plane'};
    y_unit = 'nm';
end


t = (0:size(data_bundle,1)-1)/Fs;



figure;
handle_ax(1) = subplot(211);
plot(t, data_bundle);

grid on
legend(plane, 'FontSize', 8, 'Location', 'NorthWest', 'Interpreter', 'none')
xlabel('Time [s]', 'FontSize', 16, 'FontWeight', 'bold');
ylabel([data_type_name ' [' y_unit ']'], 'FontSize', 16, 'FontWeight', 'bold');

handle_ax(2) = subplot(212);
plot(t, data_bundle_ac);

linkaxes(handle_ax, 'x');

ax = axis(gca);
ax(1:2) = [t(1) t(end)];
axis(ax);

grid on
legend(plane, 'FontSize', 8, 'Location', 'NorthWest', 'Interpreter', 'none')
xlabel('Time [s]', 'FontSize', 16, 'FontWeight', 'bold');
ylabel([data_type_name ' (w/o DC) [' y_unit ']'], 'FontSize', 16, 'FontWeight', 'bold');