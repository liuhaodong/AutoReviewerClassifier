function net = mynntrain(net, x, y, opts)
    opts.testing = 0;
    m = size(x, ndims(x));
    %sx = [net.layers{1}.shape m];
    %x = reshape(x, sx);
    numbatches = m / opts.batchsize;
    if rem(numbatches, 1) ~= 0
        error('numbatches not integer');
    end
    net.rL = [];
    for i = 1 : opts.numepochs
        kk = randperm(m);
        for l = 1 : numbatches
            idxs = cell(1, ndims(x));
            for k = 1:(length(idxs) - 1)
                idxs{k} = 1 : size(x, k);
            end
            idxs{ndims(x)} = kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize);
            batch_x = x(idxs{:});
            
            idxs = cell(1, ndims(y));
            for k = 1:(length(idxs) - 1)
                idxs{k} = 1 : size(y, k);
            end
            idxs{ndims(y)} = kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize);
            batch_y = y(idxs{:});
            sy = size(batch_y);
            batch_y = reshape(batch_y, prod(sy(1:end-1)), size(batch_y, ndims(batch_y)));

            net = mynnff(net, batch_x, opts);
            net = mynnbp(net, batch_y, opts);
            net = mynnapplygrads(net, opts);
            if isempty(net.rL)
                net.rL(1) = net.L;
            end
            net.rL(end + 1) = 0.99 * net.rL(end) + 0.01 * net.L;
        end
    end
    
end
