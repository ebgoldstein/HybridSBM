function [ AREA ] = DoIterationDummy( AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS  )
% DoIterationDummy sed transport w/o adjusting cell height.
%   GC: controls iteration by looking at what direction the flow is
%   and then calling the proper sediment transport function
%   DUMMY VERSION DOESN'T ADJUST CELLS, SO THE SED TRANS OUT OF ITERATION CAN
%   ADJUST TO NEW DIRECTION FOR A FEW ITERATIONS FIRST
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[AREA] = SedTransport(AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS );

end

