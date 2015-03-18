function best_nn = deeptrain(x, y, params)
net.layers = {
    struct('type', 'i', 'shape', [size(x, 2), 1], 'dropoutFraction', 0.0)
    struct('type', 'h', 'size', 200, 'dropoutFraction', 0.5, 'func', 'rectifier')
    struct('type', 'h', 'size', 200, 'dropoutFraction', 0.5, 'func', 'rectifier')
    struct('type', 'o', 'func', 'sigmoid')
};
nn = mynnsetup(net, length(unique(y)));

opts.numepochs = 1;
opts.batchsize = params.batchsize;
opts.alpha = params.alpha;
opts.momentum = params.momentum;
numepochs = params.numepochs;

test_i = randsample(1:length(y), floor(length(y) * params.dev_size));
test_i = ismember(1:length(y), test_i);
train_i = ~test_i;

train_x = x(train_i, :);
train_y = y(train_i, :);
test_x = x(test_i, :);
test_y = y(test_i, :);
[train_x, train_y] = vector_to_deep(train_x, train_y);
[test_x, test_y] = vector_to_deep(test_x, test_y, numel(unique(y)));

train_x = train_x(1:floor(size(train_x, 1) / opts.batchsize) * opts.batchsize, :);
train_y = train_y(1:size(train_x, 1), :);

train_x = train_x';
train_y = train_y';
test_x = test_x';
test_y = test_y';

best_err = 1;
best_nn = nn;
train_errors = zeros(1, numepochs);
errors = zeros(1, numepochs);

for i = 1:numepochs
    nn = mynntrain(nn, train_x, train_y, opts);
    [train_err, ~] = mynntest(nn, train_x, train_y, opts);
    [err, ~] = mynntest(nn, test_x, test_y, opts);
    train_errors(i) = train_err;
    errors(i) = err;
    windowed_error = mean(train_errors(max(1, i - params.error_window):i));
    if (windowed_error < best_err)
        best_nn = nn;
        best_err = windowed_error;
    end
end

figure(1);
plot(1:length(errors), errors, 1:length(train_errors), train_errors);
legend('test error','train error');
end