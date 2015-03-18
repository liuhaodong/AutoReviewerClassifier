function net = mynnsetup(net, num_classes)
    assert(~isOctave() || compare_versions(OCTAVE_VERSION, '3.8.0', '>='), ['Octave 3.8.0 or greater is required for CNNs as there is a bug in convolution in previous versions. See http://savannah.gnu.org/bugs/?39314. Your version is ' myOctaveVersion]);
    inputmaps = 1;
    mapsize = net.layers{1}.shape;

    for l = 1 : numel(net.layers)   %  layer
        if strcmp(net.layers{l}.type, 's')
            mapsize = mapsize ./ net.layers{l}.scale;
            assert(all(floor(mapsize)==mapsize), ['Layer ' num2str(l) ' size must be integer. Actual: ' num2str(mapsize)]);
            for j = 1 : inputmaps
                net.layers{l}.b{j} = 0;
            end
        end
        if strcmp(net.layers{l}.type, 'c')
            mapsize = mapsize - net.layers{l}.kernelsize + 1;
            fan_out = net.layers{l}.outputmaps * prod(net.layers{l}.kernelsize);
            for j = 1 : net.layers{l}.outputmaps  %  output map
                fan_in = inputmaps * prod(net.layers{l}.kernelsize);
                for i = 1 : inputmaps  %  input map
                    net.layers{l}.k{i}{j} = (rand(net.layers{l}.kernelsize) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out));
                    net.layers{l}.vk{i}{j} = zeros(size(net.layers{l}.k{i}{j}));
                end
                net.layers{l}.b{j} = 0;
            end
            inputmaps = net.layers{l}.outputmaps;
        end
        if strcmp(net.layers{l}.type, 'h') || strcmp(net.layers{l}.type, 'o')
            if (strcmp(net.layers{l}.type, 'o'))
                net.layers{l}.size = num_classes;
            end
            hidden_size = net.layers{l}.size;
            input_size = inputmaps * prod(mapsize);
            net.layers{l}.W = (rand(hidden_size, input_size+1) - 0.5) * 2 * 4 * sqrt(6 / (hidden_size + input_size));
            net.layers{l}.vW = zeros(size(net.layers{l}.W));
            inputmaps = 1;
            mapsize = hidden_size;
            if (isfield(net.layers{l}, 'autoencodable') && net.layers{l}.autoencodable == 1)
                net.layers{l}.rW = (rand(input_size, hidden_size + 1) - 0.5) * 2 * 4 * sqrt(6 / (hidden_size + input_size));
                net.layers{l}.vrW = zeros(size(net.layers{l}.rW));
                net.layers{l}.reconstruct = 0;
            end
        end
    end

end
