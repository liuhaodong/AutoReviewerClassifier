function nn = mynnmode(nn, reconstruct)

for l = 1:numel(nn.layers)
    if isfield(nn.layers{l}, 'autoencodable') && nn.layers{l}.autoencodable == 1
        nn.layers{l}.reconstruct = reconstruct;
    end
end

end
