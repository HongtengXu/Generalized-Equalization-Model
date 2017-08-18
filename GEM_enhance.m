function [out,C_ori,C_out,NL]=GEM_enhance(in, q, n, L, d)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The joint tone adjustment and contrast enhancement based on Generalized
% Equalization Model.
%
% in: input image
% q: the order of P
% n: the norm of ||S/P^q||_n, always be 2 or inf.
% L: the max intensity, sometimes larger than 255
% d: the min s, always be 0, if d~=0, the user should have installed cvx
% toolbox.
%
% out: output image
% Gain: The gain of contrast: Gain=P*S^T/P_ori*S_ori^T
% NL: the nonlinearity of transform: NL=norm(\nabla(S-S_ori))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=double(in);




[p_k, x_k]=imhist(uint8(in), 256);
x_k=x_k(p_k>0);
P=p_k(p_k>0);
P=P./sum(P);

s_ori=[x_k(1);x_k(2:end)-x_k(1:end-1)];
C_ori=P'*s_ori;
    
dim=length(x_k);
Nabla=[eye(dim-1),zeros(dim-1,1)]-[zeros(dim-1,1),eye(dim-1)];

% solve min ||S/P^q||_n
if d==0
    if n==2
        S=L.*( P.^(2*q) )./sum( P.^(2*q) );
    else if n==3
            S=L.*( P.^(q) )./sum( P.^(q) );
        else if n==1
                if q==0
                    S=L.*( P.^(q) )./sum( P.^(q) );
                else
                    S=zeros(size(P));
                    S(P==max(P))=L;
                end
            end
        end

    end
else
    
    cvx_begin
        variable s(dim)
        minimize( norm( ( (P).^(-q)).*(s) , n) )
        subject to
            sum(s)==L;
            s>=d;

    cvx_end
    S=s;
end

C_out=sum(P.*S);
NL=norm(Nabla*((S-s_ori)));

% mapping new histogram to out
for i=1:length(P)
    
        T=sum(S(1:i));
    
    out( in==x_k(i) )=T;
end


