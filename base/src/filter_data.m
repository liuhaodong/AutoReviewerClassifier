function out = filter_data(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;


data = varargin{1};
sigqual_percentage = varargin{2};
if (length(varargin) > 2),
    rest = varargin{3};
end

list = data.task_H; enum = 1; enum_list;

M = data.task_M;

% original data size
I = false(size(M,1), 1);
filter.orignal = [size(M(~isnan(M(:, COND)),:)) nanfreq(M(:, COND))];

% remove calibration segments
if exist('rest', 'var')
    I = (data.task_M(:, COND) == rest) | I;
    M(I,:) = NaN;
    filter.remove_rest = [size(M(~isnan(M(:, COND)),:)) nanfreq(M(:, COND))];
end

% filter out rows with NaN features
I = any(isnan(data.feat_M), 2) | I;
M(I,:) = NaN;
filter.nan = [size(M(~isnan(M(:, COND)),:)) nanfreq(M(:, COND))];

% filter by signal
I = M(:,INTERN_QUALITY) < sigqual_percentage | I;
M(I,:) = NaN;
filter.sigqual = [size(M(~isnan(M(:, COND)),:)) nanfreq(M(:, COND))];

filter

data.task_M = data.task_M(~I, :);
data.feat_M = data.feat_M(~I, :);
data.cond_dict = containers.Map;

conds = unique(data.task_M(:, COND));
for i = length(conds):-1:1,
    data.task_M((data.task_M(:, COND) == conds(i)), COND) = i;
    data.cond_dict(sprintf('%d', i)) = conds(i);
end

% new indices
selected_I = find(~I);
new_indices = NaN(length(I), 1);
for i = 1:size(selected_I, 1),
    new_indices(selected_I(i)) = i;
end

% re-index epochs
current_row = 0;
for i = 1:size(data.epoch.idx, 1),
    data.epoch.idx(i) = new_indices(data.epoch.idx(i));
end

out = data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end
