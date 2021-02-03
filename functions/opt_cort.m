%=========================================================================%
% function error = opt_cort(guess, times, pre, post, pats, dists, type)
%
% Run the optimisation of the one-compartment or two-compartment post ODE
%
% Parameters
% ----------
% guess : 1x4 list of parameters (if type{1} is 'single')
% guess : 1x6 list of parameters (if type{1} is 'double')
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
%
%
% Returns
% -------
% error : float
%     Error of cost function
%=========================================================================%
function error = opt_cort(guess, times, pre, post, pats, dists, type)
    % Initialize values
    error = 0;
    count = 0;

    
    % Iterate over choice of patients
    for pat_num = pats
        % Left time point
        left_pt = 1;
   
        
        while 1            
            if (times(left_pt)+dists(1)) > times(end)
                break
            end
        
            
            % Find the right time point
            [~, right_pt] = min(abs(times(left_pt) + dists(1) - times));

            
            % Time points to integrate over
            t_aux = times(left_pt:right_pt);
            pre_aux = pre(left_pt:right_pt, pat_num);
            post_aux = post(left_pt:right_pt, pat_num);

            % Get initial conditions and ODE function depending on type{1}
            [cort_ode, inits] = decay_type(pre_aux(1), post_aux(1), guess, type{1});
            
            
            % Initial condition is data initial condition
            [t,y] = ...
                ode23(@(t,y)cort_ode(t, y, guess, t_aux, pre_aux), ...
                    [t_aux(1), t_aux(end)], inits);
            y = sum(y, 2);    


            % Interpolate the ODE values to the data values
            y_interp = interp1(t, y, t_aux);
            
            % Error is the sum(abs(diff(ODE - data)))
            if strcmp(type{2}, 'mean')
                error = error + sum(abs(y_interp' - post_aux)) / max(post_aux);
            elseif strcmp(type{2}, 'fft')
                error = error + sum(abs(fft(y_interp' - post_aux))) / max(abs(fft(post_aux)));
            end
            
            
            count = count + max(size(y_interp));
            [~, left_pt] = min(abs(times(left_pt) + dists(2) - times));
        end       
    end

    
    % Rivide by total time points over all the iterated patients
    error = error /  count;
end
