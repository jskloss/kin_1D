function [u,keff]=steady_state_eigenproblem(curr_time)

global dat
[M,P]=assemble_steady_state_operator(curr_time);

M=apply_BC_mat_only(M,false);
P=apply_BC_mat_only(P,true);

% % kold=1;uold=rand(length(M),1);
% % uold=uold/norm(uold,2);
% % 
% % max_it=10000;
% % for it=1:max_it
% %     src=P*uold;
% %     plot(src)
% %     unew=M\src;
% %     k=norm(unew,2);
% %     err_k=abs(kold-k);
% %     err_v=norm(uold-unew/k);
% %     fprintf('it =%d, keff=%g \t err=%g \t err=%g\n',it,k,err_k,err_v);
% %     kold=k;
% %     uold=unew/k;
% %     if(err_v<1e-7 && err_k<1e-8)
% %         break
% %     end
% %     if(it==max_it)
% %         warning('convergence has not been reached');
% %     end
% % end

opts.disp=0;
[u,keff]=eigs(P,M,1,'lm',opts);

dat.keff=keff;

if sum(u)<0
    u=-u;
end

return
end