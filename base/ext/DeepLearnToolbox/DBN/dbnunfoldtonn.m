function nn = dbnunfoldtonn(dbn, outputsize, opt)
%DBNUNFOLDTONN Unfolds a DBN to a NN
%   dbnunfoldtonn(dbn, outputsize ) returns the unfolded dbn with a final
%   layer of size outputsize added.
    if(exist('outputsize','var'))
        size = [dbn.sizes outputsize];
    else
        size = [dbn.sizes];
    end
    
    layers = {
        struct('type', 'i', 'shape', [1, size(1)], 'dropoutFraction', 0.2)
    };
    for s = 2:length(size) - 1
        layers{end+1} = struct('type', 'h', 'size', size(s), 'dropoutFraction', 0.4, 'func', 'sigmoid', 'autoencodable', 1);    
    end
    layers{end+1} = struct('type', 'o', 'func', 'sigmoid');
    net.layers = layers;
    nn = mynnsetup(net, outputsize);
    for i = 1 : numel(dbn.rbm)
        nn.layers{i+1}.W = [dbn.rbm{i}.c dbn.rbm{i}.W];
    end
end