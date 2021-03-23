%=========================================================================%
% function [new_t, new_pre, new_post, new_cyt1, new_cyt2] = ...
%           delay_shift_cyts(times, pre, post, cyt1, cyt2, shift)
%
% Shift the data so that we can assume pre takes shift time to affect post
%
% Parameters
% ----------
% times : data time points
% pre   : times x patients pre data points
% post  : times x patients post data point
% cyt1  : times x patients pre data points
% cyt2  : times x patients post data point
% shift : impost a time shift of this much for de facto delay equations
%     if shift > 0, pre takes a while to affect post
%     if shift < 0, pre future affects post (not useful)
% 
% Returns
% -------
% new_t    : new time points
% new_pre  : new_t x patients pre data points
% new_post : new_t x patients pro data points
% new_cyt1 : new_t x patients pre data points
% new_cyt2 : new_t x patients pro data points
%=========================================================================%
function [new_t, new_pre, new_post, new_cyt1, new_cyt2, new_cyt3, new_cyt4] = ...
          delay_shift_cyts(times, pre, post, cyt1, cyt2, cyt3, cyt4, shift)
    if shift == 0
        new_pre = pre;
        new_post = post;
        new_t = times;  
        
        new_cyt1 = cyt1;
        new_cyt2 = cyt2;
        new_cyt3 = cyt3;
        new_cyt4 = cyt4;
        return
    end
              

    % Find the time point index for the shift
    [~, t_idx] = min(abs(times - abs(shift)));

    if shift > 0 
        % Pre is not shifted. The last points are removed to match sizes
        new_pre = pre(1:end - t_idx + 1, :);
   
        % Post is shifted
        new_post = post(t_idx:end, :);
         % Cytokines match the post data
        new_cyt1 = cyt1(t_idx:end, :);
        new_cyt2 = cyt2(t_idx:end, :);     
        new_cyt3 = cyt3(t_idx:end, :);
        new_cyt4 = cyt4(t_idx:end, :); 
    else
        % Pre is shifted
        new_pre = pre(t_idx:end, :);
        
        % Post is not shifted. The last points are removed to match sizes
        new_post = post(1:end - t_idx + 1, :);
        % Cytokines match the post data
        new_cyt1 = cyt1(1:end - t_idx + 1, :);
        new_cyt2 = cyt2(1:end - t_idx + 1, :);    
        new_cyt3 = cyt3(1:end - t_idx + 1, :);
        new_cyt4 = cyt4(1:end - t_idx + 1, :); 

    end
   
    
    % Time starts at 0 and ends at t(end)-shift
    new_t = times(1:end - t_idx + 1);
end
