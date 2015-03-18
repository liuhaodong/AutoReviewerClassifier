function [h, a, a2] = mynnpredict(net, x, opts)
    %  feedforward
    opts.testing = 1;
    net = mynnff(net, x, opts);
    a = net.layers{end}.a{1};
    a2 = net.layers{end - 1}.a{1};
    [~, h] = max(a);
end
