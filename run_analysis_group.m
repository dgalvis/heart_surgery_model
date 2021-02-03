%=========================================================================%
% Function: run_analysis_group.m (bear is the hpc)
% Author: Daniel Galvis
%
% Description: This code does the group level analysis of the optimisations.
% That is, it uses the mean squared error over all controls or all surgicals.
%
% We are only looking at the two-compartment model ('double')
% We look at the mean method with dists = 650
% This just means that the optimiser looks for the smallest difference 
% between model output and cortisol trajectory (no sliding windows)
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
%
% This code has multiple sections:
%     No Fixed Parameters: create csv files for best group optimisations
%     of controls and surgicals (all 6 parameters are variable)
%
%     Parameter 4, the integer parameter m, is chosen based on which value
%     in m = 1,2,3,4 has the max number of top solutions (m = 2) in the control
%     data
%   
%     csv files are saved of top solutions with m = 2 as well "m2 csv" files
%
%     The top trajectories for both controls and surgicals are put in csv files
%
%     Trajectories are plotted
%     
%     Other sections: m2_runs - m = 2 other 5 parameters are variable
%                     KA_runs - m = 2, KA variable, p_f, p_s fixed
%                     p_runs  - m = 2, KA fixed, p_f, p_s vaariable
%
%     For these cases, the top surgical and control parameters and trajectories
%     are saved as csv files (and plotted)
%
%     All csv files are place in the same places as the .mat files with the
%     latin hypercube optimisations.
%=========================================================================%
%% Setup 
    %restoredefaultpath;clear;close all;clc;

function run_analysis_group(type, dists, run_id, visual)

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
    load('data_all.mat');

    pats_s = 1:10;
    pats_c = 11:13;

    %type = {'double', 'fft'}; % mean or fft can be used
    fout_s = 'surgical_group';
    fout_c = 'control_group';
    %dists = 50; % 650 or 50 available (sliding window type)

    %% No fixed parameters (get best parameters)

    % dists50 and dists650 tried (dists50 terrible so not continued)
    % mean and fft attempted

    din = fullfile(['control', num2str(run_id)], ['dists', num2str(dists)]);

    % This grabs (and saves) all the top parameters sets to csv files
    [pc_c, ~] = grab_parameters(pats_c, 1.1, type, din, fout_c);
    grab_parameters(pats_s, 1.1, type, din, fout_s);

    % Fourth parameter m (4th parameter, an integer must be fixed), Choose the 
    % one with the max number of top parameter sets
    [~, idx] = max(sum(pc_c(:,4) == 1:4));

    % Find the ones with that value of parameter m (4th parameter)
    fout_c = 'control_group_m2';
    fout_s = 'surgical_group_m2';

    [pc_c, ~] = grab_parameters(pats_c, 1.1, type, din, fout_c, idx);
    [pc_s, ~] = grab_parameters(pats_s, 1.1, type, din, fout_s, idx);


    % The baseline for controls
    % We use these when fixing a parameter (see runs_sh, run_double_mean{}.sh
    baseline_controls = median(pc_c)

    % Save the trajectories to a csv file
    % control trajectories/control parameters
    grab_trajectories(pc_c, times, pre, post, pats_c, type, din, fout_c, visual, [3,1]);

    % surgical trajectories/surgical parameters
    grab_trajectories(pc_s, times, pre, post, pats_s, type, din, fout_s, visual, [5,2]);

    % the control baseline and best control parameter used, trajectories for
    % surgical and control saved
    fout_c_medbest = 'control_group_medbest';
    fout_s_medbest = 'surgical_group_medbest';

    medbest = [baseline_controls; pc_c(1,:)];
    grab_trajectories(medbest, times, pre, post, pats_c, type, din, fout_c_medbest, visual, [3,1]);
    grab_trajectories(medbest, times, pre, post, pats_s, type, din, fout_s_medbest, visual, [5,2]);

    clear din  pc_c pc_s;
    %% Fixed only m at 2 (this is the same as above but with only m = 2 (and 4x the points)

    din = fullfile(['m2_runs', num2str(run_id)], ['dists', num2str(dists)]);

    [pc_c, ~] = grab_parameters(pats_c, 1.1, type, din, fout_c);
    [pc_s, ~] = grab_parameters(pats_s, 1.1, type, din, fout_s);

    % Save the trajectories to a csv file
    % control trajectories/control parameters
    grab_trajectories(pc_c, times, pre, post, pats_c, type, din, fout_c, visual, [3,1]);

    % surgical trajectories/surgical parameters
    grab_trajectories(pc_s, times, pre, post, pats_s, type, din, fout_s, visual, [5,2]);
    clear din  pc_c pc_s;
    %% Fixed m at 2, fixed KA (this is the same as above but with only m = 2 (and 4x the points)

    din = fullfile(['p_runs', num2str(run_id)], ['dists', num2str(dists)]);

    [pc_c, ~] = grab_parameters(pats_c, 1.1, type, din, fout_c);
    [pc_s, ~] = grab_parameters(pats_s, 1.1, type, din, fout_s);

    % Save the trajectories to a csv file
    % control trajectories/control parameters
    grab_trajectories(pc_c, times, pre, post, pats_c, type, din, fout_c, visual, [3,1]);

    % surgical trajectories/surgical parameters
    grab_trajectories(pc_s, times, pre, post, pats_s, type, din, fout_s, visual, [5,2]);
    clear din pc_c pc_s;

    %% Fixed m at 2, fixed p (this is the same as above but with only m = 2 (and 4x the points)

    din = fullfile(['KA_runs', num2str(run_id)], ['dists', num2str(dists)]);

    [pc_c, ~] = grab_parameters(pats_c, 1.1, type, din, fout_c);
    [pc_s, ~] = grab_parameters(pats_s, 1.1, type, din, fout_s);

    % Save the trajectories to a csv file
    % control trajectories/control parameters
    grab_trajectories(pc_c, times, pre, post, pats_c, type, din, fout_c, visual, [3,1]);

    % surgical trajectories/surgical parameters
    grab_trajectories(pc_s, times, pre, post, pats_s, type, din, fout_s, visual, [5,2]);
    clear din pc_c pc_s;
end
