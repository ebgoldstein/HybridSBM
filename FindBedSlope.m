function [ bedslopeX,bedslopeY ] = FindBedSlope( beginX,incrementX,endX,beginY,incrementY,endY,z,PERCENTFULL,CHEIGHT,CWIDTH)
%FINDBEDSLOPE This loop calculates the local bed slope.
%   
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for x = beginX:incrementX:endX;
    for y = beginY:incrementY:endY

        if x == endX ;
            bedslopeX(x,y)=((z(beginX,y)+PERCENTFULL(beginX,y))-(z(x,y)+PERCENTFULL(x,y)))*(CHEIGHT/CWIDTH);
        else
            bedslopeX(x,y) =((z(x + incrementX,y)+PERCENTFULL(x + incrementX,y))- (z(x,y)+PERCENTFULL(x,y)))*(CHEIGHT/CWIDTH);
        end
        if y == endY ;
            bedslopeY(x,y)=((z(x,beginY)+PERCENTFULL(x,beginY))-(z(x,y)+PERCENTFULL(x,y)))*(CHEIGHT/CWIDTH);
        else
            bedslopeY(x,y) =((z(x,y + incrementY)+PERCENTFULL(x,y + incrementY))- (z(x,y)+PERCENTFULL(x,y)))*(CHEIGHT/CWIDTH);
        end
        
    end
end

end

