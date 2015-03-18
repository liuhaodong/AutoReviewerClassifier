function [selected, score] = discriminability(X, y, classifier_name, num_selected)

for x = 1:size(X,2),
	classifier = trainClassifier(X(:,x), y, classifier_name);
	scores = applyClassifier(X(:,x), classifier);
	[result eY trace] = summarizePredictions(scores, classifier, 'averageRank', y);
	racc(x) = 1 - result{1};
end % x 

if num_selected ~= 0,
	[~, I] = sort(racc, 2, 'descend');
	selected = I(1:num_selected);
else,
	selected = 1:size(X,2);
end

score = racc;
