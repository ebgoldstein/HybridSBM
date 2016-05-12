function [ AREA ] = AdjustCells( AREA,SBVARS )
%ADJUSTCELLS Adjusts domain to depositon/erosion
%   Detailed explanation goes here
%
%
%The MIT License (MIT)
%Copyright (c) 2016 Evan B. Goldstein
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define some Variables

CWIDTH=SBVARS.CWIDTH;
CVOLUME=SBVARS.CVOLUME;
XMAX=SBVARS.XMAX;
YMAX=SBVARS.YMAX;
SecPerYear=SBVARS.SecPerYear;
timeStep=SBVARS.timeStep;
AggF=SBVARS.AggF;
AggC=SBVARS.AggC;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


z=AREA.activeZ;                     %This is just the active layer to make the code writting easier and more brief
PERCENTFULLatAL=AREA.percentFullatAL;   %This is just the percent full at the active layer to make the code writting easier and more brief




%How much fine sed. should be added to the cell
FineAdd = AREA.fineVolumeAdded+((AggF/SecPerYear)*timeStep*CWIDTH*CWIDTH);
AREA.FineAdd=FineAdd;
%How much coarse sed. should be added to the cell
CoarseAdd = AREA.coarseVolumeAdded+((AggC/SecPerYear)*timeStep*CWIDTH*CWIDTH);
AREA.CoarseAdd=CoarseAdd;
%The total volume of new sediment to add to the cell
TotalAdd = ((FineAdd + CoarseAdd) / CVOLUME);

AREA.TotalAddedSediment=TotalAdd;

%How full is the cell with the new material?
newFullness = TotalAdd + PERCENTFULLatAL;


%This loop goes through the domain and adjusts the cell height based on the
%newFullness, (Agg rate plus the amount of coarse and fine seidment deposited
%because of transport of sediment).

