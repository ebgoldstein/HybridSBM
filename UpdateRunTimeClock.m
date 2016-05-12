function [totalElapsedTime] = UpdateRunTimeClock( totalElapsedTime,timestep)
%UpdateRunTimeClock Summary of this function goes here
%   Detailed explanation goes here
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

totalElapsedTime=totalElapsedTime+timestep;

end
