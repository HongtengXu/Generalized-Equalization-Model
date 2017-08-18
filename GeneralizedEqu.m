function [out, C_ori,C_out, NL, Ratio]=GeneralizedEqu(in, mode, n, q, p, d)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The function achieve the Generalized Equalization Model (GEM) for Image
% Enhancement, which is the work in
% Hongteng Xu, Guangtao Zhai, Xiaokang Yang.
% "Generalized Equalization Model for Image Enhancement", Trans. on Multimedia, IEEE
%
% in: input image, which should be uint8 image.
% mode: "RGB": use GEM to three channels, "HSV": use GEM to Intensity
% Channel.
% n: 2: L2 norm, 3: L\infty norm
% q: Controlling the strength of enhancement. When n=2, q is recommended as
% 0.2-0.35. When n=3, q is recommended as 0.4-0.7
% p: The choice of White Balance Method. 1: GrayWorld, p: p-norm, Inf:
% MaxRGB.
% d: the contraint of GEM, when d=0, GEM has a fast solution. If d~=0, the
% user should have cvx toolbox.
%
% out: enhanced image
% Gain: The gain of contrast: Gain=P*S^T/P_ori*S_ori^T
% NL: the nonlinearity of transform: NL=norm(\nabla(S-S_ori))
% Ratio: NL/Gain.
%
% Copyright (c) 2012 Shanghai Jiaotong University
% This work should only be used for research.
%
% AUTHORS:
%     Hongteng Xu, email: hxu42@gatech.edu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(mode, 'RGB')
    tic;
    
    
    Level=size(in,3);
    P=cell(Level,1);
    X=cell(Level,1);
    for i=1:Level
        tmp=in(:,:,i);
        [P{i},X{i}]=imhist(in(:,:,i));
        P{i}=P{i}./sum(P{i});
        
        
        if p~=inf
            L(i)=sum( P{i}.*( X{i}.^p ) ).^(1/p);
        else
            index=find(P{i}~=0);
            tmp=X{i};
            L(i)=tmp(index(end));
        end
    end
    
    for i=1:Level
        index=find(P{i}~=0);
        tmp=X{i};
        L(i)=tmp(index(end))./( sqrt(3)*( L(i)./norm(L,2) ) );
           
    end
    L=255.*L./max(L);
    for i=1:Level
        [out(:,:,i),C_ori(i),C_out(i),NL(i)]=GEM_enhance(in(:,:,i), q, n, L(i), d);
    end
    Ratio=(NL.^25)./abs((C_out/C_ori)-1);
    
    toc;
end

if strcmp(mode, 'HSV')
    tic;
    
    in=rgb2hsv(in);
    
    tmp=uint8(255.*in(:,:,3));
 
    [out,C_ori,C_out,NL]=GEM_enhance(tmp, q, n, 255, d);
    Ratio=(NL^25)/abs((C_out/C_ori)-1);
    in(:,:,3)=out./255;
    out=255.*hsv2rgb(in);
    toc;
end
    
    
    
    
    