%Can this be changed to parfor?
for x=1:XMAX;
    for y=1:YMAX; 
        %If the cell, with the new material, is not overfilled or
        %underfilled
        if (newFullness(x,y) >= 0) &&(newFullness(x,y) <= 1);
            %The vol. amount of coarse material in the cell
            oldCoarse(x,y) = AREA.percentCoarse(x,y,z(x,y)) * PERCENTFULLatAL(x,y) * CVOLUME;
            %Find new percent coarse and reset the matrix
            AREA.percentCoarse(x,y,z(x,y)) = (CoarseAdd(x,y) + oldCoarse(x,y))/(newFullness(x,y) * CVOLUME);
            %If there is a negative amount of coarse material in the top
            %layer, this loop draws C. sed out of the next layer down.
            %connect this with AL? Limi to the level?
            
            
            if AREA.percentCoarse(x,y,z(x,y)) < 0
                %disp('PC<0')
                level=z(x,y);
                
                NotDone=1;
                while NotDone==1
                    AREA.percentCoarse(x,y,level-1) = AREA.percentCoarse(x,y,level-1)+(AREA.percentCoarse(x,y,level)*newFullness(x,y));
                    AREA.percentCoarse(x,y,level)=0;
                    level = level-1;
                    
                     if AREA.percentCoarse(x,y,level) < 0 && level>0;
                         NotDone=1;
                     else
                         NotDone=0;
                     end
                end
            
            elseif AREA.percentCoarse(x,y,z(x,y)) > 1
                %disp('PC>1')
                level=z(x,y);
                NotDone=1;
                while NotDone==1
                    AREA.percentCoarse(x,y,level-1) = AREA.percentCoarse(x,y,level-1)+ (((AREA.percentCoarse(x,y,level))-1)*newFullness(x,y));
                    AREA.percentCoarse(x,y,level)=1;
                    level = level-1;
                    if AREA.percentCoarse(x,y,level) > 1 && level>0;
                        NotDone=1;
                     else
                         NotDone=0;
                     end
                end
            end
            
            %Set the percent full to the new amount
            AREA.percentFull(x,y,z(x,y))=newFullness(x,y);
            
            
            
            %If the cell, with the new material, is overfilled
        elseif newFullness(x,y) > 1
            OVERFLOWED=true;
            while OVERFLOWED
                overflow = newFullness(x,y) - 1;            
            oldCoarse(x,y) = AREA.percentCoarse(x,y,z(x,y)) * PERCENTFULLatAL(x,y) * CVOLUME;
            %Find new percent coarse and reset the matrix
            AREA.percentCoarse(x,y,z(x,y)) = (CoarseAdd(x,y) + oldCoarse(x,y))/(newFullness(x,y) * CVOLUME);
            
            if AREA.percentCoarse(x,y,z(x,y)) < 0
                %disp('PC<0')
                level=z(x,y);
                NotDone=1;
                while NotDone==1
                    AREA.percentCoarse(x,y,level) < 0 && level>0;
                    AREA.percentCoarse(x,y,level-1) = AREA.percentCoarse(x,y,level-1)+(AREA.percentCoarse(x,y,level)*newFullness(x,y));
                    AREA.percentCoarse(x,y,level)=0;
                    level = level-1;
                    if AREA.percentCoarse(x,y,level) < 0 && level>0;
                        NotDone=1;
                     else
                         NotDone=0;
                     end
                end
            elseif AREA.percentCoarse(x,y,z(x,y)) > 1
                %disp('PC>1');
                %TotalAdd(x,y);
                level=z(x,y);
                NotDone=1;
                while NotDone==1
                    
                    AREA.percentCoarse(x,y,level-1) = AREA.percentCoarse(x,y,level-1)+ (((AREA.percentCoarse(x,y,level))-1)*newFullness(x,y));
                    AREA.percentCoarse(x,y,level)=1;
                    level = level-1;
                    if AREA.percentCoarse(x,y,level) > 1 && level>0;
                        NotDone=1;
                     else
                         NotDone=0;
                     end
                end
            end
            %Fill the cell up
            AREA.percentFull(x,y,z(x,y))=1;
            %And move the active layer up
            z(x,y) =  z(x,y)+1;
            %Now set the new top cell's percent full to the overflow amount
            AREA.percentFull(x,y,z(x,y)) = overflow;
            %Now set the new top cell's percent coarse to the identical value of the cell
            %below (assumes deposited material is well mixed)
            AREA.percentCoarse(x,y,z(x,y))  = AREA.percentCoarse(x,y,z(x,y)-1);

                if overflow>1
                OVERFLOWED=true;
                else
                    OVERFLOWED=false;
                end
            end
            if overflow>1
                error('still wrong')
            end
            
            
           %If the cell, with the new material, is underfilled 
        elseif (newFullness(x,y) < 0)
            UNDERFLOWED=true;
            while UNDERFLOWED
            underflow(x,y) = newFullness(x,y) + 1;
            UF=underflow(x,y);
            %Old coarse in underflow case is the average coarseness of top
            %2 cells
            oldCoarse(x,y) = (AREA.percentCoarse(x,y,z(x,y)) * PERCENTFULLatAL(x,y) * CVOLUME )+ (AREA.percentCoarse(x,y,z(x,y)-1)* CVOLUME );
            OC=oldCoarse(x,y);
            %Find new percent coarse and reset the matrix
            AREA.percentCoarse(x,y,z(x,y)) = (CoarseAdd(x,y)+ oldCoarse(x,y))/(underflow(x,y)* CVOLUME);
            %And move the active layer down
            z(x,y) =  z(x,y)-1;
            %Set the percent coarse in the new top Z to the identical
            %value of the cell above (previous active Z)
            AREA.percentCoarse(x,y,z(x,y))  = AREA.percentCoarse(x,y,z(x,y)+1);
            %Zero out the values for the PF and PC of the old activeZ cell
            AREA.percentFull(x,y,z(x,y)+1)=0;
            AREA.percentCoarse(x,y,z(x,y)+1)=0;
            %Set the %-full  in the new active Z to the underflow value
            AREA.percentFull(x,y,z(x,y))=underflow(x,y);
            if AREA.percentCoarse(x,y,z(x,y)) < 0
               
             
                %AREA.percentCoarse(x,y,z(x,y))
                %disp('PC<0')
                level=z(x,y);
                NotDone=1;
                while NotDone==1;
                    AREA.percentCoarse(x,y,level-1) =...
                        AREA.percentCoarse(x,y,level-1)+(AREA.percentCoarse(x,y,level)*underflow(x,y));
                    AREA.percentCoarse(x,y,level)=0;
                    level = level-1;
                    if AREA.percentCoarse(x,y,level) < 0 && level>0;
                        NotDone=1;
                     else
                         NotDone=0;
                     end
                        
                end
            elseif AREA.percentCoarse(x,y,z(x,y)) > 1
                %disp('PC>1')
                level=z(x,y);
                NotDone=1;
                while NotDone==1
                    AREA.percentCoarse(x,y,level-1) = AREA.percentCoarse(x,y,level-1)+ ((AREA.percentCoarse(x,y,level)-1)*underflow(x,y));
                    AREA.percentCoarse(x,y,level)=1;
                    level = level-1;
                    if AREA.percentCoarse(x,y,level) > 1 && level>0;
                        NotDone=1;
                     else
                         NotDone=0;
                     end
                end
            end 
               if underflow(x,y)<0
                UNDERFLOWED=true;
                else
                    UNDERFLOWED=false;
                end
            end
            if underflow(x,y)<0
                error('still wrong')
            end
            
            
        end
    end
end



%(Re)Set the active layer
AREA.activeZ=z;

%Find the percent full at the active layer and the Effective Percent Coarse
for ii=1:XMAX
    for jj=1:YMAX
        PERCENTFULL(ii,jj)=AREA.percentFull(ii,jj,z(ii,jj));
        PERCENTC(ii,jj)=AREA.percentCoarse(ii,jj,z(ii,jj));
        PERCENTCm1(ii,jj)=AREA.percentCoarse(ii,jj,z(ii,jj)-1);
        PERCENTCm2(ii,jj)=AREA.percentCoarse(ii,jj,z(ii,jj)-2);
        PERCENTCm3(ii,jj)=AREA.percentCoarse(ii,jj,z(ii,jj)-3);
    end
end

AREA.percentCoarse=AREA.percentCoarse;

%RESET THE PERCENT FULL AT AL
AREA.percentFullatAL=PERCENTFULL;

%RESET THE EFFECTIVE PERCENT COARSE
AREA.EffectivePercentCoarse = ((PERCENTFULL.*PERCENTC)+PERCENTCm1+PERCENTCm2+((1-PERCENTFULL).*PERCENTCm3))/3;


%EBG: Unflagging the below will CHANGE effective percent coarse to just be the top layer
%AREA.EffectivePercentCoarse =PERCENTC;


%Reset the amount added
AREA.fineVolumeAdded  = zeros(XMAX,YMAX);
AREA.coarseVolumeAdded= zeros(XMAX,YMAX);





        
 

end

