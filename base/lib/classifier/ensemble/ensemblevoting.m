% Voting mechanisms for majority vote, borda count, algebraic combiners
% (max/min/mean/weighted mean/trimmed mean/product), and 
% results is a cell array of size kx1, each cell is an array of m trials by n 
% classes and each value x_i,j contains classifier i's confidence in class
% j for trial k
% vote_method is a string specifying voting method

function out = ensemblevoting(results, vote_method)
switch(vote_method)
    % Rather pointless, just turns the one with greatest support into 1 the
    % rest 0
    case 'majorityvote'
        votes = results{1};
        for r_i = 2:length(results)
            votes = votes + results{r_i};
        end
    
        len = length(votes(1,:));
        for i = 1:size(votes, 1)
            [~, index] = max(votes(i,:));
            votes(i, :) = zeros(len);
            votes(i, index) = 1;
        end
        out = votes;

    % Currently just awards top 2 with .75 and .25 points (careful bc of
    % binary classifiers)
    % Only additional parameter needed is the points, but note that we
    % need >= # classes than possible points 
    % Note, if classifiers only say 1 or 0 for all classifiers, borda count
    % is just slower majority vote
    case 'bordacount'
        points = [0.75, 0.25];
        % We first look at each classifier array and then each trial within it
        for r_i = 1:size(results,1)
            vote = results{r_i};
            % For each trial, we find indices of top n values and place
            % them all within tempArray and then plug this back in as our
            % new vote for this trial 
            for s_i = 1:size(vote,1)
                 [~, indices] = sort(vote(s_i,:), 'descend');
                 tempArray = zeros(length(indices));
                 for i = 1:length(points)
                     tempArray(indices(i)) = points(i);
                 end
                 vote(s_i,:) = tempArray;
            end
            results{r_i} = vote;
        end
        
        % Just sums up all the votes for all classifiers for all trials
        % which is the format we want
        votes = results{1};
        for r_i = 2:length(results)
            votes = votes + results{r_i};
        end
        
        for i = 1:size(votes, 1)
            votes(i, :) = votes(i, :) / sum(votes(i, :));
        end
        out = votes;
        
    % Literally just summing all the votes up like normal, dividing by
    % the number of classifiers and then either converting to probabilities
    % or just setting max to 1 and the rest to 0
    case 'mean'
        votes = results{1};
        for r_i = 2:length(results)
            votes = votes + results{r_i};
        end
    
        % This is the only added line:
        votes = votes / size(results,1);
        
        for i = 1:size(votes, 1)
            votes(i, :) = votes(i, :) / sum(votes(i, :));
        end
        out = votes;
        
    % Same as mean but each classifier gets a different weight to their
    % votes. Assume we have some beta matrix of all the weights for each
    % classifier
    case 'wmean'
        votes = results{1} * beta_matrix(1);
        for r_i = 2:length(results)
            votes = votes + results{r_i} * beta_matrix(r_i);
        end
    
        % This is the only added line:
        votes = votes / size(results,1);
        
        for i = 1:size(votes, 1)
            votes(i, :) = votes(i, :) / sum(votes(i, :));
        end
        out = votes;
        
        
        
    % Assumes you want to remove "trim" % from top and bottom, mashes 
    % together elements along the same z vector, removes the edge cases and 
    % averages them for each trial x class
    % Note that if trim = 0.49 or 0.5 for odd # elements, this is just median rule 
    case 'trimmedmean'
        trim = 0.2;
        votes = results{1};
        for i  = 1:size(results,1) 
            col = size(results,2);
            for j = 1:col
                sorted = sort(squeeze(results{i,j,:}));
                votes (i,j) = mean(sorted(floor(trim*col): col - ceil(trim*col)));  
            end
        end
        
    % Each trial/class gets the highest minimum support by any classifier
    case 'minimum' 
        votes = results{1};
        for i  = 1:size(results,1)
            col = size(results,2);
            for j = 1:col
                my_vector = squeeze(results{i,j,:});
                votes (i,j) = min(my_vector);
            end
        end
        
        % Each trial/class gets the highest maximum support by any classifier
        case 'maximum' 
        votes = results{1};
        for i  = 1:size(results,1)
            col = size(results,2);
            for j = 1:col
                my_vector = squeeze(results{i,j,:});
                votes (i,j) = max(my_vector);
            end
        end
        
        % Product of each classifier's confidence in class/trial is used
        % NOTE: Only works if individual posterior probabilities close to
        % correctly estimated!
        case 'product' 
        votes = results{1};
        for i  = 1:size(results,1)
            col = size(results,2);
            for j = 1:col
                my_vector = squeeze(results{i,j,:});
                votes (i,j) = prod(my_vector);
            end
        end
        
end
     

end
    