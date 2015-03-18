global DEBUG CACHE VERBOSE INDEX;
CACHE = expt.cache;
VERBOSE = '-printTicToc';

%% Setup
run_setup_paths;

warning('off', 'MATLAB:polyfit:PolyNotUnique');

seed = RandStream('mt19937ar','Seed', 5489);
RandStream.setGlobalStream(seed);

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	tic;
end

% load defaults
%expt.result = '../result';
if ~isfield(expt, 'desc'),
    expt.desc = sprintf('DESC %s', 'stuff'); %TODO figure out what to put in here
end
if ~isfield(expt, 'epoch_voting')
    expt.epoch_voting = 0;
end
if ~isfield(expt, 'balance')
    expt.balance = 'none';
end
if ~isfield(expt, 'asymmetry')
    expt.asymmetry = 0;
end
expt

init_cache();
% make necessary folders
if ~exist(expt.cache, 'dir') && ~strcmp(expt.cache, ''),
    mkdir(expt.cache);
end;
if ~exist(expt.result, 'dir') && ~strcmp(expt.result, ''),
    mkdir(expt.result);
end;
if isfield(expt, 'classifier_folder') && ~exist(expt.classifier_folder, 'dir')
    mkdir(expt.classifier_folder);
end

% clear experimental cache from previous runs and clean index
clean_cache();
