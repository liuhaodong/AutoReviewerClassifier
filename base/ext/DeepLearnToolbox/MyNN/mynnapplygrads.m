function net = mynnapplygrads(net, opts)
    for l = 2 : numel(net.layers)
        if strcmp(net.layers{l}.type, 'c')
            for j = 1 : numel(net.layers{l}.a)
                for ii = 1 : numel(net.layers{l - 1}.a)
                    if(opts.momentum>0)
                        net.layers{l}.vk{ii}{j} = opts.momentum*net.layers{l}.vk{ii}{j} + net.layers{l}.dk{ii}{j};
                        net.layers{l}.dk{ii}{j} = net.layers{l}.vk{ii}{j};
                    end
                    net.layers{l}.k{ii}{j} = net.layers{l}.k{ii}{j} - opts.alpha * net.layers{l}.dk{ii}{j};
                end
                net.layers{l}.b{j} = net.layers{l}.b{j} - opts.alpha * net.layers{l}.db{j};
            end
        end
        if strcmp(net.layers{l}.type, 'h') || strcmp(net.layers{l}.type, 'o')
            for j = 1 : numel(net.layers{l}.dW)
                if(opts.momentum>0  && strcmp(net.layers{l}.type, 'h'))
                    net.layers{l}.vW = opts.momentum*net.layers{l}.vW + net.layers{l}.dW{j};
                    net.layers{l}.dW{j} = net.layers{l}.vW;
                end
                net.layers{l}.W = net.layers{l}.W - opts.alpha * net.layers{l}.dW{j};
                if isfield(net.layers{l}, 'reconstruct') && net.layers{l}.reconstruct > 0
                    if(opts.momentum>0 && strcmp(net.layers{l}.type, 'h'))
                        net.layers{l}.vrW = opts.momentum * net.layers{l}.vrW + net.layers{l}.drW{j};
                        net.layers{l}.drW{j} = net.layers{l}.vrW;
                    end
                    net.layers{l}.rW = net.layers{l}.rW - opts.alpha * net.layers{l}.drW{j};
                end
            end
        end
    end

    %net.ffW = net.ffW - opts.alpha * net.dffW;
    %net.ffb = net.ffb - opts.alpha * net.dffb;
end
