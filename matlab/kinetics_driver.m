function kinetics_driver

clear all;
close all; clc;
global dat npar

npar.set_bc_last=true;

% select problem
pbID=3; refinements=30;
problem_init(pbID,refinements);

% compute eigenmode
curr_time=0;
[phi,keff]=steady_state_eigenproblem(curr_time);
plot(npar.x_dofs,phi)
fprintf('%10.8g \n',keff);


% hold all
% [phi1,keff1]=steady_state_eigenproblem(1);
% plot(dat.x_dofs,phi1)
%
% [phi2,keff2]=steady_state_eigenproblem(3);
% plot(dat.x_dofs,phi2)
%
% [keff keff1 keff2]'

C=kinetics_init(phi,curr_time);
% npar.K0
% npar.Pnorm
u=[phi;C]; u0=u;

dt=0.01;
Pnorm=npar.Pnorm;
ntimes=150;

for it=1:ntimes
    time_end=it*dt;
    fprintf('time end = %g \n',time_end);
    
    TR = assemble_transient_operator(time_end);
    
    %     load tr.mat
    %     M=A+D;
    %     M(end,end)=1;
    %     M(1,1)=1;
    %     P=NFId+NFIp;
    %     eigs(P,M,1,'lm');
    %     [uu,kk]=eigs(P,M,1,'lm');
    %     if(sum(uu)<0), uu=-uu; end
    %     flux=uu;
    %     prec=u0(npar.n+1:end);
    %     [ L*prec (NFIp-A)*flux]
    
    M = assemble_time_dependent_operator(time_end);
    
    %     load tr2.mat;
    
    % M(unew-uold)/dt=TR.unew
    rhs = M*u;
    A = M-dt*TR;
    if npar.set_bc_last
        [A,rhs]=apply_BC(A,rhs,npar.add_ones_on_diagonal);
    else
        rhs=apply_BC_vec_only(rhs);
    end
    u = A\rhs;
    plot(npar.x_dofs,u(1:npar.n));drawnow
    
    POW = assemble_load(dat.nusigf,time_end);
    Pnorm(it+1)=dot(POW,u(1:npar.n));
    
    
end

figure(2);
plot(Pnorm/Pnorm(1),'+-')

a=Pnorm/Pnorm(1)-1;
min(a)
max(a)

% [u(npar.n+1) C(1)]
% [u(end) C(end)]
% [u(npar.n+1:end)./C-1]
%  

shape=u0(1:npar.n);
C=u0(npar.n+1:end);
[rho_MGT,beff_MGT,prec]=compute_prke_parameters(curr_time,shape,C)
X=[1;prec];
Pnorm_prke(1)=X(1);

for it=1:ntimes
    time_end=it*dt;
    fprintf('time end = %g \n',time_end);
    [rho_MGT,beff_MGT,prec]=compute_prke_parameters(time_end,shape,C);
    A=[(rho_MGT-beff_MGT) dat.lambda ; ...
        beff_MGT         -dat.lambda];
    X=(eye(2)-dt*A)\X;
    Pnorm_prke(it+1)=X(1);
    
end
hold all
plot(Pnorm_prke,'ro-')

        

return
end