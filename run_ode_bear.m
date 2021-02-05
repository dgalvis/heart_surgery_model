%=========================================================================%
% Function: run_ode_bear.m (bear is the hpc)
% Author: Daniel Galvis
% 
% Description: Run the ODE modelling for each parameter set in a hypercube 
% and calculate the cost function. Repeat for every patient.
%
%
% Parameters
% ----------
% dists : 1x2 array of floats
%     [length, slide] in data time units
%     This optimiser takes a average of sliding time windows to test
%     the optimisation and uses the average of those errors
% type: {'double', 'fft'}
%   - 'single' or 'double' (one or two compartment model)
%   - 'fft' or 'mean' (cost function evaluated on data in time or frequency
%   space (doesn't appear to play much difference)
% din: Subdirectory of ./results where the latin hypercube is saved
%   - see run_hypercube_bear.m
% dout: Subdirectory of ./results where to save the output
%
%
% Returns
% -------
% par_choices: pts x num parameters (just the hypercube)
% error      : pts x num patients (individual cost function evals)
%=========================================================================%
function [par_choices, error] = run_ode_bear(dists, type, din, dout)

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

    addpath('functions');

    disp(['dists: ', num2str(dists)]);
    disp(['type: ', type]);
    disp(['din: ', din]);
    disp(['dout: ', dout]);
    
    
    % Load in data
    data_in = fullfile('data', 'data_all.mat');
    hyp_in = fullfile('results', din, ['par_choices_acth_cort_', type{1}, '_', type{2}, '.mat']);
    
    load(data_in, 'times', 'pre', 'post', 'pats');
    load(hyp_in, 'par_choices', 'pts');

    % make the output folder
    
    dout = fullfile('results', dout);
    mkdir(dout);
    
    % Run the ODE across the hypercube
    error = hypercube_ode(times, pre, post, pats, dists, type, par_choices, pts);
    % Sort by mean error across all patients and controls (not super
    % important since we do this in analysis, but it's nice to have the good
    % solutions on top)
    [par_choices, error] = sort_me(par_choices, error, pats);

    % Save!
    data_out = fullfile(dout, ['results_',type{1},'_',type{2},'.mat']);
    save(data_out, 'par_choices', 'error', ...
         'pts', 'pats','type','dists', '-v7.3');
end
