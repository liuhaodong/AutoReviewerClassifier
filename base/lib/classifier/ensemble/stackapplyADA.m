function labels = stackapplyADA(classifier_struct, feat)
classifiers = classifier_struct.classifiers;

class_ratios = classifier_struct.ratios;

% For each trial, we apply every classifier on it and create a
% matrix for that trial. Our output is a vector of matrices, length = #trials,
% each element is number of classifiers x number of outputs
    
num_classifiers = size(classifiers,1);
num_trials = size(feat,1);
nn_input = zeros(num_trials, num_classifiers);

for c_i = 1:length(classifiers)
    output = apply_classifier(vector_to_data(feat), classifiers{c_i});
    
    %         ratios = class_ratios{c_i};
    %
    %         result(:,1) = result(:,1) * log(ratios(1) / (1-ratios(1)));
    %         result(:,2) = result(:,2) * log(ratios(2) / (1-ratios(2)));
    %
    %         results{c_i} = result;
    
    classifier_c = class_ratios{c_i};
    for k = 1:num_trials
             if strcmp(classifier_struct.subclassifier, 'nbayesPooled')
                 result = classifier_c((output(k,1) > output(k,2))+1);
                 nn_input(k,c_i) = log(result / (1-result));
             else
                 result = classifier_c((output(k,2)+1 == 1)+1);
                 nn_input(k,c_i) = log(result / (1-result));
             end
    end
end


train_x = vector_to_deep(nn_input);
labels = nnpredict(classifier_struct.nn, train_x);
    
end