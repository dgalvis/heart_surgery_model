%=========================================================================%
% Script: run_data_cyts.m
% Author: Daniel Galvis
%
% Description: This code takes in dataset.csv and saves an interpolated and
% time shifted version of it. See below.
%
% Inputs: dataset.csv looks like this:
% These are the columns, the titles are the first line as follows
% | patient | time | CORTISOL | ACTH | IL6 | TNFA |
% patients = 2075, 2079, 2094, 2095, 2097, 2098, 2101, 2102, 2110, 2120
% time     = 0:10:720 (minutes)

% Outputs:
%    cytokines_data.mat
%       - data is interpolated to 1 minute increments 
%       - acth is time shifted 10 minutes so that cortisol sees 10 minutes
%         previous (IL6 and TNFA are not shifted)
%       - Cortisol is converted from nmol/l to pg/ml (factor 0.0363)
%       - ACTH, IL6, TNFA are not converted
%       - Keep 651 of the points (to match data length of controls)
%       Note cyt1 = IL6, cyt2 = TNFA
%    csv files are also saved for all four of these
%        - matrix time points x patient number 
%=========================================================================%

% Beginning
restoredefaultpath;clear; close all; clc;
addpath('functions_cyts');


% Cytokine data directory
dir = './data/cytokines';
% Cytokine data filename
fin = fullfile(dir, 'dataset.csv');
% [pre, post, cyt1, cyt2]
var_names = {'ACTH', 'CORTISOL', 'IL6', 'TNFA'};
% scale [pre, post, cyt1, cyt2] 
conversions = [1, 0.0363, 1, 1];
% Time to shift pre by
shift = 10;

% Get data
[times, pre, post, cyt1, cyt2] = get_data_cyts(fin, var_names, conversions, shift,  false);


% keep same number of points as controls
num_points = 651;
times = times(1:num_points);
pre = pre(1:num_points,:);
post = post(1:num_points,:);
cyt1 = cyt1(1:num_points,:);
cyt2 = cyt2(1:num_points,:);

% Save outputs
save(fullfile(dir,'cytokines_data.mat'));
csvwrite(fullfile(dir,'cortisol.csv'), post);
csvwrite(fullfile(dir,'acth.csv'), pre);
csvwrite(fullfile(dir,'IL6.csv'), cyt1);
csvwrite(fullfile(dir,'TNFA.csv'), cyt2);