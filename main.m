function main_setup()

% specify 
folder_path_root = '/Users/pschm/fubox/BTAPE';
folder_path_dicom = '/Users/pschm/fubox/BTAPE-raw';

% add setup folder and subfolders for access to function
addpath(genpath(fullfile(folder_path_root, 'bids_setup')))

% bids setup for folder structure
bids_create(folder_path_root)

% convert dicom to nii and place into sourcedata
dicm2nii_sub(folder_path_root, folder_path_dicom)

% rename and move
bids_move(folder_path_root, folder_path_dicom)

% create dataset_description.json
create_description(folder_path_root)


rmpath(genpath(fullfile(folder_path_root, 'bids_setup')))
movefile(fullfile(folder_path_root, 'bids_setup'), fullfile(folder_path_root, 'code'))

end