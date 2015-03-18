function [out] = run_all_classification(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};
cv_splits = varargin{2};
feature_selector = varargin{3};
classifier = varargin{4};
epoch_voting = varargin{5};
balance = varargin{6};
params = varargin{7};
params.pretrained_classifier = varargin{8};

results = cell(length(cv_splits), 1);
ok_count = 0;
notok_count = 0;
for i = 1:length(cv_splits),
    cv = cv_splits(i);
    
    if epoch_voting
        cv_data = gen_cv_epoch_data(cv, data);
    else
        cv_data = gen_cv_data(cv, data);
    end

    I_balanced = balance_class(cv_data.train.task_M(:, strcmp(cv_data.train.task_H, 'COND')), balance);
    cv_data.train.task_M = cv_data.train.task_M(I_balanced, :);
    cv_data.train.feat_M = cv_data.train.feat_M(I_balanced, :);
    if (isempty(params.pretrained_classifier))
        [cv_data.train, trained_selector] = train_feature_selector(cv_data.train, feature_selector);
        cv_data.test = apply_feature_selector(cv_data.test, trained_selector);
    end
    trained_classifier = train_classifier(cv_data.train, classifier, params);
    if trained_classifier.ok,
        cv_results = apply_classifier(cv_data.test, trained_classifier, params);
		ok_count = ok_count + 1;
    else,
        cv_results = ones(size(cv_data.test.task_M, 1), length(unique(data.M(:,strcmp(data.H, 'cond')))) ) * 0.5;
		notok_count = notok_count + 1;
    end
    
    if epoch_voting
        cv_results = epoch_vote(cv, data, cv_results);
    end
    
    results{i} = cv_results;
end

out = results;
%[notok_count ok_count]

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end

function [out] = gen_cv_data(varargin)
cv = varargin{1};
data = varargin{2};

% get data
cv_data.train.feat_M = data.feat_M(cv.train, :);
cv_data.test.feat_M = data.feat_M(cv.test, :);
cv_data.train.feat_H = data.feat_H;
cv_data.test.feat_H = data.feat_H;
cv_data.train.task_M = data.task_M(cv.train, :);
cv_data.test.task_M = data.task_M(cv.test, :);
cv_data.train.task_H = data.task_H;
cv_data.test.task_H = data.task_H;
out = cv_data;

end

function [out] = gen_cv_epoch_data(varargin)
cv = varargin{1};
data = varargin{2};

% fill features
ecv.train = find(ismember(data.epoch.idx, cv.train));
ecv.test = find(ismember(data.epoch.idx, cv.test));
cv_data.train.feat_M = data.epoch.M(ecv.train, :);
cv_data.test.feat_M = data.epoch.M(ecv.test, :);
cv_data.train.feat_H = data.epoch.H;
cv_data.test.feat_H = data.epoch.H;

% fill task info
t.ecv.train = data.epoch.idx(ecv.train);
t.ecv.test = data.epoch.idx(ecv.test);
cv_data.train.task_M = data.task_M(t.ecv.train, :);
cv_data.test.task_M = data.task_M(t.ecv.test, :);
cv_data.train.task_H = data.task_H;
cv_data.test.task_H = data.task_H;
out = cv_data;

end

function [out] = epoch_vote(cv, data, cv_results),
ecv.test = find(ismember(data.epoch.idx, cv.test));
t.ecv.test = data.epoch.idx(ecv.test);
voted_results = zeros(length(cv.test), size(cv_results, 2));
for i = 1:length(cv.test),
    I = (t.ecv.test == cv.test(i));
    results_i = cv_results(I, :);
    % collect votes
    votes = zeros(size(results_i, 1), 1);
    for r = 1:size(results_i, 1)
         [res_c, res_i] = max(results_i(r, :));
         votes(r) = res_i;
    end
    [vote_cnt, vote_class] = hist(votes, unique(votes));
    for v = 1:length(vote_class)
         voted_results(i, vote_class(v)) = vote_cnt(v) / sum(vote_cnt);
    end
end
out = voted_results;
end