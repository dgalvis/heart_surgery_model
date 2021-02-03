%=========================================================================%
%function activation = hill_fun(points, exp, half)
%    activation = points.^exp ./ (half.^exp + points.^exp);
%
%
% This function implements a hill equation 
%
%
% Parameters
% ----------
% point : float or array of floats
% half : float
% exp : integer or float (biophysically it is often an integer)
%
%
% Returns
% -------
% activation : float in [0,1] or array of floats in [0,1]
%    activation(i,j) = point(i,j).^exp / (half^exp + point(i,j)^exp);
%=========================================================================%
function activation = hill_fun(point, exp, half)
    activation = point.^exp ./ (half.^exp + point.^exp);
end
