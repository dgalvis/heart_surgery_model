%=========================================================================%
% Function grab_trajectories(pc, times, pre, post, pats, type, din, fout, visual, shape)
% Author: Daniel Galvis
%
% Description: Save the trajectories and plot them. Given a set of parameters pc, this plots all
% The pats in pats using those parameters
%
%
% Parameters
% ----------
% pc: pts x num parameters (just the hypercube)
% times : time points
% pre   : all pre data times x patients
% post  : all post data times x patients
% (1:10 patients / 11:13 controls)
% pats : The subset of patients to use (1:10 patients, 11:13 controls)
% type: {'double', 'fft'}
%   - 'single' or 'double' (one or two compartment model)
%   - 'fft' or 'mean' (cost function evaluated on data in time or frequency
%   space (doesn't appear to play much difference)
% din: Subdirectory of ./results where the errors are saved
%   - see run_ode_bear.m
%   - see run_analysis_group.m for examples
%   - fout : output filename (csv) - type is added on in code
% visual : true show plots
% shape : shape for subplot [5,2] for 10 patients, [3,1] for controls
%
% Returns
% -------
% Plots and csv files of trajectories for the given pats using pc parameter sets
%
%=========================================================================%
function grab_trajectories(pc, times, pre, post, pats, type, din, fout, visual, shape)

    if visual
        figure();
    end
    din = fullfile('results', din);
    ct = 1;
    tot_num = size(pc, 1);
    
    % Iterate patients
    for p = pats
        disp(['Calculating ode pat ', num2str(ct), ' of ', num2str(length(pats))]);
        if visual
            subplot(shape(1),shape(2), ct);hold all; 
        end

        y_keep = zeros(length(times), tot_num);
        
        if visual
            % Plot each trajectory
            for i = 1:1:tot_num 

                % Calculate the ode
                [t, y] = single_ode(times, pre(:,p), post(:,p), type{1}, pc(i,:));
                y = sum(y,2);
                y_keep(:,i) = y;

                % Plot the trajectory
                plot(t,y / max(post(:,p)),'color', 'b', 'linewidth', 1.5);
            end
        else
            % Plot each trajectory
            parfor i = 1:1:tot_num 

                % Calculate the ode
                [t, y] = single_ode(times, pre(:,p), post(:,p), type{1}, pc(i,:));
                y = sum(y,2);
                y_keep(:,i) = y;
            end            
        end
        % Maybe save the results
        fout_pat = [fout, '_traj', num2str(ct), '_',type{1}, '_', type{2}, '.csv'];
        csvwrite(fullfile(din, fout_pat), y_keep);
        
        
        % Plot experimental data
        if visual
            plot(times, post(:,p) / max(post(:,p)) ,'k', 'linewidth', 3);  
            plot(times, pre(:,p) / max(pre(:,p)) + 1.5, 'r', 'linewidth', 3);
            plot([times(1), times(end)], [1, 1],'k--','linewidth', 3);
            ylim([0,2.5]);
            xlim([0,710]);
            yticks([0,1,1.5,2.5]);
            yticklabels({'0', num2str(round(max(post(:,p)))), '0', num2str(round(max(pre(:,p))))});
            title(['pat ', num2str(ct)]);
            xlabel('time minutes');
            ylabel('CORT and ACTH');    
        end
        

        ct = ct + 1;
    end
end
