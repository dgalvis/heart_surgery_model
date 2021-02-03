%=========================================================================%
% function [new_times, outputs] = interpolater(times, inputs, pts)
%
%
% This function uses linear interpolation to resample a dataset. It assumes
% the data has at most 3 dimensions and that time points is the first dimension
% 
% Parameters
% ----------
% times : data_points x 1 array
%     time points
% inputs : data_points x N x M array
%     data points 
% pts : int
%     resample to this many points
%
%
% Returns
% -------
% new_times : pts x 1 array
%     resampled time points
% outputs : pts x N x M array
%     resampled data points
%=========================================================================%
function [new_times, outputs] = interpolater(times, inputs, pts)


    % New times and a zeros array for new time series'
    new_times = linspace(times(1), times(end), pts);
    outputs = zeros(pts, size(inputs, 2), size(inputs, 3));
    

    for i = 1:size(inputs, 2)
        for j = 1:size(inputs, 3)
            % Interpolation of each time series
            outputs(:, i, j) = interp1(times, inputs(:, i, j), new_times,'spline');
        end
    end
end
