function [ IntegratedConcy, IntegratedConcx,coeffcrit ] = IntegratedSSConcentration(XMAX,YMAX,Cref,zeta0,RippleHeight,W,AE,karman,hustar,ustar,vstar,uMagnitude,vMagnitude)
%INTEGRATEDSSCONCENTRATION Outputs the integrated Susspended sediment
%concentration above a vortex ripple
%   
%
%
%Copyright EBG: 
%Creative Commons 
%Attribution-NonCommercial-ShareAlike 
%3.0 Unported
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%I can likely make this faster by figuring out a good way to do most of the
%loops as matrix math. Such as making a matrix of height increments (from
%z0 to the top of Conc profile, multiplying the entire matrix by step size, 
%then element by element multiplying by current V, then summing over them 
%to get integrated Conc.  
%%%%%%%%%%%%%%%%%%%%

%This Loop computes the 2nd term (integration term)%in eqn 5 coco et al 2007: 
%the suspended sediment concentration profile, 
%multiplied by the vertical velocity profile and dz.
stepbl=0.01;       %This is dz, the vertical step length

%GC: velocity profile inside the boundary layer (Fredsoe and Deigaard, p. 59-60,
%deltabl from eq.2.45(p.25)) we are adapting eq.2.45 to account for the presence of
%ripples (use of kn) concentration profile (Nielsen p. 258; Fredsoe and Deigaard p
%.305 and eq.10.24 for diffusivity ) we are assuming the current doesn't affect concentration
%profile and only advects sediment we are neglecting the flux contribution to sediment fluxes
%below the ripple crest because:
%1) we have no idea of the flow in there
%2) we assume that contribution is included in the bedload prediction


%Zero out the variables that compute the concentration profile.
qoblu=zeros(XMAX,YMAX);
qoblv=zeros(XMAX,YMAX);



%Reset the coeffient which can shut off Bl if Modified shields
%is less than shields crit.
coeffcrit=ones(XMAX,YMAX);




%First fine sediment 
parfor i=1:XMAX
    for j=1:YMAX
        if Cref(i,j)>0.0
            zeta=RippleHeight(i,j);%integration starts at ripple crest for fine
            %GC: outside the boundary layer Fredsoe and Deigaard, p. 60-61
            zeta1=1.0*RippleHeight(i,j); %integration starts at ripple crest
            %FOR FINE SED
            Czobl= Cref(i,j);
            while (Czobl>0.000003)      %Threshold for upper limit of Cs. Neglect above this.
                %Concentration fo suspended sediment @ specific z;
                %EQN 8 from Coco et al 2007a. zeta-zeta1 term is
                %present to make sure we start at reference
                %concentration (exp(0)=1 therefore Czobl=Cref.
                Czobl = Cref(i,j)*exp(-W*(zeta-zeta1)/AE(i,j));
                if (zeta<hustar) %below hustar so log current profile
                    Uobl = (1/karman)*ustar(i,j)*log(zeta/(zeta0(i,j)));
                    Vobl = (1/karman)*vstar(i,j)*log(zeta/(zeta0(i,j)));
                else % above hustar so current is constant
                    Uobl = uMagnitude;
                    Vobl = vMagnitude;
                end
                %Add the product of the concentration at this level (Czobl)
                % and the current velocity (Uobl and Vobl) to the previous
                %count (qoblu and qoblv). stepbl is multiplied because
                %this is the size of the vertical steps.
                qoblu(i,j)=qoblu(i,j)+(Czobl*Uobl*stepbl);
                qoblv(i,j)=qoblv(i,j)+(Czobl*Vobl*stepbl);
                %Step to the next elevation
                zeta=zeta+stepbl;
            end
       else
            %If (Cref) > 0, then the modified shields was less than
            %the critical shields, so no sediment motion. When this
            %coefficient=0 it shuts off the BL and SL out of the cell.
            qoblu(i,j)=0.0;
            qoblv(i,j)=0.0; 
            coeffcrit(i,j)=0; 
        end
    end
end


%This if the total integrated product.
IntegratedConcx=qoblu;      
IntegratedConcy=qoblv;
            

end

