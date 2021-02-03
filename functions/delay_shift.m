%=========================================================================%
% function [new_t, new_pre, new_post] = delay_shift(times, pre, post, shift)
%
% Shift the data so that we can assume pre takes shift time to affect post
%
% Parameters
% ----------
% times : data time points
% pre   : times x patients pre data points
% post  : times x patients post data point
% shift : impost a time shift of this much for de facto delay equations
%     if shift > 0, pre takes a while to affect post
%     if shift < 0, pre future affects post (not useful)
% 
% Returns
% -------
% new_t : new time points
% new_pre : new_t x patients pre data points
% new_post : new_t x patients pro data points
%=========================================================================%
function [new_t, new_pre, new_post] = delay_shift(times, pre, post, shift)
    if shift == 0
        new_pre = pre;
        new_post = post;
        new_t = times;  
        return
    end
              

    % Find the time point index for the shift
    [~, t_idx] = min(abs(times - abs(shift)));

    if shift > 0 
        % Pre is not shifted. The last points are removed to match sizes
        new_pre = pre(1:end - t_idx + 1, :);
        % Post is shifted
        new_post = post(t_idx:end, :);
    else
        % Pre is shifted
        new_pre = pre(t_idx:end, :);
        % Post is not shifted. The last points are removed to match sizes
        new_post = post(1:end - t_idx + 1, :);
    end
    % Time starts at 0 and ends at t(end)-shift
    new_t = times(1:end - t_idx + 1);
end
