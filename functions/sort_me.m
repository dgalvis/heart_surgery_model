%=========================================================================%
% Function: sort_me.m
% Author: Daniel Galvis
%
% Description: Sort the latin hypercube and error array by a given patient
% set. Mean squared error across the given patients
%
% Paramaters
% ----------
% par_choices : pts x N array of parameters
% error : pts x num pats array of errors
% pats : array of patients (any subset works!)
% 
%
% Returns
% -------
% par_choices : sorted
% error: sorted
%
% Example: pats = 1 -> sort error by patient 1
%          pats = 1:5 -> sort by mean squared error of pats 1-5
%=========================================================================%


function [par_choices, error] = sort_me(par_choices, error, pats)

    % Sort idx
    [~,idx] = sort(mean(error(:,pats).^2,2));
    
    % Sort
    error = error(idx,:);
    par_choices = par_choices(idx,:);
end