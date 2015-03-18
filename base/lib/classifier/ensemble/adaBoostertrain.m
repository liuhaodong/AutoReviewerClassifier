function classifier_struct = adaBoostertrain(feat, out, params)


num_classifiers = params.num_classifiers;
classifiers = {1,num_classifiers};
train_size = params.k;

% Note that ratioMatrix is for our modified adaBoost which takes into
% account accuracy for a classifier on a specific label
% Holds the ratios for label correctness of each classifier
ratioMatrix = cell(1,num_classifiers);

% Given N training examples, weights each equally likely to be included
% in a classifier T times. Each time, error is calculated which must be
% <0.5. Then Beta_t is derived from error and recorded and the distribution
% of data is re-weighted. 
num_trials = size(feat,1);

% Note that uninit is just a faster way of initializing an array
%weightVector = uninit(1,num_trials);
%weightVector(:) = 1/num_trials;

% weightVector represents probability distribution of every data point
weightVector = zeros(1,num_trials);
weightVector(:) = 1/num_trials;


num_failed_classifiers = 0;
num_total_classifiers = 0;

% For every classifier, take a random sample of trials based on
% weightVector then test them on all the training data and use their error
% as a beta value 
for c = 1:num_classifiers
    idx = randsample(1:num_trials,ceil(train_size * num_trials),true, weightVector);
    feat_c = feat(idx, :);
    out_c = out(idx, :);
    classifiers{c} = train_classifier(vector_to_data(feat_c, out_c), params.subclassifier.name, params);
    output = apply_classifier(vector_to_data(feat,out), classifiers{c});
    
    % errorT = the sum of the weights of all the data points misclassified
    % by this classifier
    errorT = 0;
    
    % variables to find ratio of this classifier classifying an example as one or two correctly
    correct_ones = 0;
    correct_twos = 0;
    total_ones = 0;
    total_twos = 0;
    
    for k = 1:num_trials
        
% Confused whether to make it num correctly classified/ total 1s by the
% oracle or by the classifier, made it by classifier

         if strcmp(params.subclassifier.name, 'nbayesPooled')
             % If nbayesPooled correctly labels it 1
             if (output(k,1) > output(k,2))
                 total_ones = total_ones + 1;
                 if (out(k) == 1)
                     correct_ones = correct_ones + 1;
                 else
                     errorT = errorT + weightVector(k);
                 end
             else % (output(k,1) < output(k,2))
                 total_twos = total_twos + 1;
                 if (out(k) == 2)
                     correct_twos = correct_twos + 1;
                 else
                     errorT = errorT + weightVector(k);
                 end
             end
             
         else
             if (output(k,2)+1) == 1
                 total_ones = total_ones + 1;
                 if (output(k,2)+1) ~= out(k)
                     errorT = errorT + weightVector(k);
                 else
                     correct_ones = correct_ones + 1;
                 end
             else
                 total_twos = total_twos + 1;
                 if (output(k,2)+1) ~= out(k)
                     errorT = errorT + weightVector(k);
                 else
                     correct_twos = correct_twos + 1;
                 end
             end
         end
         
        % Final ratios
        ratioMatrix{c} = [correct_ones/total_ones correct_twos/total_twos];

        
    % Note, nothing currently done if a classifier gets over 50% wrong on
    % training data
    if errorT > 0.5
        num_failed_classifiers = num_failed_classifiers + 1;
    end
    num_total_classifiers = num_total_classifiers + 1;
    betaT = errorT/(1-errorT);
    end
    
    
    % Changing weights of each data point (trials)
    for j = 1:num_trials
        if (output(j,2)+1) == out(j);
            weightVector(j) = weightVector(j)*betaT;
        end
    end
    weightVector = weightVector / sum(weightVector(:));
end

classifier_struct.classifiers = classifiers;
classifier_struct.ratios = ratioMatrix;

end