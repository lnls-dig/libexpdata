function dataset = load_data(metadataset, associated_files)
%LOAD_DATA   Load all data files and store it in the 'dataset' structure.
%
%   dataset = LOAD_DATA(metadataset, associated_files)

%   Copyright (C) 2014 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

for i=1:length(associated_files)
    if strcmpi(metadataset(i).data_file_format, 'ascii')
        dataset{i} = load(associated_files{i});
    else
        % more data file formats??
    end
end