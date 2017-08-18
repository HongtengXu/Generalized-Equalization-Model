%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Demo of generalized equalization model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all


for N=1:10
    
    Filename1=sprintf('%d.bmp',N);
    In=imread(Filename1);
    % d: always be 0, if d~=0, the user should have installed cvx
    % toolbox.
    d=0;
    n=2;
    p=Inf;
    q=0.25;

    tic;
    for i=1
        [out, C_ori,C_out, NL, Ratio]=GeneralizedEqu(In, 'RGB', n, q(i), p, d);
    end
    time=toc;

    Filename2=sprintf('enhance_%d_%dsec.png',N,ceil(time));
    imwrite(uint8(out),Filename2);
    
end

