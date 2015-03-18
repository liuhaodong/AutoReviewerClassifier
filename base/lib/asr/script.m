clear all;

% topology

% Roni's slide dataset
pi = [1; 0];
a = [0.6 0.4; 0.0 1.0];
b = [0.8 0.2; 0.3 0.7];
o = [1 1 2];

a
b

% baum_welch

summary = [];
i = 0;
while i <= 2 || summary(i) - summary(i-1) > 1e-6,
%while i <= 321 - 1,
    [log_p_o_given_lambda alpha eta] = forward(pi, a, b, o);
    [log_p_o_given_lambda2 beta] = backward(pi, a, b, o, alpha, eta);
    [pi_ a_ b_ xi gamma] = baum_welch(pi, a, b, o, alpha, beta, eta, log_p_o_given_lambda);

    %pi = pi_
    a = a_;
    b = b_;

    summary = [summary; log_p_o_given_lambda];
    i = i + 1;
end

a_
b_
[summary exp(summary)]
num_iterations = length(summary)
avg_ll = mean(summary)

% viterbi

[q_ delta phi] = viterbi(pi, a, b, o);
