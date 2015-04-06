%This code was developed to display data generated from the MATLAB version
%of the Sorted Bedform Code, specifically data from 'AREA.000X' files

%This code is used to generate movies of map view concentrations in the transect from 
%bottom left to top right corner of the map view display, a la the Murray
% and Thieler as well as the Coco et al. papers. The movies are entitled
% 'Map X' where X is a number refering to II (the loop iteration
% described below'. The movies are exported as avi files and can be viewed
% in quicktime 7 or real player. They can be stitched together in one of
% these programs tomake movies for the entire model run.

%The current configuration of this code runs from raw 'save.000' 
%files, not a previously saved set of variables, and will generate a movie 
%file. This code had no size
%restriction, but the student version of matlab can only handle an
%multidimensional array ('S' in this case)at the size set, so the process 
%will loop through all of the data, no matter how many outputs
%are saved, in incrememnts of 100 saved files. So, for instance if you have
%2000 saved output files to 
%process, the 'saved' variable should be set to 100 (the maximum allowed) 
%and II should be set from 1:20 (20 loops, each 100 output files long is
%2000 total output files). 

%'II' and 'Saved' are the only two variables that require manual adjusting
%Coding by EBG 2/2011
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    


close all
clear all


saved=100;

    S=zeros(100,100,6);
    for i=1:saved;
        k=i;
        if k<=9;
            AREA=importdata(['AREA000' num2str(k) '.mat']);
            S(:,:,i)=AREA.EffectivePercentCoarse;
        end
        if k>9;
            if k<100;
               AREA=importdata(['AREA00' num2str(k) '.mat']);
                S(:,:,i)=AREA.EffectivePercentCoarse;
            else
                if k<1000
                    AREA=importdata(['AREA0' num2str(k) '.mat']);
                    S(:,:,i)=AREA.EffectivePercentCoarse;
                else
                    AREA=importdata(['AREA' num2str(k) '.mat']);
                    S(:,:,i)=AREA.EffectivePercentCoarse;
                end
            end
        end
    end
    
    clear start
    clear i
    clear k
    
   s=S;

for j=1:saved;
    p=s(:,:,j);
    pcolor(p)
    xlabel('Position (m)')
    ylabel('Position (m)')
    axis([1 100 1 100]) 
    set(gca,'XTickLabel',{'100','200','300','400','500'})
    set(gca,'YTickLabel',{'50','100','150','200','250','300','350','400','450','500'})
    colorbar
    colormap(gray)
    caxis([0 1])
    shading flat
    M(j) = getframe;
end
movie(M)
movie2avi(M,['HybridMap'])

    clear p
    clear j
    clear M
    clear s
