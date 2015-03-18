% Takes each classifier, applies it to the test data, assume that it only
% outputs 1 or 0 for each class so that we can multiply it by the beta of
% the classifier
function out = ada2apply(classifier_struct, feat) 
    classifiers = classifier_struct.classifiers;
    results = cell(1,size(classifiers,1));
    
    class_ratios = classifier_struct.ratios;
    
    % Note that this assumes that result will originally be 1 or 0 for all
    % labels so that we are essentially just voting log(1/beta_t) instead of
    % 1
    for c_i = 1:length(classifiers);
        result = apply_classifier(vector_to_data(feat), classifiers{c_i});
        ratios = class_ratios{c_i};
        
        result(:,1) = result(:,1) * log(ratios(1) / (1-ratios(1)));
        result(:,2) = result(:,2) * log(ratios(2) / (1-ratios(2)));
        
        results{c_i} = result;
        
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