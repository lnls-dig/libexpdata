function metadataset = load_metadata(metadata_filenames)
%LOAD_METADATA   Load all metadata files' information and store it in the
%   'metadataset' structure.
%
%   metadataset = LOAD_METADATA(metadata_files)

%   Copyright (C) 2014 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

if ~iscellstr(metadata_filenames) && ischar(metadata_filenames)
    aux = metadata_filenames;
    metadata_filenames = cell(1,1);
    metadata_filenames{1} = aux;
elseif ~iscellstr(metadata_filenames)
    error('''metadata_filenames'' must be a string or cell array of strings.');
end

metadataset = struct;
for i=1:length(metadata_filenames)
    text = fileread(metadata_filenames{i});
    C = textscan(text, '%s %s', 'Delimiter', '=', 'CommentStyle', '#');
    parameters = C{1};
    values = C{2};
    parameters = strtrim(parameters);
    values = strtrim(values);

    for j=1:length(parameters)
        metadataset = setfield(metadataset, {i, 1}, parameters{j}, values{j});
    end
end
metadataset = orderfields(metadataset);