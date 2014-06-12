clear
close all

Kx = 10e6;
Ky = 10e6;
parameter_dependence = ''; % '', 'bcd', 'fpd'
spectrum_rms = 'on';
spectrum_rms_reversed = 'off';
spectrum_psd = 'off';
spectrum_dft = 'on';
data_type = 'pos'; % 'pos', 'abcd'

if ispc
    rootpath = fullfile('\\centaurus','Respositorio');
elseif isunix
    rootpath = fullfile('/media','centaurus');
end
basepath = fullfile(rootpath,'Grupos','DIG','Projetos','Ativos','ALL_EBPM','Tests');

datapath = 'fofb';
search_directories = {...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325i',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325j',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140326A_userBeam500mA_1-8dBatt_A',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325l','switching_off_sausaging_off',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325l','switching_on_sausaging_off',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325k','switching_on_sausaging_on',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_injection',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_fillingpattern1','switching_off_sausaging_off',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_fillingpattern2b','switching_off_sausaging_off',datapath), ...
    %fullfile(basepath,'LNLS_2014.03','sweep_redemption_song','switching_on',datapath), ...
    %fullfile(basepath,'LNLS_2014.03','sweep_BCD2','switching_on',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_lowalpha','i',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_lowalpha','j',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_lowalpha','m','switching_on_sausaging_off',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_lowalpha','n',datapath), ...
    %fullfile(basepath,'SSRL_2014.03','Beam','20140325_lowalpha','o','switching_on_sausaging_off',datapath), ...
    fullfile(basepath,'buffer',datapath),...
    };

[metadata_filenames, file_signatures] = search_metadata(search_directories);
[associated_metadatafiles, associated_files] = associate_metadata_data(metadata_filenames, file_signatures);
metadataset = load_metadata(associated_metadatafiles);

% Sort experiments by start time
[~,index_reordered]=sort({metadataset.timestamp_start});
metadataset = metadataset(index_reordered);
associated_metadatafiles = associated_metadatafiles(index_reordered);
associated_files = associated_files(index_reordered);
dataset = load_data(metadataset, associated_files);

parameter_names = fieldnames(metadataset);
variable_parameters = find_variable_parameters(metadataset);

% Ignore infrastructure fields such as experiment date and time, timezone,
% data file signature, data filename, etc.
ignore_parameters = {'location_timezone', 'data_general_description', 'data_signature', 'data_signature_method', 'data_original_filename', 'timestamp_start'};
variable_parameters = setdiff(variable_parameters, ignore_parameters);

nonvariable_parameters = setdiff(parameter_names, variable_parameters);

% Build plot legend structure, where each line refers to an experiment,
% each column refers to a particular parameter of the experiment

for i=1:length(metadataset)
    if ~isempty(variable_parameters)
        for j=1:length(variable_parameters)
            legends{i,j} = [variable_parameters{j} ' = ' getfield(metadataset(i), variable_parameters{j})];
        end
    else
        legends{i,1} = ['data' num2str(i)];
    end
end

% Time domain analysis
analysis_timedomain(dataset, metadataset, Kx, Ky, legends, data_type)

% Parameter dependece analysis
if strcmpi(parameter_dependence, 'bcd')
    analysis_parameter_dependence(dataset, metadataset, Kx, Ky, 'rffe_signal_carrier_inputpower');
elseif strcmpi(parameter_dependence, 'fpd')
    analysis_parameter_dependence(dataset, metadataset, Kx, Ky, 'beam_pattern_fill');
end

% Spectral analysis
if strcmpi(spectrum_rms, 'on')
    analysis_resolution(dataset, metadataset, Kx, Ky, legends, 'rms', data_type);
end
if strcmpi(spectrum_rms_reversed, 'on')
    analysis_resolution(dataset, metadataset, Kx, Ky, legends, 'rms_reversed', data_type);
end
if strcmpi(spectrum_psd, 'on')
    analysis_resolution(dataset, metadataset, Kx, Ky, legends, 'psd', data_type);
end
if strcmpi(spectrum_dft, 'on')
    analysis_resolution(dataset, metadataset, Kx, Ky, legends, 'dft', data_type);
end
