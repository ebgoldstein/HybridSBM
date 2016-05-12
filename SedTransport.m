function [AREA] = SedTransport(AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS )
%SEDTRANSPORT  Sediment transport function
%   This function transports BOTH fractions of the sediment
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define Some Constants

rho=1000;                   %water density, kg/m3
g=9.8;                      %gravity in m/s^2

CWIDTH=SBVARS.CWIDTH;
CHEIGHT=SBVARS.CHEIGHT;
XMAX=SBVARS.XMAX;
YMAX=SBVARS.YMAX;
timeStep=SBVARS.timeStep;
Wf=SBVARS.Wf;
Wc=SBVARS.Wc;
dfine=SBVARS.dfine;
dcoarse=SBVARS.dcoarse;
rhoS=SBVARS.rhoS;
T=SBVARS.T;


% ConvertToEffGrSz=1.0;
SIGMA=(2*pi/T); %Cyclic frequency, usually lowercase omega
hustar=2.0; % z* in von Karman EQN
karman=0.4; %  von karman's constant (Kappa in Coco et al. 2007a EQN 7)

%Convert FROM Immersed Wt TO Volumetric flux rate per unit width
ImWttoVol=1/((rhoS-rho)*g);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


uMagnitude = currentVelocityX;
vMagnitude = currentVelocityY;

%Find which direction to sweep the grid. u or v mag is negative, then
%convert to positive for the rest of the computations.
if uMagnitude > 0
    beginX = 1;
    endX   = XMAX;
    incrementX = 1;
else
    beginX = XMAX ;
    endX   = 1;
    incrementX = -1;
    uMagnitude = -uMagnitude;
end
if vMagnitude > 0
    beginY = 1;
    endY   = YMAX;
    incrementY = 1;
else
    beginY = YMAX;
    endY   = 1;
    incrementY = -1;
    vMagnitude = -vMagnitude;
end

%make  new variables for the relevant matricies from the structure, just to
%make coding easier.
% dummyAPF=AREA.percentFull;
% dummyAPC=AREA.percentCoarse;
DEPTH=AREA.depth;
z=AREA.activeZ;
PERCENTFULL=AREA.percentFullatAL;

%Calculate the depth at each x-y location; EBG changed this
D=DEPTH-((z)*0.05)+((PERCENTFULL-1)*0.05);
AREA.actualdepth=D;
%Find the wave number by solving the dispersion relation
[ Kdw ] = dispersion( XMAX,YMAX,SIGMA,D );
AREA.Kdw=Kdw;

%Find Wave Orbital Parameters
[ OrbitalVel,OrbitalExcurs ] = OrbitalParams( Kdw,D,waveHeight,T);
AREA.OrbitalVel=OrbitalVel;
AREA.OrbitalExcurs=OrbitalExcurs;

%Pull from the Structure the %coarse over top 3*CELL_HEIGHT so that it changes smoothly
EffectivePercentCoarse =AREA.EffectivePercentCoarse;

%Get the D50 of the AL
%there was a d50Ripples which multiplied 2nd term by
%'ConvertToEffGrSz' which had been set to '1'. EBG eliminated
%this parameter and eliminated d50Ripples.
%This is EQN 24 in Coco et al 2007a
d50 = dfine*(1- EffectivePercentCoarse) + dcoarse*(EffectivePercentCoarse);

AREA.d50=d50;

%Shields estimation based on bed composision and wave forcing
Shieldscritical=0.04;
%ShieldscriticalF = ShieldsCrit(dfine);
%ShieldscriticalC = ShieldsCrit(dcoarse);
%AREA.ShieldscriticalF=ShieldscriticalF;
%AREA.ShieldscriticalC=ShieldscriticalC;

nikuk=2.5*d50;              %This is the grain roughness, Ks.

%This is EQN 12 in Coco et al 2007a;
%The determination of the skin friction wave friction factor
%from Swart 1974.
FrictionParam=exp((5.213*((nikuk./OrbitalExcurs).^0.194))-5.977);

