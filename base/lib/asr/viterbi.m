function [q_ delta phi] = viterbi(pi, a, b, o)

% init

M = length(b);
N = length(a);
T = length(o);

% delta & phi

delta = zeros(N,T);
phi = zeros(N,T);

delta(:,1) = pi .* b(:,o(1));
for t=1:T-1,
    [Y I] = max( ( delta(:,t) * ones(1,N) ) .* a );
    delta(:,t+1) = Y .* b(:,o(t+1))';
    phi(:,t+1) = I;
end

q_ = ones(1,T);

[temp q_(T)] = max(delta(:,T));
for i=T-1:-1:1,
    q_(i) = phi(q_(i+1),i+1);
end
