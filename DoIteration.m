function [ AREA ] = DoIteration( AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS  )
% DoIteration Calls sediment transport routines, cell adjustment rotine,
% and time adjustment routines.
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[AREA] = SedTransport(AREA,currentVelocityX,currentVelocityY,waveHeight,SBVARS );
[AREA] = AdjustCells( AREA,SBVARS );
%[AREA] = Zerovars( AREA,SBVARS);

end

