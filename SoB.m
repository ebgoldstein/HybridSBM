%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is a Matlab rewrite of the Sorted Bedform code, initially written in
%'C' by Giovanni Coco and A. Brad Murray.
%
%"It is easier to write a new code than to understand an old one"
%-John von Neumann to Marston Morse, 1952
%
%
%This is the main script to change when running the model, all
%other functions and model subroutines are incorporated below.
%
%This code can save the entire structure that houses the model data. This
%will enable more detailed comparison between hybrid approaches and empirical
%approaches.
%
%The Code assumes you have the parallel package for matlab.
%
%Some of the features of teh original code are not implemented
%
%Written by EBG 2/12
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all


matlabpool open %Intialize parallel workers


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These set the Domain Size and scaling

CWIDTH=5;                       %cell width in meters
CHEIGHT=0.05;                   %cell height in meters
CVOLUME=CWIDTH*CWIDTH*CHEIGHT;  %cell volume in meters

XMAX=100; %# of Cells in horizontal dimension
YMAX=100; %# of Cells in horizontal dimension
ZMAX=100; %# of Cells in vertical dimension

%Initial depth of the model domain in meters. 25*Cell Height must be
%subtracted to have the effective water depth for models starting from IC.
%This is because the model initializes the IC by filling the first 25
%vertical cells up with sediment.
IDEPTH=11.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These variables set the domain composition and the deposition/erosion rate

%The average percent of coarse material in the domain. Ex: APC=.2 therefore
%average percent coarse in the domain is 20% (with variations around a
%uniform distribution).
APC=0.30;

