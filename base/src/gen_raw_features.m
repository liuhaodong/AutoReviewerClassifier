function [ out ] = gen_raw_features(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};

for t = 1:size(data.M,1),
    if isempty(data.epochs{t}) || ~isfield(data.epochs{t}(1), 'features')
        data.raw_features{t} = [];
        continue;
    end
    task_features = struct;
    fields = fieldnames(data.epochs{t}(1).features);
    for e = 1:numel(data.epochs{t})
        epoch = data.epochs{t}(e);
        for j = 1:length(fields)
            fn = fields{j};
            task_features.(sprintf('%s_%d', fn, e)) = epoch.features.(fn);
        end
    end

    data.raw_features{t} = task_features;
end

out = data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end
