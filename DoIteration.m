function [ AREA ] = DoIteration( AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS  )
% DoIteration Calls sediment transport routines, cell adjustment rotine,
% and time adjustment routines.
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[AREA] = SedTransport(AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS );
[AREA] = AdjustCells( AREA,SBVARS );
%[AREA] = Zerovars( AREA,SBVARS);

end

