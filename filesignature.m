function hash = filesignature(filename, method)

import java.security.*;

rawdatafiletext = fileread(filename);
md = java.security.MessageDigest.getInstance(method);
hash_aux = lower(dec2hex(typecast(md.digest(uint8(rawdatafiletext)),'uint8')));
hash = [];
for i=1:size(hash_aux,1)
    hash = [hash hash_aux(i,:)];
end
