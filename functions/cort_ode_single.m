%=========================================================================%
% function dy = cort_ode_single(t, y, par, times, pre)
%
% An ode for post with one decay compartments. Use with ode23 or ode45 etc
%
% Parameters
% ----------
% t, y - bog standard
% par  - needs 6 parameters
% times - time points interpolated
% pre   - pre data points for some patients. Pre affects post with a hill
%      function
%
% Returns
% -------
% dy -  derivative of the compartment for post
%=========================================================================%
function dy = cort_ode_single(t, y, par, times, pre)


    % Find the closest t (from ODE) to times (from data)
    [~, t_idx] = min(abs(times-t));

    % Rate values
    dy = - y / par(1) + par(2) * hill_fun(pre(t_idx), par(4), par(3));
end
