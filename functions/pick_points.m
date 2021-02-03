%=========================================================================%
% Function: pick_points.m
% Author: Daniel Galvis
%
% Description: Latin Hypercube of size pts for a number of parameters
%
% Paramaters
% ----------
% pts: number of points in the hypercube
% lb : N x 1 array, lower bound for points 
% ub : N x 1 array, upper bound for points
% (N the number of variable parameters)
%
% Returns
% -------
% par_choices : array pts x N (hypercube)
%=========================================================================%
function par_choices = pick_points(pts, lb, ub)


    par_choices = lhsdesign(pts, length(lb));
    for i = 1:length(lb)
        par_choices(:,i) = (ub(i) - lb(i))*par_choices(:,i) + lb(i);
    end
    
    
end