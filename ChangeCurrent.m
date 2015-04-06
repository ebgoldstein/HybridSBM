function [currentVelocityX,currentVelocityY] = ChangeCurrent(currentVelocityX,currentVelocityY,VMEAN,VSIGMA )
%CHANGE CURRENT This function changes the current every forcing duration.
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %Change current Velocity and Reverse the direction
    currentVelocityX = -sign(currentVelocityX)*normrnd(VMEAN,VSIGMA); %Update current velocity
    currentVelocityY = currentVelocityX;    %Make sure current velocity is equal

end

