%=========================================================================%
% Function: run_analysis.m (bear is the hpc)
% Author: Daniel Galvis
%
% Description: This code does the group level analysis of the optimisations.
% That is, it uses the mean squared error over all surgical and all controls.
%
% We are only looking at the two-compartment model ('double')
% We look at the mean method with dists = 650
% This just means that the optimiser looks for the smallest difference 
% between model output and cortisol trajectory (no sliding windows)
%
% The code also does the Subgroup level analysis for :
% NOTE: in pats subgroups are
% sg1 = [1,5,6,7]
% sg2 = [2,3,8]
% sg3 = [4,9,10]
% These have been determined in a quantitative manner by a different
% package (see manuscript)
%
%
% This code also does the individual analysis
%
%
% Parameters
% ----------
% dists : float
%     This code assumes the length and slide are the same (see
%     run_ode_bear.m)
% type: {'double', 'fft'}
%   - 'single' or 'double' (one or two compartment model)
%   - 'fft' or 'mean' (cost function evaluated on data in time or frequency
% run_id : The number on the end of the runs in ./results 
%
% visual : plot results? (slower! better to do it from the csv outputs)
% threshold: Keep 10% deviation from the lowest error in the
% grab_parameters (if val is 1.1), 1.05 5% etc
% 
% This code has multiple sections:
%     No Fixed Parameters: create csv files for best group optimisations
%     of controls and surgicals (all 6 parameters are variable)
%
%     Parameter 4, the integer parameter m, is chosen based on which value
%     in m = 1,2,3,4 has the max number of top solutions in the control
%     data
%   
%     csv files are saved of top solutions with m = fixed as well "m2 csv" files
%
%     The top trajectories for both controls and surgicals are put in csv files
%
%     Trajectories are plotted
%     
%     Other sections: m_runs - m = fixed other 5 parameters are variable
%                     KA_runs - m = fixed, KA variable, p_f, p_s fixed
%                     p_runs  - m = fixed, KA fixed, p_f, p_s variable
%
%     For these cases, the top surgical and control parameters and trajectories
%     are saved as csv files (and plotted)
%
%     All csv files are place in the same places as the .mat files with the
%     latin hypercube optimisations.
%=========================================================================%
%% Setup 
    %restoredefaultpath;clear;close all;clc;

function run_analysis(type, dists, run_id, visual, threshold)

    % Define the parallel pool
    % The first try is for BlueBear UniBirm HPC
    try
        % Define parallel pool
        pc = parcluster('local');
        pc.JobStorageLocation = getenv('TMPDIR');
        parpool(pc, str2num(getenv('SLURM_TASKS_PER_NODE')));
    catch
        try
            parpool('local', 18);
        catch
            try
                parpool('local');
            catch
                disp('parpool active');
            end
        end
    end



    addpath('data');
    addpath('functions');
    addpath('functions_analysis');
    load('data_all.mat', 'times', 'pre', 'post');

    pats_s = 1:10;
    pats_c = 11:13;

    %type = {'double', 'fft'}; % mean or fft can be used
    fout_s = 'surgical_group';
    fout_c = 'control_group';
    %dists = 50; % 650 or 50 available (sliding window type)
    
    % Subgroup definitions (based on quantitative assessment of data)
    pats_sg1 = [1,5,6,7];
    pats_sg2 = [2,3,8];
    pats_sg3 = [4,9,10];

    %type = {'double', 'fft'}; % mean or fft can be used
    fout_sg1 = 'surgical_subgroup1';
    fout_sg2 = 'surgical_subgroup2';
    fout_sg3 = 'surgical_subgroup3';
    
    % Individual
    fout_ind_s = 'surgical_individual';
    fout_ind_c = 'control_individual';
    

    %% No fixed parameters (get best parameters)

    % dists50 and dists650 tried (dists50 terrible so not continued)
    % mean and fft attempted

    din = fullfile(['control', num2str(run_id)], ['dists', num2str(dists)]);

    % This grabs (and saves) all the top parameters sets to csv files
    [pc_c, ~] = grab_parameters(pats_c, threshold, type, din, fout_c);
    grab_parameters(pats_s, threshold, type, din, fout_s);

    % Fourth parameter m (4th parameter, an integer must be fixed), Choose the 
    % one with the max number of top parameter sets
    [~, idx] = max(sum(pc_c(:,4) == 1:4));

    % Find the ones with that value of parameter m (4th parameter)
    fout_cm = 'control_group_m';
    fout_sm = 'surgical_group_m';

    [pc_cm, ~] = grab_parameters(pats_c, threshold, type, din, fout_cm, idx);
    [pc_sm, ~] = grab_parameters(pats_s, threshold, type, din, fout_sm, idx);


    % The baseline for controls
    % We use these when fixing a parameter (see runs_sh, run_double_mean{}.sh
    baseline_controls = median(pc_cm)

    % Save the trajectories to a csv file
    % control trajectories/control parameters
    grab_trajectories(pc_cm, times, pre, post, pats_c, type, din, fout_cm, visual, [3,1]);

    % surgical trajectories/surgical parameters
    grab_trajectories(pc_sm, times, pre, post, pats_s, type, din, fout_sm, visual, [5,2]);

    % the control baseline and best control parameter used, trajectories for
    % surgical and control saved
    fout_c_medbest = 'control_group_medbest';
    fout_s_medbest = 'surgical_group_medbest';

    medbest = [baseline_controls; pc_cm(1,:)];
    grab_trajectories(medbest, times, pre, post, pats_c, type, din, fout_c_medbest, visual, [3,1]);
    grab_trajectories(medbest, times, pre, post, pats_s, type, din, fout_s_medbest, visual, [5,2]);

    %% Group level analysis (surgical and controls)
    % m_runs = m fixed, all else variable
    % p_runs = KA, m fixed, all else variable
    % KA_runs = p_f,p_s fixed, all else variable
    for names = {'m_runs', 'p_runs', 'KA_runs'}
        din = fullfile([names{1}, num2str(run_id)], ['dists', num2str(dists)]);

        [pc_c, ~] = grab_parameters(pats_c, threshold, type, din, fout_c);
        [pc_s, ~] = grab_parameters(pats_s, threshold, type, din, fout_s);

        % Save the trajectories to a csv file
        % control trajectories/control parameters
        grab_trajectories(pc_c, times, pre, post, pats_c, type, din, fout_c, visual, [3,1]);

        % surgical trajectories/surgical parameters
        grab_trajectories(pc_s, times, pre, post, pats_s, type, din, fout_s, visual, [5,2]);
    end
    
    %% Subgroups iterate over 
    % m_runs = m fixed, all else variable
    % p_runs = KA, m fixed, all else variable
    % KA_runs = p_f,p_s fixed, all else variable

    for names = {'m_runs', 'p_runs', 'KA_runs'}
        din = fullfile([names{1}, num2str(run_id)], ['dists', num2str(dists)]);

        [pc_sg1, ~] = grab_parameters(pats_sg1, threshold, type, din, fout_sg1);
        [pc_sg2, ~] = grab_parameters(pats_sg2, threshold, type, din, fout_sg2);
        [pc_sg3, ~] = grab_parameters(pats_sg3, threshold, type, din, fout_sg3);    

        % Save the trajectories to a csv file
        % 3 surgical subgroups
        grab_trajectories(pc_sg1, times, pre, post, pats_sg1, type, din, fout_sg1, visual, [2,2]);
        grab_trajectories(pc_sg2, times, pre, post, pats_sg2, type, din, fout_sg2, visual, [3,1]);
        grab_trajectories(pc_sg3, times, pre, post, pats_sg3, type, din, fout_sg3, visual, [3,1]);    
    end  
    
    %% Individuals iterate over 
    % m_runs = m fixed, all else variable
    % p_runs = KA, m fixed, all else variable
    % KA_runs = p_f,p_s fixed, all else variable
    for names = {'m_runs', 'p_runs', 'KA_runs'}
        % Surgicals
        ct = 1;
        for i = pats_s
            fout_ind = [fout_ind_s, num2str(ct)];
            din = fullfile([names{1}, num2str(run_id)], ['dists', num2str(dists)]);

            [pc_s_ind, ~] = grab_parameters(i, threshold, type, din, fout_ind);
            grab_trajectories(pc_s_ind, times, pre, post, i, type, din, fout_ind, visual, [1,1]);
            ct = ct + 1;
        end
        
        % Controls
        ct = 1;
        for i = pats_c
            fout_ind = [fout_ind_c, num2str(ct)];
            din = fullfile([names{1}, num2str(run_id)], ['dists', num2str(dists)]);

            [pc_c_ind, ~] = grab_parameters(i, threshold, type, din, fout_ind);
            grab_trajectories(pc_c_ind, times, pre, post, i, type, din, fout_ind, visual, [1,1]);
            ct = ct + 1;
        end   

    end 
    
end
