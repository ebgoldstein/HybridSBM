function [WaveHeightold,WaveHeight,BigWaveCount,STCount] = ChangeWavesS(WaveHeight,WMEAN,WSIGMA,STORMWAVES,BigWaveCount,STCount,BigWaveInt,STLength)
%CHANGE WAVES STORMS This function changes the waves every forcing duration.
%   Detailed explanation goes here
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WaveHeightold=WaveHeight;

if BigWaveCount < BigWaveInt
    WaveHeight = normrnd(WMEAN,WSIGMA);
    BigWaveCount=BigWaveCount+1;
else
    WaveHeight = STORMWAVES;
    STCount = STCount+1;
    if (STCount >= STLength) %storm duration, in units of forcing duration (days)*/
        BigWaveCount=0;
        STCount=0;
    end
end


