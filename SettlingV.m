function [ W ] = SettlingV( d )
%SETTLINGV Iteratively calculates settling velocity
%   based on F and D 1992 p. 198-199
%   d is in 'm' and W is in 'm/s'
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rhoS=2650;      %Density of Sed,  kg/m3
rho=1000;      %Density of Water,   kg/m3
s=rhoS/rho;     %Specific Density, dimensionless
nu=0.000001;    %  kinematic visc., m2/s 
g=9.8;    %  gravity, m/s2; 

%%%Soulsby method
Dstarf=((g*1.65/(nu^2))^(1/3))*0.0001
Dstarc=((g*1.65/(nu^2))^(1/3))*0.001


Dstar=((g*1.65/(nu^2))^(1/3))*d

W=(nu/d)*(((107.3296+(1.049*Dstar^3))^.5)-10.36)


end

