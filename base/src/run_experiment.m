function [data] = run_experiment( expt )

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
    fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

%RUN_EXPERIMENT Summary of this function goes here
%   Detailed explanation goes here

run_setup;

data = run_prepare_data(expt);

if isfield(expt.classifier.params, 'pretrain')
    pretrain = pretrain_dbn(expt.classifier.params.pretrain, expt);
else
    pretrain = [];
end

% cross-validated classification
cv_splits = gen_cv_splits(data, expt.cv, expt.cv_subjects);
[cv_results] = run_all_classification(data, cv_splits, expt.feature_selector,...
                        expt.classifier.name, expt.epoch_voting, expt.balance, ...
                        expt.classifier.params, pretrain);

% evaluate results
data = load_cached_object(data);
data = aggregate_results(data, cv_splits, cv_results);
data = evaluate_results(data);

%my_visualize(data);
%describe_task(data, 2);

M = data.M;
H = data.H;
T = data.T;
C = data.C;

NUMERIC = 0;
STRING = 1;
DATENUM = 2;

H = {H{:}, data.feat_H{:}};
M_signal = NaN(size(M,1), size(data.feat_M,2));
M_signal(data.task_M(:,find(strcmp(data.task_H,'TASK'))),:) = data.feat_M;
M = [M M_signal];
T(end+1:end+1+length(data.feat_H)) = NUMERIC;

H_results = {};
for r = 1:size(data.results, 2)
    H_results = {H_results{:}, sprintf('results(%d)', r)};
end

H = {H{:}, 'Y', 'eY', H_results{:}};
M = [M data.Y data.eY data.results];
T(end+1:end+3+length(H_results)) = NUMERIC;

tablewrite(sprintf('%s/%s', expt.result, 'hof.xls'), M, H, T, C);
postprocess_results(data, expt.result, 'hof');

end

function data = aggregate_results(data, cv_splits, cv_results)
    list = data.task_H; enum = 1; enum_list;
    task_idxs = data.task_M(:, TASK);
    gold = data.task_M(:, COND);
    cv_splits = load_cached_object(cv_splits);
    cv_results = load_cached_object(cv_results);
    data.results = NaN(size(data.M,1), length(unique(data.task_M(:,strcmp(data.task_H, 'COND')))) );
    data.Y = NaN(size(data.M,1), 1);
    for i = 1:length(cv_splits)
        cv = cv_splits(i);
        data.results(task_idxs(cv.test), :) = cv_results{i};
        data.Y(task_idxs(cv.test)) = gold(cv.test);
    end
end
