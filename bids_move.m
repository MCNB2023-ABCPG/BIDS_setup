function bids_move(folder_path_root, folder_path_dicom, folder_path_code)

% move converted .nii into existing folder structure and rename
% according to BIDS
% Paul Schmitthäuser (03.06.2024)


%folder_path_code = fullfile(folder_path_root, 'code');
folder_path_sourcedata = fullfile(folder_path_root, 'sourcedata');


% load folder structure from bids setup
load(fullfile(folder_path_code, 'exp_var.mat'));
%folder_base_pipeline_raw = folder_base_pipelines{1}; % double check which index has been specified in bids_setup


% Structure to specify the run names of the sourcedata
key = [];
key{1}.id = sub_all(1);
key{1}.ses = ses_all(1,:);
%key{1}.run = run_all(1,:);
key{1}.run = [run_all(1,:), '008'];
%key{1}.source = {'s005.nii', 's008.nii', 's011.nii', 's014.nii', 's017.nii', 's019.nii', 's021.nii'}
key{1}.source = {'s005.nii', 's008.nii', 's011.nii', 's014.nii', 's017.nii', 's019.nii', 's021.nii', 's023.nii'};
key{1}.log = {'run-01', 'run-02', 'run-03', 'run-04', 'run-05', 'run-06', 'localizer1', 'localizer2'};

key{2}.id = sub_all(2);
key{2}.ses = ses_all(2,:);
key{2}.run = run_all(2,:);
key{2}.source = {'s004.nii', 's005.nii', 's006.nii', 's007.nii', 's009.nii', 's010.nii', 's011.nii'};
key{2}.log = {'run-01', 'run-02', 'run-03', 'run-04', 'run-05', 'run-06', 'localizer'};


for s=1:numel(sub_all)

    folder_path_sourcedata_sub = fullfile(folder_path_sourcedata, strcat('sub-', sub_all{s}));
    folder_path_log_sub = fullfile(folder_path_dicom, strcat('sub-', sub_all{s}));

for ss=1:numel(ses_all(s,:))
    
    if isscalar(ses_all(s,:))
        folder_path_sourcedata_ses = folder_path_sourcedata_sub;
        folder_path_log_ses = fullfile(folder_path_log_sub, 'func');
    else
        folder_path_sourcedata_ses = fullfile(folder_base_pipeline_ses,strcat('ses-', ses_all{s,ss}));
        folder_path_log_ses = fullfile(folder_path_log_sub, strcat('ses-', ses_all{s,ss}), 'func');
    end

    load(fullfile(folder_path_sourcedata_ses, 'dcmHeaders.mat'), 'h');
    file_base_sourcedata = dir(folder_path_sourcedata_ses);
    file_base_sourcedata = file_base_sourcedata(3:end);
    
    file_base_log = dir(folder_path_log_ses);
    file_base_log = file_base_log(3:end);


for i=1:numel(file_base_sourcedata)
    
    str_elem = strsplit(file_base_sourcedata(i).name, '_');
    
    % detect anatomical scan
    if strcmp(str_elem{1}, 'anat')
        file_base_bids = ['sub-', key{s}.id{:}];

        % TODO adding ses- 
        if ~isscalar(key{s}.ses)
            %file_base_bids = [file_base_bids, '_ses-', key{1}.ses{:}];
            %file_path_bids = fullfile(folder_path_root, '_ses-', key{1}.ses{:});
        end

        file_base_bids = [file_base_bids, '_T1w.nii'];
        file_path_bids = fullfile(folder_path_root, strcat('sub-', key{s}.id{:}), 'anat' ,file_base_bids);
        file_path_sourcedata = fullfile(folder_path_sourcedata_ses, file_base_sourcedata(i).name);
        copyfile(file_path_sourcedata, file_path_bids)



        [dcmHeader_idx, dcmHeader_struct] = extract_header(h, file_base_sourcedata(i).name);
        if ~isnan(dcmHeader_idx)
            dcmHeader_struct = rmfield(dcmHeader_struct,'Filename');
            %dcmHeader_struct.SliceTiming = abs(dcmHeader_struct.SliceTiming);
            %dcmHeader_struct.RepetitionTime = 1;
            encoded = jsonencode(dcmHeader_struct, PrettyPrint=true);
            file_path_json = replace(file_path_bids,'.nii','.json');
            fid = fopen(file_path_json,'w');
            fprintf(fid,'%s',encoded);
            fclose(fid);
        end

    end

    % detect functional scan
    if ~isscalar(str_elem)

        if ((strcmp(str_elem{1}, 'func') | strcmp(str_elem{2}, 'func')) & ~strcmp(str_elem{end}, 'epi.nii'))
            file_base_bids = ['sub-', key{s}.id{:}];
    
            % TODO adding ses- 
            if ~isscalar(key{s}.ses)
                %file_base_bids = [file_base_bids, '_ses-', key{1}.ses{:}];
                %file_path_bids = fullfile(folder_path_root, '_ses-', key{1}.ses{:});
            end
            
            % adding task-
            file_base_bids = [file_base_bids, '_task-BTP'];
    
            % adding run- (here, we have to match from the key

            matched_idx = strcmp(str_elem(end), key{s}.source);
            
            if any(matched_idx)
                matched_run = key{s}.run(matched_idx);
                file_base_bids = [file_base_bids, '_run-', matched_run{:}];
                file_base_bids = [file_base_bids, '_bold.nii'];
                file_path_bids = fullfile(folder_path_root, strcat('sub-', key{s}.id{:}), 'func' ,file_base_bids);
                file_path_sourcedata = fullfile(folder_path_sourcedata_ses, file_base_sourcedata(i).name);
                copyfile(file_path_sourcedata, file_path_bids)
            end
                
            [dcmHeader_idx, dcmHeader_struct] = extract_header(h, file_base_sourcedata(i).name);
            if ~isnan(dcmHeader_idx)
                dcmHeader_struct = rmfield(dcmHeader_struct,'Filename');
                dcmHeader_struct.TaskName = 'BTP';
                dcmHeader_struct.SliceTiming = abs(dcmHeader_struct.SliceTiming);
                dcmHeader_struct.RepetitionTime = 1;
                encoded = jsonencode(dcmHeader_struct, PrettyPrint=true);
                file_path_json = replace(file_path_bids,'.nii','.json');
                fid = fopen(file_path_json,'w');
                fprintf(fid,'%s',encoded);
                fclose(fid);
            end

        

        end % detect functional
    end % exclude scalar file aka dcmHeader

end % loop elements in sourcedata

for i=1:numel(file_base_log)
    file_base_bids = ['sub-', key{s}.id{:}];
    str_elem = strsplit(file_base_log(i).name, '_');
    %disp(file_base_log{i}.name);
    
    if strcmp(str_elem{1}, 'log')
        
        matched_idx = strcmp(str_elem(end-1), key{s}.log);

        if any(matched_idx)
            matched_run = key{s}.run(matched_idx);
            file_base_bids = [file_base_bids,'_task-BTP', '_run-', matched_run{:}, '_log.mat'];
            %file_base_bids = [file_base_bids, '_log.mat'];
            file_path_bids = fullfile(folder_path_root, strcat('sub-', key{s}.id{:}), 'func' ,file_base_bids);
            file_path_sourcedata = fullfile(folder_path_log_ses, file_base_log(i).name);
            copyfile(file_path_sourcedata, file_path_bids)
        end


    end

end


end % loop ses
end % loop sub
end % function

