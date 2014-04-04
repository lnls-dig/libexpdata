clear
close all

search_directories = {'/media/centaurus/Grupos/DIG/Projetos/Ativos/ALL_EBPM/Tests/SSRL_2014.03/'};

metadata_filenames = search_metadata(search_directories, false);
metadataset = load_metadata(metadata_filenames);

for i=1:length(metadataset)
    %metadataset(i).beam_bunch_length = '5 ps';
    if strcmpi(metadataset(i).dsp_data_rate_decimation_ratio, '50')
        metadataset(i).dsp_data_rate_decimation_ratio = '35';
    end
end

save_metadata(metadataset, metadata_filenames)