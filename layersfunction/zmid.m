function [ O,  O2 ] = zmid(m, n, I1, I2, weights, M2, d1, d2)
%% Nonlinear transform layer

if nargin == 5
   %% Compute z-update
   % I1 = x^k
   % I2 = u^{k-1}
   
   % real
   z = zeros(m+n,1);
   z(1:n) = shrinkage(I1(1:n) + I2(1:n), weights(1));
   z(n+1:m+n) = shrinkage(I1(n+1:m+n) + I2(n+1:m+n), weights(2));
   O = z;
   
%    % complex
%    N = length(I1);
%    I1C = I1(1:N/2) + 1j*I1(N/2+1:N);
%    I2C = I2(1:N/2) + 1j*I2(N/2+1:N);
%    z(1:n) = shrinkage(I1C(1:n) + I2C(1:n), weights(1)/Rho);
%    z(n+1:m+n) = shrinkage(I1C(n+1:m+n) + I2C(n+1:m+n), weights(2)/Rho);
%    O = [real(z);imag(z)];

end


if nargin == 8
    %% Compute dE/dz
    
    
    dEdu = d1;
    dEdx = d2;
    
    dudz = -1;
    % dxdz =  eye(m+n)/Rho - AULA/Rho^2;
    dxdz = reshape(M2,[m+n,m+n]);
    dEdz = dEdu.*dudz + transpose(transpose(dEdx)*dxdz);
    
    O = dEdz;
    
    %% Compute dE/dlambda
    
    % I1 = x^k
    % I2 = u^{k-1}

    dzdlambda1 = shrinkage_derivative_kappa(I1(1:n) + I2(1:n), weights(1));
    dzdlambda2 = shrinkage_derivative_kappa(I1(n+1:m+n) + I2(n+1:m+n), weights(2));
    dEdlambda1 = dEdz(1:n)'*dzdlambda1;
    dEdlambda2 = dEdz(n+1:n+m)'*dzdlambda2;
    
    O2 = [dEdlambda1 ; dEdlambda2];

end
end
