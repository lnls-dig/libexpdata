function save_metadata(metadataset, metadata_filenames)
%SAVE_METADATA   Save a 'metadataset' cvontaining metadata information
%    into files.
%
%   SAVE_METADATA(metadata_files, metadata_filenames)

%   Copyright (C) 2014 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

if ~iscellstr(metadata_filenames) && ischar(metadata_filenames)
    aux = metadata_filenames;
    metadata_filenames = cell(1,1);
    metadata_filenames{1} = aux;
elseif ~iscellstr(metadata_filenames)
    error('''metadata_filenames'' must be a string or cell array of strings.');
end

if length(metadataset) ~= length(metadata_filenames)
    error('''metadataset'' and ''metadata_filenames'' must have equal lengths.');
end

parameter_names = fieldnames(metadataset);

for i=1:length(metadata_filenames)
    fid = fopen(metadata_filenames{i}, 'w+');
    for j=1:length(parameter_names)
        parameter_value = getfield(metadataset, {i}, parameter_names{j});
        if ~isempty(parameter_value)
            fprintf(fid, '%s = %s\n', parameter_names{j}, parameter_value);
        end
    end
    fclose(fid);
end