function [ timeSinceForcingUpdate] = UpdateForcingClock( timeSinceForcingUpdate,FORCING_DURATION,timeStep)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if timeSinceForcingUpdate >= FORCING_DURATION;
    timeSinceForcingUpdate=0;
else
    timeSinceForcingUpdate=timeSinceForcingUpdate+timeStep;
end


end
