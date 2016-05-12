function [ TaoC ] = ShieldsCrit(d)
%ShieldsCritical Calculates critical shields for motion
    %Based off of soulsby 1997 eqn 77 p.106.
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define some parameters
nu=0.000001;                %kinematic visc. of water, m2/s
g=9.8;                      %gravity in m/s^2
SSD=1.65;                   %Submerged specific density (rhos/rho)-1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dstar=d*((g*SSD/(nu^2))^(1/3));        %eqn 75

TaoC=(.3/(1+(1.2*(Dstar)))+(0.55*(1-exp(-0.02*Dstar))));

end
