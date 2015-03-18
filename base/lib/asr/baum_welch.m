function [pi_ a_ b_ xi gamma] = baum_welch(pi, a, b, o, alpha, beta, eta, log_p_o_given_lambda)

% init

M = length(b);
N = length(a);
T = length(o);

% xi

xi = zeros(N,N,T-1);
for t=1:T-1,
    alpha_mask = alpha(:,t) * ones(1,N);
    b_beta_mask = ones(N,1) * ( b(:,o(t+1)) .* beta(:,t+1) )';
    xi(:,:,t) = alpha_mask .* a .* b_beta_mask .* eta(t+1) ./ log_p_o_given_lambda;
end

% gamma

gamma = zeros(N,T);
for t=1:T,
%gamma = zeros(N,T-1);
%for t=1:T-1,
    gamma(:,t) = alpha(:,t) .* beta(:,t) ./ log_p_o_given_lambda;
end

% pi'

pi_ = gamma(:,1);

% a'

s = sum(xi,3);
a_ = s ./ ( sum(s,2) * ones(1,N) );

% b'

for k=1:M
    i = (o==k);
    %i = ( o(1:T-1) == k );
    b_(:,k) = sum(gamma(:,i),2) ./ sum(gamma,2);
end
