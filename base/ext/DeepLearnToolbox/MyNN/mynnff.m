function net = mynnff(net, x, opts)
    n = numel(net.layers);
    net.layers{1}.a{1} = x;
    if isfield(net.layers{1}, 'dropoutFraction') && (net.layers{1}.dropoutFraction > 0)
        if (opts.testing)
            net.layers{1}.a{1} = net.layers{1}.a{1}.*(1 - net.layers{1}.dropoutFraction);
        else
            dropOutMask = (rand(size(net.layers{1}.a{1}))>=net.layers{1}.dropoutFraction);
            net.layers{1}.a{1} = net.layers{1}.a{1}.*dropOutMask;
        end
    end
    inputmaps = 1;

    for l = 2 : n   %  for each layer
        if strcmp(net.layers{l}.type, 'c')
            %  !!below can probably be handled by insane matrix operations
            for j = 1 : net.layers{l}.outputmaps   %  for each output map
                %  create temp output map
                z = zeros(size(net.layers{l - 1}.a{1}) - [(net.layers{l}.kernelsize - 1) 0]);
                for i = 1 : inputmaps   %  for each input map
                    %  convolve with corresponding kernel and add to temp output map
                    z = z + convn(net.layers{l - 1}.a{i}, net.layers{l}.k{i}{j}, 'valid');
                end
                %  add bias, pass through nonlinearity
                net.layers{l}.a{j} = activationff(z + net.layers{l}.b{j}, net.layers{l}.func);
                %dropout
                if(net.layers{l}.dropoutFraction > 0)
                    if (opts.testing)
                        net.layers{l}.a{j} = net.layers{l}.a{j}.*(1 - net.layers{l}.dropoutFraction);
                    else
                        net.layers{l}.dropOutMask{j} = (rand(size(net.layers{l}.a{j}))>=net.layers{l}.dropoutFraction);
                        net.layers{l}.a{j} = net.layers{l}.a{j}.*net.layers{l}.dropOutMask{j};
                    end
                end
            end
            %  set number of input maps to this layers number of outputmaps
            inputmaps = net.layers{l}.outputmaps;
        elseif strcmp(net.layers{l}.type, 's')
            %  downsample
            for j = 1 : inputmaps
                z = convn(net.layers{l - 1}.a{j}, ones(net.layers{l}.scale) / prod(net.layers{l}.scale), 'valid');   %  !! replace with variable
                idxs = cell(1, length(net.layers{l}.scale) + 1);
                for k = 1:length(net.layers{l}.scale)
                    idxs{k} = 1 : net.layers{l}.scale(k) : size(z, k);
                end
                idxs{end} = 1:size(z, ndims(z));
                net.layers{l}.a{j} = z(idxs{:});
            end
        elseif strcmp(net.layers{l}.type, 'h') || strcmp(net.layers{l}.type, 'o')
            %z = ones(1, size(x, ndims(x)));
            %for j = 1 : inputmaps
            %    sa = size(net.layers{l - 1}.a{j});
            %    z = vertcat(z, reshape(net.layers{l - 1}.a{j}, prod(sa(1:end-1)), sa(end)));
            %end
            b = ones(1, size(x, ndims(x)));
            z = [];
            for i = 1 : numel(net.layers{l - 1}.a)
                sa = size(net.layers{l - 1}.a{i});
                z = vertcat(z, reshape(net.layers{l - 1}.a{i}, prod(sa(1:end-1)), sa(end)));
            end
            net.layers{l}.a{1} = activationff(net.layers{l}.W * vertcat(b, z), net.layers{l}.func);
            %dropout
            if isfield(net.layers{l}, 'dropoutFraction') && (net.layers{l}.dropoutFraction > 0)
                if (opts.testing)
                    net.layers{l}.a{1} = net.layers{l}.a{1}.*(1 - net.layers{l}.dropoutFraction);
                else
                    net.layers{l}.dropOutMask = (rand(size(net.layers{l}.a{1}))>=net.layers{l}.dropoutFraction);
                    net.layers{l}.a{1} = net.layers{l}.a{1}.*net.layers{l}.dropOutMask;
                end
            end
            if isfield(net.layers{l}, 'reconstruct') && net.layers{l}.reconstruct > 0
                net.layers{l}.reconstruct_a{1} = activationff(net.layers{l}.rW * vertcat(ones(1, size(x, ndims(x))), net.layers{l}.a{1}), net.layers{l}.func);
                net.layers{l}.reconstruct_y = z;
            end
            inputmaps = 1;
        end
    end

end