%GC note: ATTENTION! d50 is used to evaluate ShieldsParam. The assumption
%is that the whole bed composition is key to putting sediment
%in suspension,the diffusivity profile is instead related
%to the individual grain size under consideration
%EBG deleted Shields ripple and replaced all occurences with
%ShieldsParam because d50 and d50ripple are identical (see note above)
%SheildsParam= tao/rho((rhos/rho)-1)gd50 (e.g. Nielsen 1986)
%tao=.5*rho*FrictionParam*u1m^2 (f and D p24)

ShieldsParam = (FrictionParam./(3.3*g*d50) ).*((SIGMA*OrbitalExcurs).^2);
AREA.ShieldsParam=ShieldsParam;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RIPPLES!!

%Genetic Programming Predictor
[RippleHeight,RippleAspectRatio,RippleLength] = RippleGP(AREA,ShieldsParam,Shieldscritical,T,d50,OrbitalVel,XMAX,YMAX);

%Update the ripples
AREA.RippleHeight=RippleHeight;
AREA.RippleLength=RippleLength;
AREA.RippleAspectRatio=RippleAspectRatio;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This sediment diffusivity is from Nielsen 1992 with del increased
% as per Thorne et al 2002 and Thorne et al 2009;
% Furthermore Thorne et al 2009 mentioned that the Nielsen diffusivity expression may be
%an underestimate (factor of 2). this allows use to double it (ThorneC=2 is doubling)..
ThorneC=2;

del=25;
ks=del*RippleHeight.*(RippleAspectRatio);

%For Fine Sed
auxexp2=ThorneC*0.016*(ks.*OrbitalVel);
%For Coarse Sed
auxexp2C=ThorneC*0.016*(ks.*OrbitalVel);

AREA.auxexp2=auxexp2;
AREA.auxexp2C=auxexp2C;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Suspended sediment reference concentration, predicted by GP..

%gp CREF in g/L
CrefFgL=((0.328*OrbitalVel)/(0.0688+(1000*dfine))).^2;
CrefCgL=((0.328*OrbitalVel)/(0.0688+(1000*dcoarse))).^2;


%Convert g/L to m3/m3
CrefF=(1/rhoS)*CrefFgL;
CrefC=(1/rhoS)*CrefCgL;


AREA.CrefFgL=CrefFgL;
AREA.CrefCgL=CrefCgL;
AREA.CrefF=CrefF;
AREA.CrefC=CrefC;

%Roughness related to wave-generated ripples, EQN 18 in Coco et al. 2007a
zeta0=(((28*RippleHeight).*RippleAspectRatio)+(2*d50))/30;

%Assume logarithmic current Profile
%Shear velocity in x-direction where V*=uMag and z*=2.
%From rearranged eqn 17 Coco et al 2007a
ustar=(karman*uMagnitude)./log(hustar./(zeta0));
%Shear velocity in y-direction where V*=vMag and z*=2
%From rearranged eqn 17 Coco et al 2007a
vstar=(karman*vMagnitude)./log(hustar./(zeta0));

