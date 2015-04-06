%This code was developed to display data generated from the MATLAB version
%of the Sorted Bedform Code, specifically data from 'AREA.000X' files

%This code is used to generate movies of profiles in the transect from
%bottom left to top right corner of the map view display, a la the Murray
% and Thieler as well as the Coco et al. papers. The movies are entitled
% 'Profile X' where X is a number refering to II (the loop iteration
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
%matlabpool open

saved=100;

S=zeros(100,100,saved);
for i=1:saved;
    k=i;
    if k<=9;
        AREA=importdata(['AREA000' num2str(k) '.mat']);
        PC=AREA.percentCoarse;
        PF=AREA.percentFull;
        parfor j=1:100;
            XsectionPC(j,:)=diag(PC(:,:,j));
            XsectionPF(j,:)=diag(PF(:,:,j));
        end
        XsectionPF(XsectionPF==0)=NaN;
        XsectionPF(XsectionPF>0)=1;
        Xsection=XsectionPF.*XsectionPC;
        S(:,:,i)=Xsection;
    end
    if k>9;
        if k<100;
            AREA=importdata(['AREA00' num2str(k) '.mat']);
            PC=AREA.percentCoarse;
            PF=AREA.percentFull;
            parfor j=1:100;
                XsectionPC(j,:)=diag(PC(:,:,j));
                XsectionPF(j,:)=diag(PF(:,:,j));
            end
            XsectionPF(XsectionPF==0)=NaN;
            XsectionPF(XsectionPF>0)=1;
            Xsection=XsectionPF.*XsectionPC;
            S(:,:,i)=Xsection;
        else
            if k<1000
                AREA=importdata(['AREA0' num2str(k) '.mat']);
                PC=AREA.percentCoarse;
                PF=AREA.percentFull;
                parfor j=1:100;
                    XsectionPC(j,:)=diag(PC(:,:,j));
                    XsectionPF(j,:)=diag(PF(:,:,j));
                end
                XsectionPF(XsectionPF==0)=NaN;
                XsectionPF(XsectionPF>0)=1;
                Xsection=XsectionPF.*XsectionPC;
                S(:,:,i)=Xsection;
            else
                AREA=importdata(['AREA' num2str(k) '.mat']);
                PC=AREA.percentCoarse;
                PF=AREA.percentFull;
                parfor j=1:100;
                    XsectionPC(j,:)=diag(PC(:,:,j));
                    XsectionPF(j,:)=diag(PF(:,:,j));
                end
                XsectionPF(XsectionPF==0)=NaN;
                XsectionPF(XsectionPF>0)=1;
                Xsection=XsectionPF.*XsectionPC;
                S(:,:,i)=Xsection;
            end
        end
    end
end

clear start
clear i
clear k
%
% profilet=zeros(100,100,saved);
%
%
% %This Loop pulls out the cells that are used to create the transect
% %from the lower left corner of the map to the upper right, and also
% %transposes the data for better display
%
% for n=0:99;
%     profilet(:,n+1,:)=S((301+(101*n)),:,:);
%
% end
% clear n
% clear S

for jj=1:saved;
    %j
    ps=S(:,:,jj);
    pcolor(ps)
    colorbar
    colormap(gray)
    axis([1 100 30 70])
    %set(gca,'XTickLabel',{'141','282','423','564','707'})
    %set(gca,'YTickLabel',{'50','100','150','200','250','300','350','400','450','500'})
    shading flat
    caxis([0 1.2])
    MM(jj) = getframe;
end
movie(MM)
movie2avi(MM,['Profile'])

