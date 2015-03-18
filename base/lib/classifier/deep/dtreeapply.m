function out = dtreeapply(classifier_struct, feat)

% Apply the tree to the input and get a vector of predicted outputs
yfit = classifier_struct(feat);
vote = zeros(length(yfit),2);

% Convert the vector into the expected input type
for i = 1:(length(yfit))
    if yfit{i} == '1'
        vote(i,1) = 1;
    else
        vote(i,2) = 1;
    end
end

out = vote;

end