function out = activationff(in, func)

switch func
    case 'sigmoid'
        out = sigm(in);
    case 'rectifier'
        out = max(0, in);
end
end

