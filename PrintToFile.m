function  PrintToFile(AREA,FrameNumber,SBVARS )
%PrintToFile This function prints the SoB data to a file
%  
%   This function clears all variables and saves the SoB variables, as a
%   whole. I.e. it saves the entire structure that the SB file is made of.
%   This may be untenable when the files get big, but it is worth a try
%   right now. Also this will be able to save many statistics, thereby
%   enabling a better comparison with the hybrid models.
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%EPC=AREA.EffectivePercentCoarse;

%Try this first
S = ['save AREA',sprintf('%04d',FrameNumber) ' AREA'];
eval(S)

%this should probably write the forcing conditions

end

