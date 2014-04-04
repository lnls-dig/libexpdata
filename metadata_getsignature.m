function [signature, method] = metadata_getsignature(filename)

metadata = load_metadata(filename);

try
    signature = metadata.data_signature;
    method = metadata.data_signature_method;
catch
    signature = '';
    method = '';
end