%=========================================================================%
% Function [pc, er] = grab_parameters(pats, threshold, type, din, fout, choose_m)
% Author: Daniel Galvis
%
% Description: This code sorts the parameter sets by mean squared error of a 
% subset of the controls and patients (pats). And gives the top parameter sets
% based on a threshold (for example 10% greater than the smallest error)
%
%
% Parameters
% ----------
% pats : The subset of patients to use (1:10 patients, 11:13 controls)
% threshold : what to keep (1.1 means keep all parameter sets whose error
%             is within 10% of the smallest error)
% type: {'double', 'fft'}
%   - 'single' or 'double' (one or two compartment model)
%   - 'fft' or 'mean' (cost function evaluated on data in time or frequency
%   space (doesn't appear to play much difference)
% din: Subdirectory of ./results where the errors are saved
%   - see run_ode_bear.m
%   - see run_analysis_group.m for examples
%   - fout : output filename (csv) - type is added on in code
%
% choose_m : A value for parameter 4 (m). This will only keep the solutions where
%  m = choose_m
%
% Returns
% -------
% pc: pts x num parameters (just the hypercube)
% er      : pts x num patients (individual cost function evals)
% (pts here is defined as the number of points that are kept, depends on threshold)
%
%=========================================================================%
function [pc, er] = grab_parameters(pats, threshold, type, din, fout, choose_m)


    % Load in results
    fin = fullfile('results', din, ['results_',type{1},'_',type{2},'.mat']);
    load(fin, 'par_choices', 'error');
    
    % Sort the parameters and error by mean squared error of pats list
    [par_choices, error] = sort_me(par_choices, error, pats);
    
    % Calculate the mean squared error 
    err_aux = sqrt(mean(error(:, pats).^2, 2));
    
    % Find the total number of parameter sets that are within a tolerance
    tot_num = sum(err_aux < (threshold * err_aux(1)));
    pc = par_choices(1:tot_num, :);
    er = err_aux(1:tot_num);

    % For parameter 4 (m the integer) sometimes we want to kick out all but
    % one of the integer values. This does that
    try
        idx = (pc(:,4) == choose_m);
        pc = pc(idx, :);
        er = er(idx, :);
    end
        
    
    % Maybe save the results
    fout = fullfile('results', din, [fout, '_',type{1}, '_', type{2}, '.csv']);
    csvwrite(fout, [pc, er]);
end
