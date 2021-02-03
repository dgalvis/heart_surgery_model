%%
restoredefaultpath;clear;close all;clc;

addpath('../../data');
addpath('../../functions');

addpath('../../violin');

addpath('../../results/p_runs1/dists650');

load('data_all.mat');

type = {'double', 'mean'};
load(['results_',type{1},'_',type{2},'.mat']); 

%%
pat_s = 1:10;
pc = {};
er = {};
for p = pat_s
    [par_choices_s, error_s] = sort_me(par_choices, error, p);
    err_aux_p = error_s(:,p);
    tot_num_p = sum(err_aux_p < (1.1*err_aux_p(1)));

    pc_p = par_choices_s(1:tot_num_p,:);
    er_p = error_s(1:tot_num_p,p);
    csvwrite(['surgical_pars', num2str(p), '.csv'], [pc_p, er_p]);
    pc{p} = pc_p;
    er{p} = er_p;
end


figure();
g = [];
pc2 = [];
er2 = [];
for p = pat_s
    g1 = repmat({['Surgical', num2str(p)]}, size(pc{p}, 1), 1);
    g = [g;g1];
    pc2 = [pc2; pc{p}];
    er2 = [er2; er{p}];
end
  
ct = 1;
for i = [1,2,5,6]
    subplot(2,3,ct);hold all;
    violinplot(pc2(:, i), g);
    ct = ct + 1;
end
subplot(2,3,5);hold all;
violinplot(er2, g);  

%%
ct = 1;
figure();
for p = pat_s
    
    pc_s = pc{p};
    tot_num_p = size(pc_s, 1);
    
    y_keep = zeros(size(post,1), size(1:10:tot_num_p ,2));
    
    
    subplot(5,2, ct);hold all; 
    for i = 1:10:tot_num_p 
        [t,y] = single_ode(times, pre(:,p), post(:,p), type{1}, pc_s(i,:));
        y = sum(y,2);
        y_keep(:,i) = y;
        plot(t,y / max(post(:,p)),'color', (0.75 - (i/tot_num_p)*[0.50,0.50,0.50]), 'linewidth', 1.5);
    end
    csvwrite(['surgical_traj_', num2str(ct), '.csv'], y_keep);
    plot(times, post(:,p) / max(post(:,p)) ,'k', 'linewidth', 3);  
    plot(times, pre(:,p) / max(pre(:,p)) + 1.5, 'r', 'linewidth', 3);
    plot([times(1), times(end)], [1, 1],'k--','linewidth', 3);
    ylim([0,2.5]);
    xlim([0,710]);
    yticks([0,1,1.5,2.5]);
    yticklabels({'0', num2str(round(max(post(:,p)))), '0', num2str(round(max(pre(:,p))))});
    title(['surgical: ', num2str(ct)]);
    xlabel('time minutes');
    ylabel('CORT and ACTH');    
    ct = ct + 1;
end