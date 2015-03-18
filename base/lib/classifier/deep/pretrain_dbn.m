function out = pretrain_dbn(varargin)
global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

params = varargin{1};
expt = varargin{2};

expt.task_file = params.task_file;
expt.eeg_files = params.eeg_files;
data = run_prepare_data(expt);

% prepare data for deep
data = load_cached_object(data);
train_x = vector_to_deep(data.feat_M);

% unsupervised phase
rand('state',0)
dbn.sizes = params.sizes;
opts =   params.opts;
train_x = train_x(1:floor(size(train_x, 1) / opts.batchsize) * opts.batchsize, :);
dbn = dbnsetup(dbn, train_x, opts);
dbn = dbntrain(dbn, train_x, opts);

out = dbn;
out = cache_exit(INTERN_cache_desc, out);
end

