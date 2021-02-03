%=========================================================================%
% Script: run_data_.m
% Author: Daniel Galvis
%
% Description: This code takes in .xlsx files and saves an interpolated and
% time shifted version of it. See below.
%
% Inputs: dataset.csv looks like this:
% These are the columns, the titles are the first line as follows
% | patient | time | CORTISOL | ACTH 
% patients = 2075, 2079, 2094, 2095, 2097, 2098, 2101, 2102, 2110, 2120
% time     = 0:10:720 (minutes) [surgical]
% time     = 0:10:660 (minutes) [control]

% Outputs:
%    data_all.mat (both)
%    data_control.mat (only control)
%    data_surgical.mat (only surgical)
%       - data is interpolated to 1 minute increments 
%       - acth is time shifted 10 minutes so that cortisol sees 10 minutes
%         previous (IL6 and TNFA are not shifted)
%       - Cortisol is converted from nmol/l to pg/ml (factor 0.0363)
%       - ACTH, IL6, TNFA are not converted
%       - Keep 651 of the points (to match data length of controls)
%       Note cyt1 = IL6, cyt2 = TNFA
%    csv files are also saved for all four of these
%        - matrix time points x patient number 


% Note:
% in data_surgical pats = 1:10 (1-10 patients)
% in data_control pats = 1:3 (1-3 controls)
% in data_all pats = 1:13 (1:10 surgical, 11:13 controls)
%=========================================================================%

% Start
clear;restoredefaultpath;clc;close all;
addpath('data');
addpath('functions');

% Input data folders
finc = 'CORT_ACTH_control_ab.xlsx';
fins = 'CORT_ACTH_surgical.xlsx';
dir  = './data';


% [pre_name, post_name]
var_names = {'ACTH', 'CORTISOL'};
% scale [pre, post] example ACTH -> CORT
conversions = [1, 0.0363];
% time to shift pre by
shift = 10;


% Get data controls
[times, pre, post] = get_data(finc, var_names, conversions, shift,  false);  
pats = 1:size(pre,2);
save(fullfile(dir, 'data_control.mat'), 'pre', 'post', 'times', 'pats');

% Rename controls, find number of points in controls
prec = pre;
postc = post;
num_points = length(times);

% Get data surgical
[times, pre, post] = get_data(fins, var_names, conversions, shift,  false);  
pats = 1:size(pre,2);

% Crop surgical time points so they match controls
times = times(1:num_points);
pre = pre(1:num_points,:);
post = post(1:num_points,:);

save(fullfile(dir, 'data_surgical.mat'), 'pre', 'post', 'times', 'pats');
pres = pre;
posts = post;

% Concatenate surgical and controls and save
pre = [pres,prec];
post= [posts,postc];
pats = 1:size(pre,2);
save(fullfile(dir, 'data_all.mat'), 'pre', 'post', 'times', 'pats');









    
