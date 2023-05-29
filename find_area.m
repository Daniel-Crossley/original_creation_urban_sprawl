%% Function to find the area of live cells array
function [area] = find_area(T)
% if there is a particular array that just represents the live people, use that
% array
area = sum(T, 'all');