%CALCULATE LOCAL EQUILIBRIUM Integrated SUSPENDED SEDIMENT
%Fine Sediment
[ IntegratedConcy, IntegratedConcx,coeffcrit ] = IntegratedSSConcentration(XMAX,YMAX,CrefF,zeta0,RippleHeight,Wf,auxexp2,karman,hustar,ustar,vstar,uMagnitude,vMagnitude);
%Coarse Sediment
[ IntegratedConcyC, IntegratedConcxC,coeffcritC ] = IntegratedSSConcentration(XMAX,YMAX,CrefC,zeta0,RippleHeight,Wc,auxexp2C,karman,hustar,ustar,vstar,uMagnitude,vMagnitude);
AREA.IntegratedConcy=IntegratedConcy;
AREA.IntegratedConcx=IntegratedConcx;
AREA.IntegratedConcyC=IntegratedConcyC;
AREA.IntegratedConcxC=IntegratedConcxC;
AREA.coeffcritC=coeffcritC;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%GC:Convert the concentraton profiles to immersed weight.
%ConvertToImmersedWt=(rhoS-rho)*g;
%EBG note: I don't do this, instead i convert q2 parts from Imm weight to
%volumetric flux... see notes above the qs2 equation (below)
%Currently the qsx1 routines below is the intergrated ConC profile is in (m^2)/(s)
%because it is the vertical integral of the each slice of the ss column,
%where each slice represents the product of the slice height (in m), the
%volumetric concentration (m^3/m^3), and the current velocity (in m/s).
%To get the volumetric seidment flux out of the cell (m^3/s), you take the
%integrated concentration and multiply by the cell width, which is done in
%the TOTAL (local) sed flux eqns below..
%%%%%%%%%%%%%%%%%%%%

%FINE SED
qsx1=(IntegratedConcx);
qsy1=(IntegratedConcy);
%COARSE SED
qsx1C=(IntegratedConcxC);
qsy1C=(IntegratedConcyC);

AREA.qsx1=qsx1;
AREA.qsy1=qsy1;
AREA.qsx1C=qsx1C;
AREA.qsy1C=qsy1C;

%Drag Coefficient; EQN 7 Coco et al 2007a. In the paper this eqn is
%written incorrectly. this formulation follows one by soulsby 1997 i think.
%EBG:EQN from the code:
%CD=(karman./log(hustar./(zeta0))).^2;
%This is from Soulsby 1997 p55 (assumes log profile for entire water column).
%In this formulation, because log profile is not present through the entire water
%column,  beta might be replaced by (hustar./2*D)-log(hustar./2*D); this is
%~3 in the case of hustar=2 and D ~20...
beta=1;
CD=(karman./(beta+log((zeta0)./D))).^2;
AREA.CD=CD;

%Gamma sub-c in Coco et al 2007a EQN 6
%This is a parameter that 'tunes' the bedslope term in the transport
%equation. (morphodynamic diffusion term)
coeffslope=0.07;

%Efficiency factor in Coco et al 2007a EQN 6
Es=0.035;
%Gamma sub-s; EQN 6 Coco et al 2007a
%%FINE
coeff = coeffslope*16*Es*rho/(3*pi*Wf);
%%%COARSE
coeffC = coeffslope*16*Es*rho/(3*pi*Wc);


%Find the local bedlsope (periodic BC for the edges)
[ bedslopeX,bedslopeY ] = FindBedSlope( beginX,incrementX,endX,beginY,incrementY,endY,z,PERCENTFULL,CHEIGHT,CWIDTH);
AREA.bedslopeX=bedslopeX;
AREA.bedslopeY=bedslopeY;


%This is the third term of equation 5 in Coco et al 2007a
%I convert this from immersed wt C to volume C


%%%FINE SED
qsx2=ImWttoVol*coeff *coeffcrit.* CD .* ((OrbitalVel).^5) .*bedslopeX* (1/(5*Wf));
qsy2=ImWttoVol*coeff *coeffcrit.* CD .* ((OrbitalVel).^5) .*bedslopeY* (1/(5*Wf));

%%%COARSE SED
qsx2C=ImWttoVol*coeffC *coeffcritC .* CD .* ((OrbitalVel).^5) .*bedslopeX * (1/(5*Wc));
qsy2C=ImWttoVol*coeffC *coeffcritC .* CD .* ((OrbitalVel).^5) .* bedslopeY * (1/(5*Wc));

AREA.qsx2=qsx2;
AREA.qsy2=qsy2;
AREA.qsx2C=qsx2C;
AREA.qsy2C=qsy2C;

