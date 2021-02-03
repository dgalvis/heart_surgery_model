%=========================================================================%
% Function: hypercube_ode.m
% Author: Daniel Galvis
%
% Description: Run the optimisation across all parameters in par_choices
%
% Paramaters
% ----------
% times: array of times
% times : time points
% pre   : all pre data times x patients
% post  : all post data times x patients
% pats  : indices of the patients to use for optimisation
% dists : 1x2 array of floats
%     [length, slide] in data time units
%     This optimiser takes a average of sliding time windows to test
%     the optimisation and uses the average of those errors
% type : 2-cell array of strings
%     type{1} : 'single' or 'double' (one or two compartments for post
%                                    decay)
%     type{2} : 'mean' or 'fft' (optimise in time or frequency space)
% par_choices: N x 4 (single) or N x6 (double) parameter sets
% pts: N
%
% Returns
% -------
% error: N x length(pats) of optimisation errors
%=========================================================================%
function error = hypercube_ode(times, pre, post, pats, dists, type, par_choices, pts)

    error = zeros(pts, max(pats));
    tic;
    
    % Error for all the points, across the given patients
    parfor i = 1:pts
        for j = pats
            error(i,j) = opt_cort(par_choices(i,:), times, pre, post, j, dists, type);
        end
    end
    toc;
    
end
