function [ Kdw ] = dispersion( XMAX,YMAX,SIGMA,D )
%DISPERSION RELATION Find the wave number using iterations of the
%disperision equation for a plan view grid of bathymetry
%   Detailed explanation goes here
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g=9.8;                      %gravity in m/s^2

%Dispersion relation is solved using Dean and Dalrymple p. 72.
%Iterative Loop to find Wave number
%Starting value for the loop is Kdw0
KDW=zeros(XMAX,YMAX);

parfor i=1:XMAX
    for j=1:YMAX
        Kdw0=(SIGMA^2)*(1/g)*((tanh((SIGMA^2)*(D(i,j)/g)))^(- 0.5));     %First approximatio of wave #
        Kdw=(SIGMA^2)*(1/g)*(1/tanh(Kdw0*D(i,j)));                       %Wave number
        Kaux=abs(1-(Kdw0/Kdw));
        while Kaux >= 0.01
            Kdw0=Kdw;
            Kdw=(SIGMA^2)*(1/g)*(1/tanh(Kdw0*D(i,j)));                       %Wave number
            Kaux=abs(1-(Kdw0/Kdw));
        end
        KDW(i,j)=Kdw;
    end
end
clear Kdw
Kdw=KDW;
% Kdw0=zeros(XMAX,YMAX);
% Kdw=zeros(XMAX,YMAX);
% Kaux=zeros(XMAX,YMAX);
% parfor i=1:XMAX
%     for j=1:YMAX
%         Kdw0(i,j)=(SIGMA^2)*(1/g)*((tanh((SIGMA^2)*(D(i,j)/g)))^(- 0.5));     %First approximatio of wave #
%         Kdw(i,j)=(SIGMA^2)*(1/g)*(1/tanh(Kdw0(i,j)*D(i,j)));                       %Wave number
%         Kaux(i,j)=abs(1-(Kdw0(i,j)/Kdw(i,j)));
%         while Kaux(i,j) >= 0.01
%             Kdw0(i,j)=Kdw(i,j);
%             Kdw(i,j)=(SIGMA^2)*(1/g)*(1/tanh(Kdw0(i,j)*D(i,j)));                       %Wave number
%             Kaux(i,j)=abs(1-(Kdw0(i,j)/Kdw(i,j)));
%         end
%     end
% end

end
