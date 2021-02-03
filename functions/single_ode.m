%=========================================================================%
% Function: single_ode.m
% Author: Daniel Galvis
%
% Description: Run the ode for a single parameter set
%
% Paramaters
% ----------
% times: array of times
% pre : array of acth (single patient!)
% post: array of cortisol (single patient!)
% type: 'single' or 'double'
% pars: array 1x4 for single, 1x6 for double
%
% Returns
% -------
% [t, y] the model output approximation of post
%=========================================================================%


function [t,y] = single_ode(times, pre, post, type, pars)


    [cort_ode, inits] = decay_type(pre(1), post(1), pars, type);


    % Initial condition is data initial condition
    [t,y] = ...
        ode23(@(t,y)cort_ode(t, y, pars, times, pre), times, inits);
    %y = sum(y, 2); 
end