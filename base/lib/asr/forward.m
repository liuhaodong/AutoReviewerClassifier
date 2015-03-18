function [log_p_o_given_lambda alpha eta] = forward(pi, a, b, o)

% init

M = length(b);
N = length(a);
T = length(o);

% alpha

alpha = zeros(N,T);
eta = ones(1,T);

eta(1) = 1 / sum(pi .* b(:,o(1)));
alpha(:,1) = eta(1) * (pi .* b(:,o(1)));
for t=1:T-1,
    eta(t+1)     = 1 / sum(    ( alpha(:,t)' * a ) .* b(:,o(t+1))' );
    alpha(:,t+1) = eta(t+1) .* ( alpha(:,t)' * a ) .* b(:,o(t+1))';
end

%p_o_given_lambda = sum(alpha(:,T));
%p_o_given_lambda = sum(alpha(:,T)) / prod(eta);
log_p_o_given_lambda = log(sum(alpha(:,T))) - sum(log(eta));
