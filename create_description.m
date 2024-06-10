function create_description(folder_path_root)

description = [];
description.Name = 'final';
description.BIDSVersion = '1.9.0';
encoded = jsonencode(description, PrettyPrint=true);
fid = fopen(fullfile(folder_path_root,'dataset_description.json'),'w');
fprintf(fid,'%s',encoded);
fclose(fid);

end