function [metadata_filenames, file_signatures] = search_metadata(search_directories, compute_signature)
%SEARCH_METADATA   Search all metadata files in each directory path and
%   corresponding subdirectories.
%
%   [metadata_filenames, file_signatures] = SEARCH_METADATA(search_directories)

%   Copyright (C) 2014 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

if ~iscellstr(search_directories) && ischar(search_directories)
    aux = search_directories;
    search_directories = cell(1,1);
    search_directories{1} = aux;
elseif ~iscellstr(search_directories)
    error('''search_directories'' must be a string or cell array of strings.');
end

if nargin < 2
    compute_signature = true;
end

l=1;
m=1;
for i=1:length(search_directories)
    % Depending on the operating system, the 'genpath' function returns
    % the subdirectories of a directory path separated by ':' (UNIX) or
    % ';' (Windows)
    if ispc
        path_separator = ';';
    else
        path_separator = ':';
    end
    
    % Get all subdirectories of a path
    search_subdirectories = regexp(genpath(search_directories{i}),['[^' path_separator ']*'],'match');
    
    % List all metadata file names and compute the signatures of all
    % non-metadata files in the path
    for j=1:length(search_subdirectories)
        filenames = dir(search_subdirectories{j});
        filenames = filenames(~[filenames.isdir]);

        for k=1:length(filenames)
            filename = fullfile(search_subdirectories{j}, filenames(k).name);
            [dummy, dummy, file_extension] = fileparts(filename);
            if strcmpi(file_extension, '.metadata')
                metadata_filenames{l,1} = filename;
                l=l+1;
            elseif compute_signature
                file_signatures(m,1).name = filename;
                file_signatures(m,1).md5 = filesignature(filename, 'md5');
                file_signatures(m,1).sha1 = filesignature(filename, 'sha-1');
                file_signatures(m,1).sha256 = filesignature(filename, 'sha-256');
                m=m+1;
            end
        end
    end
end

if ~compute_signature
    file_signatures = [];
end