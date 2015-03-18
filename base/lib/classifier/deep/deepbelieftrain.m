function nn = deepbelieftrain(x, y, params)

% unfold dbn
dbn = params.pretrained_classifier;
num_classes = length(unique(y));
nn = dbnunfoldtonn(dbn, num_classes);
nn.activation_function = 'sigm';

% create train & dev sets
dev_size = params.autotrain.dev_size;
classes = unique(y);
dev_x = zeros(0, size(x, 2));
dev_y = zeros(0, size(y, 2));
train_x = zeros(0, size(x, 2));
train_y = zeros(0, size(y, 2));
for c = 1:length(classes)
    class = classes(c);
    c_I = find(y == class);
    c_I = c_I(randperm(length(c_I)));
    cut_off = floor(length(c_I) * dev_size);
    dev_I = c_I(1:cut_off);
    train_I = c_I(cut_off + 1:end);
    dev_y = vertcat(dev_y, y(dev_I, :));
    dev_x = vertcat(dev_x, x(dev_I, :));
    train_y = vertcat(train_y, y(train_I, :));
    train_x = vertcat(train_x, x(train_I, :));
end

% train nn
opts = params.opts;
[train_x, train_y] = vector_to_deep(train_x, train_y);
[dev_x, dev_y] = vector_to_deep(dev_x, dev_y);
train_x = train_x(1:floor(size(train_x, 1) / opts.batchsize) * opts.batchsize, :);
train_y = train_y(1:size(train_x, 1), :);

auto_init = params.autotrain.init;
auto_stop = params.autotrain.stop;
auto_step = params.autotrain.step;
opts.numepochs = auto_step.numepochs;
opts.alpha = auto_init.alpha;
opts.momentum = auto_init.momentum;
old_err = 1;
runs = 0;
oldnn = nn;
while opts.momentum > auto_stop.momentum && opts.alpha > auto_stop.alpha
    nn = nntrain(nn, train_x, train_y, opts);
    runs = runs + opts.numepochs;
    [err, bad] = nntest(nn, dev_x, dev_y);
    if err < old_err
        old_err = err;
        oldnn = nn;
    else
        opts.alpha = opts.alpha * auto_step.alpha;
        opts.momentum = opts.momentum * auto_step.momentum;
    end
end

nn = oldnn;

end