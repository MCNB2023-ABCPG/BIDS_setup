function dicom2nii_sub(folder_path_root, folder_path_dicom, folder_path_code)

%folder_path_code = fullfile(folder_path_root, 'code');
folder_path_sourcedata = fullfile(folder_path_root, 'sourcedata');

load(fullfile(folder_path_code, 'exp_var.mat'));


for i=1:numel(sub_all)
    fmt_sub = strcat('sub-', sub_all{i});
    folder_path_dicom_sub = fullfile(folder_path_dicom, fmt_sub);
    folder_path_sourcedata_sub = fullfile(folder_path_sourcedata, fmt_sub);
    
    for j=1:numel(ses_all(i,:))

        if isscalar(ses_all(i,:))
            folder_path_dicom_ses = folder_path_dicom_sub;
            folder_path_sourcedata_ses = folder_path_sourcedata_sub;
        else
            fmt_ses = strcat('ses-', ses_all{i,j});
            folder_path_dicom_ses = fullfile(folder_path_dicom_sub, fmt_ses);
            folder_path_sourcedata_ses = fullfile(folder_path_sourcedata_sub, fmt_ses);
        end

        %mkdir(folder_path_sourcedata_ses);
    end
    
    dicm2nii(folder_path_dicom_ses, folder_path_sourcedata_ses, 0)
end


end