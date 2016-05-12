function [ OrbitalVel,OrbitalExcurs ] = OrbitalParams( Kdw,D,waveHeight,T )
%ORBITAL PARAMETERS Summary of this function goes here
%   calculates maximum wave orbital velocity and wave orbital amplitude
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%With wave number (Kdw) we can get the wave parameters
% Such as wave orbital speed (Uw):
OrbitalVel = (1./(sinh(Kdw.*D)))*(pi*waveHeight/T);

%and wave orbital amplitude (Aw);(OrbitalVel=SIGMA*OrbitalExcurs)
OrbitalExcurs = (0.5*waveHeight)./sinh(Kdw.*D);


end
