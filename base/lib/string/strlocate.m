function I = strlocate(S, str)

K = strfind(S, str);

I = [];

for i = 1:length(K),
        if ~isempty(K{i}),
                I(end+1) = i;
        end
end % i
