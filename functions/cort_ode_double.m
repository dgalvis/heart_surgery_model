%=========================================================================%
% function dy = cort_ode_double(t, y, par, times, pre)
%
% An ode for post with two decay compartments. Use with ode23 or ode45 etc
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
% dy - 2x1, derivative for both compartments
%=========================================================================%
function dy = cort_ode_double(t, y, par, times, pre)
    y1 = y(1);
    y2 = y(2);

    
    % Find the closest t (from ODE) to times (from data)
    [~, t_idx] = min(abs(times-t));

    
    % Rate values
    dy1 = - y1 / par(1) + par(2) * hill_fun(pre(t_idx), par(4), par(3));
    dy2 = - y2 / par(5) + par(6) * hill_fun(pre(t_idx), par(4), par(3));    
    dy = [dy1;dy2]; 
end
