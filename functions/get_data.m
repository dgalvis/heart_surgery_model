%=========================================================================%
% function [times, pre, post] = get_data(fin, var_names, conversions, shift, verbose)
%
% Get the data interpolate it, time shift post relative to pre, and maybe
% plot. Getting ready for optimisation
%
% Parameters
% ----------
% fin : dataset csv
% var_names : names of columns in the csv (2-cell array). These will be pre
%     and post respectively
% conversions : multiple pre and post by these scalars (change units)
% shift : shift in time units. See delay_shift.m
% verbose : plot interpolated shifted data?
%
% Returns
% -------
% times : time points
% pre : patients x time points
% post : patients x time points
%
% all patients are brought in and indexed in order.
% in my case number of patients is 10.
%=========================================================================%
function [times, pre, post] = get_data(fin, var_names, conversions, shift, verbose)


    % Read data
    full_table = readtable(fin);
    % Patient IDs
    patients = unique(full_table.patient, 'stable');
    % Times
    times = unique(full_table.time);
    % Turn into an array
    data_table = removevars(full_table, {'patient', 'time'});
    data = table2array(data_table);
    % Column names
    col_names = data_table.Properties.VariableNames;

    % Populate all data except time in 3d array
    data3D = zeros(sum(full_table.patient == patients(1)), ...
                   size(data, 2), ...
                   max(size(patients)));
    % Array of data
    for pats = 1:max(size(patients))
        data3D(:, :, pats) = data(full_table.patient == patients(pats), :);
    end

    
    % Set pre and post time series'
    pre_name = var_names{1}; %col_names(pre_idx);
    post_name = var_names{2}; %col_names(post_idx);
    for c_idx = 1:size(data, 2)
        if strcmp(col_names{c_idx}, pre_name)
            pre_idx = c_idx;
        elseif strcmp(col_names{c_idx}, post_name)
            post_idx = c_idx;
        end
    end
    
    
    disp(['pre: ', pre_name]);
    pre = squeeze(data3D(:, pre_idx, :))*conversions(1);
    disp(['post: ', post_name]);
    post = squeeze(data3D(:, post_idx, :))*conversions(2);


    % Number of points to use (100x)
    pts = (max(size(post))-1)*10 + 1;
    % Interpolate and shift the data
    [~, pre] = interpolater(times, pre, pts);
    [times, post] = interpolater(times, post, pts);
    [new_times, new_pre, new_post] = delay_shift(times, pre, post, shift);

    
    % Maybe plot the data and the shifted data
    if verbose
        figure();
        for idx = 1:size(pre, 2)
            subplot(5,2,idx);hold all;
            
            plot(times, pre(:,idx), 'k', ...
                 new_times, new_pre(:,idx), 'k:',...
                 'linewidth',2);
            legend(pre_name, 'pre-shift');
        end
         figure();
        for idx = 1:size(post, 2)
            subplot(5,2,idx);hold all;   
            plot(times, post(:,idx), 'r',...
                 new_times, new_post(:,idx),...
                 'r:','linewidth',2);
            legend(post_name, 'post-shift');
        end           
    end

    
    % set the outputs to shifted data
    times = new_times;
    pre = new_pre;
    post = new_post;
    
    % Remove negative values
    min_pre = min(pre);
    min_pre(min_pre > 0) = 0;
    pre = pre - min_pre;
    
    % Remove negative values
    min_post = min(post);
    min_post(min_post > 0) = 0;
    post = post - min_post;
    

end
