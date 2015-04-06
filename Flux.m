function [ AREA,excessSed,excessSedC] = Flux(AREA,uMagnitude,vMagnitude, beginX,incrementX,endX,beginY,incrementY,endY)
%UNTITLED4 Summary of this function goes here
%EBG These loops calculate what comes into the cell from adjacent cells
%GC: these give time delay
%This Loop determines how much sediment has come into the cell
%we are looking at, via excess and local flux, from the cell
%previous. This loop cannot be paralelized because it looks
%backward...
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
percentDeposited=AREA.percentDeposited;
percentDepositedC=AREA.percentDepositedC;

QLocalFineX=AREA.localFluxFineX;
QLocalFineY=AREA.localFluxFineY;
QLocalCoarseX=AREA.localFluxCoarseX;
QLocalCoarseY=AREA.localFluxCoarseY;


%Excess out of iteration at the boundaries; 
%FINE
excessOutOfIterFineX=AREA.excessOutofIterFineX;
excessOutOfIterFineY=AREA.excessOutofIterFineY;
%COARSE
excessOutOfIterCoarseX=AREA.excessOutofIterCoarseX;
excessOutOfIterCoarseY=AREA.excessOutofIterCoarseY;

%Local out of iteration at the boundaries; 
%FINE
localOutOfIterFineX=AREA.localFluxOutofIterFineX;
localOutOfIterFineY=AREA.localFluxOutofIterFineY;
%COARSE
localOutOfIterCoarseX=AREA.localFluxOutofIterCoarseX;
localOutOfIterCoarseY=AREA.localFluxOutofIterCoarseY;



for x = beginX:incrementX:endX;
    for y = beginY:incrementY:endY;
        if(x == beginX) %If at the boundaries, Take the excess and local from the other side
            excessInFineX(x,y) = excessOutOfIterFineX(y);%
            LocalFineXin(x,y) = localOutOfIterFineX(y);%
            excessInCoarseX(x,y) = excessOutOfIterCoarseX(y);
            LocalCoarseXin(x,y) = localOutOfIterCoarseX(y);
        else  %Take the excess and local from the previous cell
            excessInFineX(x,y) = excessOutFineX(x - incrementX,y);%
            LocalFineXin(x,y) = QLocalFineX(x - incrementX,y);%
            excessInCoarseX(x,y) = excessOutCoarseX(x - incrementX,y);
            LocalCoarseXin(x,y) = QLocalCoarseX(x - incrementX,y);
        end
        if(y == beginY) %If at the boundaries, Take the excess and local from the other side
            excessInFineY(x,y) = excessOutOfIterFineY(x);%
            LocalFineYin(x,y) = localOutOfIterFineY(x);%
            excessInCoarseY(x,y) = excessOutOfIterCoarseY(x);
            LocalCoarseYin(x,y) = localOutOfIterCoarseY(x);
        else
            excessInFineY(x,y) = excessOutFineY(x,y - incrementY);
            LocalFineYin(x,y) = QLocalFineY(x,y - incrementY);
            excessInCoarseY(x,y) = excessOutCoarseY(x,y - incrementY);
            LocalCoarseYin(x,y) = QLocalCoarseY(x,y - incrementY);
        end

        %Excess sediment is the amount of sediment that is left in the water
        %Column after acounting for the x- and y- directed flux (in and
        %out). Some of it is deposited (loop above figures out how much, loop
        %below adds that amount volumetrically to the appropriate matrix
        %...This Excess sediment not deposited is advected in the down-current direction.
        
        %FINE SED
        excessSed(x,y) = (LocalFineXin(x,y) - QLocalFineX(x,y)) + (LocalFineYin(x,y) - QLocalFineY(x,y))+ (excessInFineX(x,y) + excessInFineY(x,y));
        
        excessOutFineX(x,y) = (1-percentDeposited(x,y))*excessSed(x,y)*(uMagnitude/(uMagnitude + vMagnitude));
        excessOutFineY(x,y) = (1-percentDeposited(x,y))*excessSed(x,y)*(vMagnitude/(uMagnitude + vMagnitude));
        %GC: think about negative excessOut...*/
        
        %%COARSE SED
        excessSedC(x,y) = (LocalCoarseXin(x,y) - QLocalCoarseX(x,y)) + (LocalCoarseYin(x,y) - QLocalCoarseY(x,y))+ (excessInCoarseX(x,y) + excessInCoarseY(x,y));
        
        excessOutCoarseX(x,y) = (1-percentDepositedC(x,y))*excessSedC(x,y)*(uMagnitude/(uMagnitude + vMagnitude));
        excessOutCoarseY(x,y) = (1-percentDepositedC(x,y))*excessSedC(x,y)*(vMagnitude/(uMagnitude + vMagnitude));

        %record how much susp. load to pass in the other side next iteration
        if  x == endX - incrementX
            AREA.excessOutofIterFineX(y) = excessOutFineX(x,y);
            AREA.localFluxOutofIterFineX(y) = QLocalFineX(x,y);
            AREA.excessOutofIterCoarseX(y) = excessOutCoarseX(x,y);
            AREA.localFluxOutofIterCoarseX(y) = QLocalCoarseX(x,y);
        end
        if y == endY - incrementY
            AREA.excessOutofIterFineY(x) = excessOutFineY(x,y);
            AREA.localFluxOutofIterFineY(x) = QLocalFineY(x,y);
            AREA.excessOutofIterCoarseY(x) = excessOutCoarseY(x,y);
            AREA.localFluxOutofIterCoarseY(x) = QLocalCoarseY(x,y);
        end
    end
end

end

