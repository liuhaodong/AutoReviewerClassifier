function test_example_MyNN
load mnist_uint8;

train_x = double(reshape(train_x',28, 4, 7, 60000))/255;
test_x = double(reshape(test_x',28, 4, 7,10000))/255;
train_y = double(train_y');
test_y = double(test_y');

train_x = train_x(:, :, :, 1:500);
train_y = train_y(:, 1:500);
test_x = test_x(:, :, :, 1:500);
test_y = test_y(:, 1:500);

%% ex1 Train a 6c-2s-12c-2s Convolutional neural network 
%will run 1 epoch in about 200 second and get around 11% error. 
%With 100 epochs you'll get around 1.2% error

rand('state',0)

cnn.layers = {
    struct('type', 'i', 'shape', [28, 4, 7]) %input layer
    struct('type', 'c', 'outputmaps', 6, 'kernelsize', [5, 2, 1], 'dropoutFraction', 0, 'func', 'sigmoid') %convolution layer
    struct('type', 's', 'scale', [2, 1, 1]) %sub sampling layer
    struct('type', 'c', 'outputmaps', 12, 'kernelsize', [5, 1, 3], 'dropoutFraction', 0, 'func', 'sigmoid') %convolution layer
    struct('type', 's', 'scale', [2, 1, 1]) %subsampling layer
    struct('type', 'h', 'size', 30, 'dropoutFraction', 0, 'func', 'sigmoid')
    struct('type', 'o', 'func', 'sigmoid')
};

opts.alpha = 0.05;
opts.batchsize = 50;
opts.numepochs = 300;
opts.momentum = 0.9;

cnn = mynnsetup(cnn, train_x, train_y);
cnn = mynntrain(cnn, train_x, train_y, opts);

[er, bad] = mynntest(cnn, test_x, test_y, opts);

%plot mean squared error
figure; plot(cnn.rL);
assert(er<0.12, 'Too big error');
