%=========================================================================%
% Function: run_hypercube_bear.m (bear is the hpc)
% Author: Daniel Galvis
%
% Description: Identifies a hypercube for the given parameters of the
% model. This gets fed into the ode to evaluate the cost function
%
%
% Parameters
% ----------
% lb: a 1D array of lower bounds
% ub; a 1D array of upper bounds
% idxa: The indices of all parameters that vary
% vals: An array of values for fixed parameters
% idxb: The indices of all fixed paramters
% pts : Number of samples to identify
% type: {'double', 'fft'}
%   - 'single' or 'double' (one or two compartment model)
%   - 'fft' or 'mean' (cost function evaluated on data in time or frequency
%   space (doesn't appear to play much difference)
% dout: output directory (for example 'control') result is saved to
%  ./results/dout
% seed : seed for the hypercube generation. If not given, one is chosen
%
%
% Returns 
% -------
% saves a file to ./results/dout
% filename: ./results/dout/par_choices_acth_cort_{type}.mat
% inputs are saved (same names)
% par_choices: pts x num parameters array
%
%
% Example:
% lb = [0,0,0,0];
% ub = [1,1,1,1];
% idxa = [1,2,5,6]
% vals = [50, 2]
% idxb = 3:4
% pts = 16*1024^2
% type = 'double' (must be double if 6 parameters)
% dout = 'control'
% seed = [];
% 
% par_choices(1,:) = [0.42, 0.01, 50, 2, 0.93, 0.43]; etc...
%=========================================================================%
function par_choices = run_hypercube_bear(lb, ub, idxa, vals, idxb, pts, type, dout, seed)

    addpath('functions');

    % Seed random number generator
    try
        rng(seed);
    catch
        rng('shuffle');
        seed = rng;
        disp('Using new random seed');
    end
    mkdir(['./results/', dout]);
    
    % Pick the points
    par_choices = zeros(pts, max([idxa, idxb]));
    % variable parameters
    par_choices(:, idxa) = pick_points(pts, lb, ub);
    % fixed parameters
    par_choices(:, idxb) = repmat(vals, pts, 1);
 
    % save
    fout = fullfile('results', dout, ['par_choices_acth_cort_', type{1}, '_', type{2}, '.mat']);
    save(fout, 'par_choices', 'lb','ub', 'idxa', 'vals', 'idxb', 'seed', 'pts', '-v7.3'); 
end
 
 
