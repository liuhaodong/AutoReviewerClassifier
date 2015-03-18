function out = ensembleapply(classifier_struct, feat)

classifiers = classifier_struct.classifiers;

results = {};
for c_i = 1:length(classifiers)
    classifier = classifiers{c_i};
    result = apply_classifier(vector_to_data(feat), classifier);
    results{c_i} = result;
end

% voting
votes = results{1};
for r_i = 2:length(results)
    votes = votes + results{r_i};
end
for i = 1:size(votes, 1)
    votes(i, :) = votes(i, :) / sum(votes(i, :));
end
out = votes;

end