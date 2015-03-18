function [er, scores] = mynntest(net, x, y, opts)
    %  feedforward
    opts.testing = 1;
    net = mynnff(net, x, opts);
    scores = net.layers{end}.a{1};
    [~, h] = max(scores);
    [~, a] = max(y);
    bad = find(h ~= a);

    er = numel(bad) / size(y, 2);
end
