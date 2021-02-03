%=========================================================================%
% function [cort_ode, inits] = decay_type(pre, post, pars, type)
%
% This function chooses the ode (one or two post decay compartments) based
% on the string in variable type. It also chooses the initial condition for
% the ode based on the input data and in the case of two compartments,
% based on the parameters.
%
% Parameters
% ----------
% pre : float
%     The first pre data point for a specific patient
% post : float
%     The first post data point for that same patient
%
% pars : array of floats
%     The parameters in an array
%
% type : string
%     'single' or 'double' depending on the decay type
%
% Returns
% -------
% cort_ode : ode function for solver (single or double decay)
%
% inits : initial condition for ode
%     'single' : float with first data point for post
%     'double' : 1x2 array with values for both decay variables
%=========================================================================%
function [cort_ode, inits] = decay_type(pre, post, pars, type)

        if strcmp(type, 'single')
            cort_ode = @cort_ode_single;
            inits = post;
        elseif strcmp(type, 'double')
            cort_ode = @cort_ode_double;

            % For the fast variable, choose the equilibrium values as
            % initial value
            inits(1) = pars(1) * pars(2) * hill_fun(pre, pars(4), pars(3));
            % Slow variable adds up to the initial value of the post data
            inits(2) = max(post - inits(1), 0);
        end