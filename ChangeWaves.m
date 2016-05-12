function [WaveHeightold,WaveHeight] = ChangeWaves(WaveHeight,WMEAN,WSIGMA)
%CHANGE WAVES This function changes the waves every forcing duration.
%   Changes waves based on normal distribution
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    WaveHeightold=WaveHeight;
    WaveHeight=normrnd(WMEAN,WSIGMA);
    
end


