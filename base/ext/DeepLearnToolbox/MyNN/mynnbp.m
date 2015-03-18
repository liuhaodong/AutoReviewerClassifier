function net = mynnbp(net, y, opts)
    n = numel(net.layers);
    m = size(net.layers{end}.a{1}, ndims(net.layers{end}.a{1}));
    %   error
    net.layers{end}.d{1} = net.layers{end}.a{1} - y;
    %  loss function
    net.L = 1/2* sum(net.layers{end}.d{1}(:) .^ 2) / m;

    %%  backprop deltas
    %net.fvd = (net.ffW' * net.od);              %  feature vector delta
    %if strcmp(net.layers{n}.type, 'c') || strcmp(net.layers{n}.type, 'h')         %  only conv layers has sigm function
    %    net.fvd = net.fvd .* (net.fv .* (1 - net.fv));
    %end

    %  reshape feature vector deltas into output map style
    %sa = size(net.layers{n}.a{1});
    %fvnum = prod(sa(1 : end - 1));
    %for j = 1 : numel(net.layers{n}.a)
    %    net.layers{n}.d{j} = reshape(net.fvd(((j - 1) * fvnum + 1) : j * fvnum, :), sa);
    %end

    for l = n : -1 : 2
        if strcmp(net.layers{l}.type, 'h') || strcmp(net.layers{l}.type, 'o')
            for j = 1 : numel(net.layers{l}.a)
                if isfield(net.layers{l}, 'reconstruct') && net.layers{l}.reconstruct > 0
                    reconstruction_error = (net.layers{l}.reconstruct_a{1} - net.layers{l}.reconstruct_y);
                    net.layers{l}.reconstruct_d{j} = reconstruction_error .* activationbp(net.layers{l}.reconstruct_a{j}, net.layers{l}.func);
                    rec_d = (net.layers{l}.rW' * net.layers{l}.reconstruct_d{j});
                    net.layers{l}.d{j} = max(0, 1 - net.layers{l}.reconstruct) * net.layers{l}.d{j} + net.layers{l}.reconstruct * rec_d(2:end, :);
                end
                net.layers{l}.d{j} = net.layers{l}.d{j} .* activationbp(net.layers{l}.a{j}, net.layers{l}.func);
                if(isfield(net.layers{l}, 'dropoutFraction') && net.layers{l}.dropoutFraction>0)
                    net.layers{l}.d{j} = net.layers{l}.d{j} .* net.layers{l}.dropOutMask;
                end
                sa = size(net.layers{l - 1}.a{j});
                fvd = (net.layers{l}.W' * net.layers{l}.d{j});
                fvnum = prod(sa(1 : end - 1));
                for i = 1 : numel(net.layers{l - 1}.a)
                    net.layers{l - 1}.d{i} = reshape(fvd(((i - 1) * fvnum + 2) : i * fvnum + 1, :), sa);
                end
            end
        elseif strcmp(net.layers{l}.type, 'c')
            for j = 1 : numel(net.layers{l}.a)
                net.layers{l}.d{j} = net.layers{l}.d{j} .* activationbp(net.layers{l}.a{j}, net.layers{l}.func);
                if(net.layers{l}.dropoutFraction>0)
                    net.layers{l}.d{j} = net.layers{l}.d{j} .* net.layers{l}.dropOutMask{j};
                end
            end
            for i = 1 : numel(net.layers{l - 1}.a)
                z = zeros(size(net.layers{l - 1}.a{1}));
                for j = 1 : numel(net.layers{l}.a)
                     z = z + convn(net.layers{l}.d{j}, rot180(net.layers{l}.k{i}{j}), 'full');
                end
                net.layers{l - 1}.d{i} = z;
            end
        elseif strcmp(net.layers{l}.type, 's')
            for j = 1 : numel(net.layers{l}.a)
                net.layers{l - 1}.d{j} = (expand(net.layers{l}.d{j}, [net.layers{l}.scale 1]) / prod(net.layers{l}.scale));
            end
        end
    end

    %%  calc gradients
    for l = 2 : n
        if strcmp(net.layers{l}.type, 'c')
            for j = 1 : numel(net.layers{l}.a)
                for i = 1 : numel(net.layers{l - 1}.a)
                    net.layers{l}.dk{i}{j} = convn(flipall(net.layers{l - 1}.a{i}), net.layers{l}.d{j}, 'valid') / m;
                end
                net.layers{l}.db{j} = sum(net.layers{l}.d{j}(:)) / m;
            end
        elseif strcmp(net.layers{l}.type, 'h') || strcmp(net.layers{l}.type, 'o')
            for j = 1 : numel(net.layers{l}.a)
                z = ones(1, m);
                for i = 1 : numel(net.layers{l - 1}.a)
                    sa = size(net.layers{l - 1}.a{i});
                    z = vertcat(z, reshape(net.layers{l - 1}.a{i}, prod(sa(1:end-1)), sa(end)));
                end
                net.layers{l}.dW{j} = net.layers{l}.d{j} * z' / m; % NOTE: check up on bias stuff
                if isfield(net.layers{l}, 'reconstruct') && net.layers{l}.reconstruct > 0
                    net.layers{l}.drW{j} = net.layers{l}.reconstruct_d{j} * vertcat(ones(1, m), net.layers{l}.a{1})' / m;
                end
            end
        end
    end
    %net.dffW = net.od * (net.fv)' / size(net.od, ndims(net.od));
    %net.dffb = mean(net.od, ndims(net.od));

    function X1 = rot180(X)
        X1 = X;
        for d = 1:ndims(X)
            X1 = flipdim(X1, d);
        end
    end
end
