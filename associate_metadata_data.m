function [associated_metadatafiles, associated_files] = associate_metadata_data(metadata_filenames, files_ignatures)
%ASSOCIATE_METADATA_DATA   For each metadata file, look for a data file 
%   with the corresposding signature (MD5, SHA-1 or SHA-256).
%
%   [associated_metadatafiles, associated_files] = ASSOCIATE_METADATA_DATA(metadata_filenames, files_ignatures)

%   Copyright (C) 2014 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

j=1;
for i=1:length(metadata_filenames)
    [signature, method] = metadata_getsignature(metadata_filenames{i});
    if strcmpi(method, 'md5')
        aux = find(strcmpi({files_ignatures.md5}', signature));
    elseif strcmpi(method, 'sha-1')
        aux = find(strcmpi({files_ignatures.sha1}', signature));
    elseif strcmpi(method, 'sha-256')
        aux = find(strcmpi({files_ignatures.sha256}', signature));
    else
        aux = [];
    end
        
    if ~isempty(aux)
        associated_metadatafiles{j,1} = metadata_filenames{i};
        associated_files{j,1} = files_ignatures(aux(1)).name;
        j = j+1;
    else
        warning('Could not find data file described at ''%s'' with %s signature %s.', metadata_filenames{i}, upper(method), signature);
    end
end