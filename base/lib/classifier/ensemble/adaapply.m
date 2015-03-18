% Takes each classifier, applies it to the test data, assume that it only
% outputs 1 or 0 for each class so that we can multiply it by the beta of
% the classifier
function out = adaapply(classifier_struct, feat) 
    classifiers = classifier_struct.classifiers;
    results = cell(1,size(classifiers,1));
    
    % Note that this assumes that result will originally be 1 or 0 for all
    % labels so that we are essentially just voting log(1/beta_t) instead of
    % 1
    for c_i = 1:length(classifiers);
        result = apply_classifier(vector_to_data(feat), classifiers{c_i});
        results{c_i} = result * log(1/classifier_struct.beta(c_i));
    end
    
    votes = results{1};
    for r_i = 2:length(results)
        votes = votes + results{r_i};
    end
    
    for i = 1:size(votes, 1)
        votes(i, :) = votes(i, :) / abs(sum(votes(i, :)));
    end
    out = votes;
    
end