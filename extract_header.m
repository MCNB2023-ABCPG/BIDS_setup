function [idx, h_struct] = extract_header(h, name)
    h_cell = struct2cell(h);

    for k=1:numel(h_cell)
        if strcmp([h_cell{k}.NiftiName,'.nii'], name)
            idx = k;
            h_struct = h_cell{k};
            return
        end
    end
    idx = NaN;
    h_struct = NaN;
    return
        
end
