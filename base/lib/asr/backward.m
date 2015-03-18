function [log_p_o_given_lambda beta] = backward(pi, a, b, o, alpha, eta)

% init

M = length(b);
N = length(a);
T = length(o);

% beta

beta = zeros(N,T);

beta(:,T) = ones(N,1);
for t=T-1:-1:1,
    beta(:,t) = eta(t+1) .* ( a * ( b(:,o(t+1)) .* beta(:,t+1) ) );
end

log_p_o_given_lambda = log(alpha(:,1)' * beta(:,1)) - sum(log(eta));
