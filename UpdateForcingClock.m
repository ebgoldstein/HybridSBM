function [ timeSinceForcingUpdate] = UpdateForcingClock( timeSinceForcingUpdate,FORCING_DURATION,timeStep)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if timeSinceForcingUpdate >= FORCING_DURATION;
    timeSinceForcingUpdate=0;
else
    timeSinceForcingUpdate=timeSinceForcingUpdate+timeStep;
end

    
end
