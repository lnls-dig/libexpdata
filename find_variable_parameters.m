function variable_parameters = find_variable_parameters(metadataset)
%FIND_VARIABLE_PARAMETERS   Find which parameters have changed from one
%   experiment to the other.
%
%   variable_parameters = FIND_VARIABLE_PARAMETERS(metadataset)

%   Copyright (C) 2014 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)

parameter_names = fieldnames(metadataset);
k = 1;
variable_parameters = {};
for i=1:length(parameter_names)
    parameter_value = eval(['{metadataset.' parameter_names{i} '}']);
    for j=1:length(parameter_value)
        if isempty(parameter_value{j})
            parameter_value{j} = '';
        end
    end
    unique_parameter_values = unique(parameter_value);
    if length(unique_parameter_values) > 1
        variable_parameters{k} = parameter_names{i};
        k = k+1;
    end
end