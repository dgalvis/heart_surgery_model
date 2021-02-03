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

pat_g1 = [1,5,6,7];
[par_choices_g1, error_g1] = sort_me(par_choices, error, pat_g1);
err_aux_g1 = sqrt(mean(error_g1(:,pat_g1).^2, 2));
tot_num_g1 = sum(err_aux_g1 < (1.1*err_aux_g1(1)));

pc_g1 = par_choices_g1(1:tot_num_g1,:);
er_g1 = sqrt(mean(error_g1(1:tot_num_g1,pat_g1).^2, 2));

pat_g2 = [2,3,8];
[par_choices_g2, error_g2] = sort_me(par_choices, error, pat_g2);
err_aux_g2 = sqrt(mean(error_g2(:,pat_g2).^2, 2));
tot_num_g2 = sum(err_aux_g2 < (1.1*err_aux_g2(1)));

pc_g2 = par_choices_g2(1:tot_num_g2,:);
er_g2 = sqrt(mean(error_g2(1:tot_num_g2,pat_g2).^2, 2));


pat_g3 = [4,9,10];
[par_choices_g3, error_g3] = sort_me(par_choices, error, pat_g3);
err_aux_g3 = sqrt(mean(error_g3(:,pat_g3).^2, 2));
tot_num_g3 = sum(err_aux_g3 < (1.1*err_aux_g3(1)));

pc_g3 = par_choices_g3(1:tot_num_g3,:);
er_g3 = sqrt(mean(error_g3(1:tot_num_g3,pat_g3).^2, 2));


figure();
g1 = repmat({'Surgical Group 1'}, size(pc_g1, 1), 1);
g2 = repmat({'Surgical Group 2'}, size(pc_g2, 1), 1);
g3 = repmat({'Surgical Group 3'}, size(pc_g3, 1), 1);
ct = 1;
for i = [1,2,5,6]
    subplot(2,3,ct);hold all;
    violinplot([pc_g1(:,i); pc_g2(:,i); pc_g3(:,i)], [g1;g2;g3]);   
    ct = ct + 1;
end
subplot(2,3,5);hold all;
violinplot([er_g1; er_g2; er_g3], [g1;g2;g3]);  


csvwrite('surgical_group1_pars.csv', [pc_g1, er_g1]);
csvwrite('surgical_group2_pars.csv', [pc_g2, er_g2]);
csvwrite('surgical_group3_pars.csv', [pc_g3, er_g3]);

%%
ct = 1;
figure();
for p = pat_s
    
    if sum(p==pat_g1)
        disp(['group 1: ', num2str(p)]);
        tot_num_s = tot_num_g1;
        pc_s = pc_g1;
    end
    if sum(p==pat_g2)
        disp(['group 2: ', num2str(p)]);
        tot_num_s = tot_num_g2;
        pc_s = pc_g2;
    end
    if sum(p==pat_g3)
        disp(['group 3: ', num2str(p)]);
        tot_num_s = tot_num_g3;
        pc_s = pc_g3;
    end
    
    y_keep = zeros(size(post,1), size(1:100:tot_num_s ,2));
    
    
    subplot(5,2, ct);hold all; 
    for i = 1:100:tot_num_s 
        [t,y] = single_ode(times, pre(:,p), post(:,p), type{1}, pc_s(i,:));
        y = sum(y,2);
        y_keep(:,i) = y;
        plot(t,y / max(post(:,p)),'color', (0.75 - (i/tot_num_s)*[0.50,0.50,0.50]), 'linewidth', 1.5);
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




