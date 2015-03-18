function [data] = evaluate_results(data)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% remove nans
I = isfinite(data.results(:, 1));
gold = data.Y(I, :);
results = data.results(I, :);

% get score
[acc, racc, eY, rank, confusion] = classifier_score(gold, results);
data.eY = NaN(size(data.Y));
data.eY(I) = eY;

% do sig test
correct = length(find(acc));
incorrect = length(~find(acc));
total = length(eY);
chi2 = chi_squared_sig_test([correct, incorrect],   [total * 0.5, total * 0.5], 0.05);

% print results
confusion
n = length(acc);
accuracy = length(find(acc)) / length(acc);
p = chi2.P;
sig_indicator = {'', '*'};
fprintf('n=%d accuracy=%1.2f%s p=%1.2f\n', n, accuracy, sig_indicator{chi2.H+1}, p);

data.outcome.acc = accuracy;
data.outcome.confusion = confusion;
data.outcome.p = p;
data.outcome.f1 = 0;
data.outcome.matthews = 0;

if length(nanunique(data.eY)) == 2,
    TP = confusion(2, 2);
    FN = confusion(1, 2);
    FP = confusion(2, 1);
    TN = confusion(1, 1);
    data.outcome.f1 = 2*TP/(2*TP + FP + FN);
    data.outcome.matthews = (TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
end

end
