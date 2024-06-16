function main()

% specify 
folder_path_root = '/Users/pschm/BTAPE_local';
folder_path_dicom = '/Users/pschm/BTAPE_raw';
folder_path_code_setup = '/Users/pschm/icloud_link/University/mcnb/2_semester/NMP/BIDS_setup';
folder_path_code = '/Users/pschm/icloud_link/University/mcnb/2_semester/NMP/BTAPE_code';

% add setup folder and subfolders for access to function
addpath(genpath(folder_path_code_setup));

% bids setup for folder structure
bids_create(folder_path_root)

% convert dicom to nii and place into sourcedata
dicm2nii_sub(folder_path_root, folder_path_dicom)

% rename and move
bids_move(folder_path_root, folder_path_dicom, folder_path_code)

% create dataset_description.json
create_description(folder_path_root)


rmpath(genpath(folder_path_code_setup))
%movefile(fullfile(folder_path_root, 'bids_setup'), fullfile(folder_path_root, 'code'))

end