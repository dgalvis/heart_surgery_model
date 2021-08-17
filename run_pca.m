restoredefaultpath;clear; close all; clc;
addpath('functions_cyts');


% Cytokine data directory
dir = './data/cytokines';
% Cytokine data filename
fin = fullfile(dir, 'dataset_full.csv');
% [pre, post, cyt1, cyt2]
var_names = {'ACTH', 'CORTISOL', 'IL10', 'IL6', 'IL8', 'TNFA'};
% scale [pre, post, cyt1, cyt2] 
conversions = [1, 1, 1, 1, 1, 1];
% Time to shift pre by
shift = 0;

% Get data
[times, acth, cort, il10, il6, il8, tnfa] = get_data_cyts(fin, var_names, conversions, shift,  false);

acth = (acth - mean(acth,1)) ./ std(acth,1);
cort = (cort - mean(cort,1)) ./ std(cort,1);
il10 = (il10 - mean(il10,1)) ./ std(il10,1);
il6 = (il6 - mean(il6,1)) ./ std(il6,1);
il8 = (il8 - mean(il8,1)) ./ std(il8,1);
tnfa = (tnfa - mean(tnfa,1)) ./ std(tnfa,1);

labels = {'cortisol', 'acth', 'IL10', 'IL6', 'IL8', 'TNF\alpha'};
N = length(labels);
%% PCA

% Run PCA
[~,~,~,~,acth_cort,~] = pca([acth(:), cort(:)]);
[~,~,~,~,il10_cort,~] = pca([il10(:), cort(:)]);
[~,~,~,~,il6_cort,~] = pca([il6(:), cort(:)]);
[~,~,~,~,il8_cort,~] = pca([il8(:), cort(:)]);
[~,~,~,~,tnfa_cort,~] = pca([tnfa(:), cort(:)]);

[~,~,~,~,il10_acth,~] = pca([il10(:), acth(:)]);
[~,~,~,~,il6_acth,~] = pca([il6(:), acth(:)]);
[~,~,~,~,il8_acth,~] = pca([il8(:), acth(:)]);
[~,~,~,~,tnfa_acth,~] = pca([tnfa(:), acth(:)]);

[~,~,~,~,il6_il10,~] = pca([il6(:), il10(:)]);
[~,~,~,~,il8_il10,~] = pca([il8(:), il10(:)]);
[~,~,~,~,tnfa_il10,~] = pca([tnfa(:), il10(:)]);

[~,~,~,~,il8_il6,~] = pca([il8(:), il6(:)]);
[~,~,~,~,tnfa_il6,~] = pca([tnfa(:), il6(:)]);

[~,~,~,~,tnfa_il8,~] = pca([tnfa(:), il8(:)]);

% Put into a matrix
pca_map = zeros(N);
pca_map(1,2) = acth_cort(1);
pca_map(1,3) = il10_cort(1);
pca_map(1,4) = il6_cort(1);
pca_map(1,5) = il8_cort(1);
pca_map(1,6) = tnfa_cort(1);
pca_map(2,3) = il10_acth(1);
pca_map(2,4) = il6_acth(1);
pca_map(2,5) = il8_acth(1);
pca_map(2,6) = tnfa_acth(1);
pca_map(3,4) = il6_il10(1);
pca_map(3,5) = il8_il10(1);
pca_map(3,6) = tnfa_il10(1);
pca_map(4,5) = il8_il6(1);
pca_map(4,6) = tnfa_il6(1);
pca_map(5,6) = tnfa_il8(1);


% Symmetric
pca_map = pca_map + pca_map';
pca_map = pca_map + 100*eye(N);


% Get numbers
x = repmat(1:N,N,1); % generate x-coordinates
y = x'; % generate y-coordinates
% Generate Labels
t = num2cell(round(pca_map)); % extact values into cells
t = cellfun(@num2str, t, 'UniformOutput', false); % convert to string


% Plot
figure('Position', [10,10,1200,600]);
subplot(1,2,1);hold all;
imagesc(pca_map);
text(x(:), y(:), t, 'HorizontalAlignment', 'Center');
axis tight;
set(gca, 'YDir', 'reverse');
caxis([50,100]);colorbar;
xticklabels(labels);
yticklabels(labels);
title('PCA');
%% CORR
acth_cort = corr([acth(:), cort(:)]);
il10_cort = corr([il10(:), cort(:)]);
il6_cort = corr([il6(:), cort(:)]);
il8_cort = corr([il8(:), cort(:)]);
tnfa_cort = corr([tnfa(:), cort(:)]);

il10_acth = corr([il10(:), acth(:)]);
il6_acth = corr([il6(:), acth(:)]);
il8_acth = corr([il8(:), acth(:)]);
tnfa_acth = corr([tnfa(:), acth(:)]);

il6_il10 = corr([il6(:), il10(:)]);
il8_il10 = corr([il8(:), il10(:)]);
tnfa_il10 = corr([tnfa(:), il10(:)]);

il8_il6 = corr([il8(:), il6(:)]);
tnfa_il6 = corr([tnfa(:), il6(:)]);

tnfa_il8 = corr([tnfa(:), il8(:)]);

% Put into a matrix
corr_map = zeros(N);
corr_map(1,2) = acth_cort(2,1);
corr_map(1,3) = il10_cort(2,1);
corr_map(1,4) = il6_cort(2,1);
corr_map(1,5) = il8_cort(2,1);
corr_map(1,6) = tnfa_cort(2,1);
corr_map(2,3) = il10_acth(2,1);
corr_map(2,4) = il6_acth(2,1);
corr_map(2,5) = il8_acth(2,1);
corr_map(2,6) = tnfa_acth(2,1);
corr_map(3,4) = il6_il10(2,1);
corr_map(3,5) = il8_il10(2,1);
corr_map(3,6) = tnfa_il10(2,1);
corr_map(4,5) = il8_il6(2,1);
corr_map(4,6) = tnfa_il6(2,1);
corr_map(5,6) = tnfa_il8(2,1);


% Symmetric
corr_map = corr_map + corr_map';
corr_map = corr_map + eye(N);


% Get numbers
x = repmat(1:N,N,1); % generate x-coordinates
y = x'; % generate y-coordinates
% Generate Labels
t = num2cell(round(corr_map,2)); % extact values into cells
t = cellfun(@num2str, t, 'UniformOutput', false); % convert to string


% Plot
subplot(1,2,2);hold all;
imagesc(corr_map);
text(x(:), y(:), t, 'HorizontalAlignment', 'Center');
axis tight;
set(gca, 'YDir', 'reverse');
caxis([0,1]);colorbar;
xticklabels(labels);
yticklabels(labels);
title('Correlations');

