%=========================================================================%
% function [times, pre, post] = get_data_cyts(fin, var_names, conversions, shift, verbose)
%
% Get the data interpolate it, time shift post relative to pre, and maybe
% plot. Getting ready for optimisation
%
% Parameters
% ----------
% fin : dataset csv
% var_names : names of columns in the csv (4-cell array). These will be pre
%     and post respectively and cyt1 and cyt2
% conversions : multiple pre, post, cyt1, cyt2 by these scalars (change units)
% shift : shift in time units. See delay_shift.m
% verbose : plot interpolated shifted data?
%
% Returns
% -------
% times : time points
% pre : patients x time points
% post : patients x time points
% cyt1 : patients x time points
% cyt2 : patients x time points
%
% all patients are brought in and indexed in order.
% in my case number of patients is 10.
%=========================================================================%
function [times, pre, post, cyt1, cyt2, cyt3, cyt4] = get_data_cyts(fin, var_names, conversions, shift, verbose)


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
    cyt1_name = var_names{3};
    cyt2_name = var_names{4};
    cyt3_name = var_names{5};
    cyt4_name = var_names{6};
    
    for c_idx = 1:size(data, 2)
        if strcmp(col_names{c_idx}, pre_name)
            pre_idx = c_idx;
        elseif strcmp(col_names{c_idx}, post_name)
            post_idx = c_idx;
        elseif strcmp(col_names{c_idx}, cyt1_name)  
            cyt1_idx = c_idx;
        elseif strcmp(col_names{c_idx}, cyt2_name)
            cyt2_idx = c_idx;
        elseif strcmp(col_names{c_idx}, cyt3_name)
            cyt3_idx = c_idx;
        elseif strcmp(col_names{c_idx}, cyt4_name)
            cyt4_idx = c_idx;
        end
    end
    
    
    disp(['pre: ', pre_name]);
    pre = squeeze(data3D(:, pre_idx, :))*conversions(1);
    disp(['post: ', post_name]);
    post = squeeze(data3D(:, post_idx, :))*conversions(2);
    disp(['cyt1: ', cyt1_name]);
    cyt1 = squeeze(data3D(:, cyt1_idx, :))*conversions(3);
    disp(['cyt2: ', cyt2_name]);
    cyt2 = squeeze(data3D(:, cyt2_idx, :))*conversions(4);
    disp(['cyt3: ', cyt3_name]);
    cyt3 = squeeze(data3D(:, cyt3_idx, :))*conversions(5);
    disp(['cyt4: ', cyt4_name]);
    cyt4 = squeeze(data3D(:, cyt4_idx, :))*conversions(6);
    
    % Number of points to use (100x)
    pts = (max(size(post))-1)*10 + 1;
    % Interpolate and shift the data
    [~, pre] = interpolater_cyts(times, pre, pts);
    [~, cyt1] = interpolater_cyts(times, cyt1, pts);
    [~, cyt2] = interpolater_cyts(times, cyt2, pts);
    [~, cyt3] = interpolater_cyts(times, cyt3, pts);
    [~, cyt4] = interpolater_cyts(times, cyt4, pts);
    
    [times, post] = interpolater_cyts(times, post, pts);
    
    [new_times, new_pre, new_post, new_cyt1, new_cyt2, new_cyt3, new_cyt4] = ...
        delay_shift_cyts(times, pre, post, cyt1, cyt2, cyt3, cyt4, shift);
    
    
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
         figure();
        for idx = 1:size(cyt1, 2)
            subplot(5,2,idx);hold all;   
            plot(times, cyt1(:,idx), 'r',...
                 new_times, new_cyt1(:,idx),...
                 'r:','linewidth',2);
            legend(cyt1_name, 'cyt1-shift');
        end   
         figure();
        for idx = 1:size(cyt2, 2)
            subplot(5,2,idx);hold all;   
            plot(times, cyt2(:,idx), 'r',...
                 new_times, new_cyt2(:,idx),...
                 'r:','linewidth',2);
            legend(cyt2_name, 'cyt2-shift');
        end          
    end

    
    % set the outputs to shifted data
    times = new_times;
    pre = new_pre;
    post = new_post;
    cyt1 = new_cyt1;
    cyt2 = new_cyt2;
    cyt3 = new_cyt3;
    cyt4 = new_cyt4; 
    % Remove negative values
    min_pre = min(pre);
    min_pre(min_pre > 0) = 0;
    pre = pre - min_pre;
    
    % Remove negative values
    min_post = min(post);
    min_post(min_post > 0) = 0;
    post = post - min_post;
    
    % Remove negative values
    min_cyt1 = min(cyt1);
    min_cyt1(min_cyt1 > 0) = 0;
    cyt1 = cyt1 - min_cyt1;   
    
    % Remove negative values
    min_cyt2 = min(cyt2);
    min_cyt2(min_cyt2 > 0) = 0;
    cyt2 = cyt2 - min_cyt2; 
    
    % Remove negative values
    min_cyt3 = min(cyt3);
    min_cyt3(min_cyt3 > 0) = 0;
    cyt3 = cyt3 - min_cyt3;   
    
    % Remove negative values
    min_cyt4 = min(cyt4);
    min_cyt4(min_cyt4 > 0) = 0;
    cyt4 = cyt4 - min_cyt4;   
end
