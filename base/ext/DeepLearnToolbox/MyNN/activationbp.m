function out = activationbp(in, func)

switch func
    case 'sigmoid'
        out = (in .* (1 - in));
    case 'rectifier'
        out = double(in > 0);
end

end