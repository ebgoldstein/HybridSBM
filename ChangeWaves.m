function [WaveHeightold,WaveHeight] = ChangeWaves(WaveHeight,WMEAN,WSIGMA)
%CHANGE WAVES This function changes the waves every forcing duration.
%   Changes waves based on normal distribution
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    WaveHeightold=WaveHeight;
    WaveHeight=normrnd(WMEAN,WSIGMA);
    
end