%This is EQN 3 modified by the amount of fine material in the
%AL, (Multiplied through by the B term in (coco et al eqn 2)
%such that "The flux of fine sediment leaving the bed is the
%flux that would be entrained from an all-fine bed multiplied
%by the percentage of fine sediment in the active layer" Coco
%et al. 2007a p3-4
%two suspended sed terms are present because of the 2 terms in eqn 5

%All these flux terms are in volumetric sed flux (m^3/s)...

%%%%EBG NOTE: when flux is very large, this routine presents a problem
%because it can flux the same amount of material in both the X and Y direction,
%essentially selling the same car twice... this is where the model stability
%is compromised....

%%%FINE SED
QLocalFineX = (1 - EffectivePercentCoarse) .* (qsx1 - qsx2);
QLocalFineY = (1 - EffectivePercentCoarse) .* (qsy1 - qsy2);
%%%COARSE SED
QLocalCoarseX = (EffectivePercentCoarse) .* (qsx1C - qsx2C);
QLocalCoarseY = (EffectivePercentCoarse) .* (qsy1C - qsy2C);

AREA.localFluxFineX=QLocalFineX;
AREA.localFluxFineY=QLocalFineY;
AREA.localFluxCoarseX=QLocalCoarseX;
AREA.localFluxCoarseY=QLocalCoarseY;

%Percent deposited is the ratio between the time it
%takes for sediment of a specific grain size to be advected
%through a cell under the effect of the current vs the time for
%sediment to settle:

%This is Tsettle in coco et al eqn4.
%Measure of concentration profile height,
%'turbulence' or based on the diffusion ceofficient
% vs the fall velocity of the size fraction.
%%%FINE SED
effectiveProfileHeight = auxexp2/Wf;
%%%COARSE SED
effectiveProfileHeightC = auxexp2C/Wc;

AREA.effectiveProfileHeight=effectiveProfileHeight;
AREA.effectiveProfileHeightC=effectiveProfileHeightC;

%This is equation 4 from Coco et al. 2007a. Determines how much
%sediment is deposited based of concentration profile height
%current madgnitude and the sediment fall velocity.


if uMagnitude > vMagnitude
    %FINE SED
    percentDeposited = (Wf*CWIDTH)./(uMagnitude *effectiveProfileHeight);
    %COARSE SED
    percentDepositedC = (Wc*CWIDTH)./(uMagnitude *effectiveProfileHeightC);
else
    %FINE SED
    percentDeposited = (Wf*CWIDTH)./(vMagnitude *effectiveProfileHeight);
    %COARSE SED
    percentDepositedC = (Wc*CWIDTH)./(vMagnitude *effectiveProfileHeightC);
end

%Percent Deposited can;t be negative
if min(percentDeposited)< 0
    error('Woo! This can not be! (percent deposited < 0)');
end
if min(percentDepositedC)< 0
    error('Woo! This can not be! (percent deposited < 0)');
end

%Percent Deposited can't be greater than 1
percentDeposited=min(percentDeposited,1);
percentDepositedC=min(percentDepositedC,1);

AREA.percentDeposited=percentDeposited;
AREA.percentDepositedC=percentDepositedC;

%%%%THIS IS THE BIG LOOP that figures out equation 2 in coco et al 2007a.
%figures out 'what is the excess sed?'
[ AREA,excessSed,excessSedC] = Flux(AREA,uMagnitude,vMagnitude, beginX,incrementX,endX,beginY,incrementY,endY);
%Determine the amount of fine and Coarse sediment to deposit.
%EBG note: removed converted to volume step because everything is already
%volumetric flux per unit width..just need to account for time step, cell
%width, and packing ratio: 0.6 exists because this is the percentage of
%sediment in a given unit volume (i.e. a packing ratio)

FVA=percentDeposited.*excessSed*(CWIDTH*timeStep/0.6);
CVA=percentDepositedC.*excessSedC*(CWIDTH*timeStep/0.6);
AREA.fineVolumeAdded = FVA;
AREA.coarseVolumeAdded = CVA;
end
