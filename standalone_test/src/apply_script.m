clear
global EXPERIMENTAL;
EXPERIMENTAL = {};

% data loading
expt.task_file = '../data/task.xls'; % the location of the task file
expt.eeg_files = {'../data/TP9.xls', '../data/FP1.xls', '../data/FP2.xls', '../data/TP10.xls'}; % the location of the eeg file

expt.cache = ''; % the location of the cache folder
expt.result = '../result'; % where we will store the outputs

% data info
expt.sigqual_sample = 100; % sigqual is from 0 (best) to 200 (worst).  Any eeg segment (row in eeg file) with sigqual higher than sigqual_sample will be filtered out
expt.sigqual_percentage = 0.0; % Any task segment (row in task file) with a percentage of filtered out eeg segments higher than sigqual_percentage will be filtered out
expt.denoise = 1; % denoise by wavelet transform
expt.bands = [1 4 8 12 30 101]; % the boundaries of the frequency band buckets.  e.g. 1-4 is a bucket, 4-8 is the next bucket
expt.sampling_rate = 512; % sampling rate of the eeg device used to collect data
expt.normalize = 1; % per-subject normalization (by zscore) across entire dataset prior to cross-validation and balancing
expt.rest = 3;
%expt.asymmetry = 0;

% filtering
expt.bandpass = [0.9, 102];

% segmental features
% each data segment is broken into sub-segments (epochs) and higher-order features are computed over these epochs 
expt.epochs.length = 1; % the length of an epoch (in seconds)
expt.epochs.overlap = 0.75; % the overlap between two epochs (in seconds)
expt.epochs.min = 0.5; % the minimum length of an epoch (in seconds)
expt.higher_order_features = {'mean', 'var'}; % mean, var (variance), max, and min are supported
expt.feature_set = 'higher_order_features';

% feature selection
expt.feature_selector.algorithm = 'pca'; % The feature selection algorithm.  Possible values: rank or pca
expt.feature_selector.dimensions = 20; % The dimensions to use after performing pca.  Field required if feature_selector.algorithm is pca
%expt.feature_selector.num_selected = 10; % The number of selected features in rank feature selection.  Field required if feature_selector.algorithm is rank

% classify
expt.cv = 'block'; % the type of cross-validation.  Leave-one-out is the only available method currently
expt.cv_subjects = 'within'; % the type of train/test split: within subject or between subject
expt.balance = 'none';
expt.classifier.name = 'deep'; % the type of algorithm.  Possible values: svm, nbayesPooled, or libsvm (faster implementation of svm, currently windows only)
expt.classifier.params = [];
expt.classifier.params.numepochs = 3000;
expt.classifier.params.batchsize = 15;
expt.classifier.params.alpha = 0.02;
expt.classifier.params.momentum = 0.8;
expt.classifier.params.error_window = 20;
expt.classifier.params.dev_size = 0.3;

use_classifier(expt);