% The aggradation rate of Coarse and fine material in m/yr. (At the moment
% this feature is not implemented.
AggF=0.0;
AggC=0.0;

%Parameterize the Sediment.
%@ Wrightsville, C=2mm (0.002m),F=0.2mm (0.0002m)
% %
dfine=0.0002;              % diameter of fine sed, in m (0.15mm)
dcoarse=0.0005;              % diameter of coarse sed, in m (1mm)
Wf=0.02;                    % fall velocity of fine sediment
Wc=0.07;                    % fall velocity of coarse sediment


% dfine=0.0002;              % diameter of fine sed, in m
% dcoarse=0.0008;              % diameter of coarse sed, in m
%
% %%Find Fall velocity
% Wf = SettlingV(dfine);
% Wc = SettlingV(dcoarse);

rhoS=2600;                  % sediment density, kg/m3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These variables set the forcing parameters

%CURRENTS
VMEAN=0.1414;
%VMEAN=0.2;         %~10 cm.s (gutierrez et al 2005; storm data)
%Mean current velocity in the x and y direction reported in m/s. This is
%the exact current velocity if VSIGMA=0. The mean velocity in the diagonal
%direction, the direction which is reported in the papers, is found by
%Vd=sqrt((Vmean^2)+(Vmean^2)). Therefore Vmean of 0.1414 works out to be a
%diagonal velocity of .02 m/s.
VSIGMA=0; %Current Velocity excursion.
% VMEAN must be > 3* VSIGMA
if VSIGMA*3>VMEAN;
    error('whoops, VSIGMA is too big compared to VMEAN')
end

currentVelocityX=VMEAN;
currentVelocityY=VMEAN;

%WAVES
T=10;    %wave period, in s
WMEAN=2; %Wave height mean reported in m. This is the exact wave height if WSIGMA=0.
WSIGMA=0; %Wave Height excursion.
% WHEIGHT must be > 3* WSIGMA
if WSIGMA*3>WMEAN;
    error('whoops, WSIGMA is too big compared to WHEIGHT')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Storm event variables
%Not implemeted yet...

AreThereStorms='n'; %Change this to 'y' if you want storms

if AreThereStorms== 'y'
    STORMWAVES=4.0;         %Storm Wave height reported in m.
    BigWaveInt = 100;       %Duration between storms (in units of forcing duration)
    STLength= 4;            %Duration of storm events (in units of forcing duration)
    %SHOULD ADD SOME CURRENTS HERE
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These variables set how long the Model runs, forcing duration length,
%timestep, and when to save

FORCING_DURATION=86400;    %86400 s = 24hrs. after FORCING_DURATION has passed, new wave heights and current velocities are generated */

StartSavingAt=0; %units = FORCING_DURATIONSs*/
FrameSpacing=1; % units = FORCING_DURATIONs (presently 1 day); wave frequency ~= 864/day                    */
maxRunTime = 100; %measured in units of FORCING_DURATIONs; */ presently, 1 FORCING_DURATION = 1 day. */

AdjustTime=10;  %Number of iterations that sediment is transported across
%the BC; used because of changes in direction?

timeStep = 400;   %Time step of model in seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Constants (Maybe export some of these to the functions?

SecPerYear=31536000;        %number of seconds per year

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Some variables, the ones that are used in all the loops, are put in a
%STRUCTURE to be called back by other loops and functions.
%I.e.:Domain Variables, computation variables, Sediment variables, and wave
%variables.

SBVARS=struct('CWIDTH',CWIDTH,'CHEIGHT',CHEIGHT,'CVOLUME',CVOLUME,'XMAX',XMAX,...
    'YMAX',YMAX,'ZMAX',ZMAX,'timeStep',timeStep,'SecPerYear',SecPerYear...
    ,'Wf',Wf,'Wc',Wc,'dfine',dfine,'dcoarse',dcoarse,'rhoS',rhoS,'T',T,'AggF',AggF,'AggC',AggC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Does the Model Start from a file or start from the IC?

startFromFile = 'n';    %User Defined

if startFromFile == 'y'
    load AREA0100.mat;    %User Defined
    offset = 100;         %User Defined; this makes subsequent saved files have the appropriate number
else
    %Make the initial conditions or load them from a file
    [AREA] = InitConds(APC,IDEPTH,SBVARS);
    offset=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create the Model Counters and Initializers

totalElapsedTime = 0.0;       % in seconds */
timeSinceForcingUpdate = 0.0;   % in seconds */
FrameNumber = 1+offset;   % for keeping of track of when to save a new one */
RunTimeClock=0;

%Storm Counters
if AreThereStorms== 'y'
    BigWaveCount=0;
    STCount =0;
end

%Set intial wave conditions
waveHeight = WMEAN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%THIS IS WHERE THE MODEL RUNS!!


%Begin running the model
for RunTime=FrameNumber:maxRunTime;

    %Update Current Direction and velocity
    %[currentVelocityX,currentVelocityY] = ChangeCurrent(currentVelocityX,currentVelocityY,VMEAN,VSIGMA );

    %Update Wave Heights depending on the presence of storms
    if AreThereStorms== 'n'
        [waveHeightold,waveHeight] = ChangeWaves(waveHeight,WMEAN,WSIGMA);
    elseif AreThereStorms== 'y'
        [waveHeightold,waveHeight,BigWaveCount,STCount] = ChangeWavesS(waveHeight,WMEAN,WSIGMA,STORMWAVES,BigWaveCount,STCount,BigWaveInt,STLength);
    end

    %Now the main loop needs to do its thing!!

    for ii=timeStep:timeStep:FORCING_DURATION;
        ii %To print the time step
        [ AREA ] = DoIteration(AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS);
        [ timeSinceForcingUpdate] = UpdateForcingClock( timeSinceForcingUpdate,FORCING_DURATION,timeStep);
        [totalElapsedTime] = UpdateRunTimeClock( totalElapsedTime,timeStep);
        ii=ii+timeStep;
    end

    PrintToFile(AREA,FrameNumber,SBVARS);
    FrameNumber  %To print the frame number that is saved
    FrameNumber =FrameNumber+1;
end

%Print how much time has elapsed
%Save the forcing file..

matlabpool close %Release the parallel workers
