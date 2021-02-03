%=========================================================================%
% Function: run_copy_hypercube_bear.m (bear is the hpc)
% Author: Daniel Galvis
%
% Description: This code will copy the hypercube for a list of values of
% one parameter. This is done for the integer parameter (m) so I can look
% at the same hypercube but with m = 1,2,3,4
%
% Parameters
% ----------
%
% copy_vals : array of values (example 1:4)
% idx  : index of the parameter to copy over (usually 4)
% type: {'double', 'fft'}
%   - 'single' or 'double' (one or two compartment model)
%   - 'fft' or 'mean' (cost function evaluated on data in time or frequency
% din : subdirectory of 'results' (dout from run_hypercube_bear.m)
%
% From the data load (run_hypercube_bear)
% lb: a 1D array of lower bounds
% ub; a 1D array of upper bounds
% idxa: The indices of all parameters that vary
% vals: An array of values for fixed parameters
% idxb: The indices of all fixed paramters
% pts : Number of samples to identify
% seed : seed for the hypercube generation. If not given, one is chosen
%
%
% Return
% ------
% New hypercube file (replaces the old one, but does not delete it)
% Sets the old file to _original.mat
%
% Example copy_vals = 1:2, idx = 4
% par_choices(:,idx) = 1;, par_choices(:,idx) = 2; concatenate


function par_choices = run_copy_hypercube_bear(copy_vals, idx, type, din)

    fin = fullfile('results', din, ['par_choices_acth_cort_', type{1}, '_', type{2}, '.mat']);
    forig = fullfile('results', din, ['par_choices_acth_cort_', type{1}, '_', type{2}, '_original.mat']);

    load(fin, 'idxa', 'idxb', 'lb', 'ub', 'vals', 'par_choices', 'pts', 'seed');
    save(forig, 'idxa', 'idxb', 'lb', 'ub', 'vals', 'par_choices', 'pts', 'seed', '-v7.3');

    % Reset these variables to incorporate the copied values in the hypercube
    lb_aux = [lb(1:(idx-1)), min(copy_vals)];
    ub_aux = [ub(1:(idx-1)), max(copy_vals)];
    try
        lb_aux = [lb_aux, lb(idx:end)];
        ub_aux = [ub_aux, ub(idx:end)];
    catch
    end
    lb = lb_aux;
    ub = ub_aux;


    idxa = unique([idxa, idx]);

    idxb_keeps = find(idxb ~= idx);
    idxb = idxb(idxb_keeps);
    vals = vals(idxb_keeps);

    % Copy the latin hypercube for each value of the given parameter
    % This is done for integer parameters!
    pc = [];
    for i = copy_vals
        par_choices(:, idx) = i;
        pc = [pc; par_choices];

    end
    par_choices = pc;
    % pts increases
    pts = length(copy_vals)*pts;

     % save
    save(fin, 'idxa', 'idxb', 'lb', 'ub', 'vals', 'par_choices', 'pts', 'seed', '-v7.3');
end