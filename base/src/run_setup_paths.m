% get path of base folder
PATH = sprintf('%s/../../', mfilename('fullpath'));

% load libs
addpath(sprintf('%s/lib/cache', PATH));
addpath(sprintf('%s/lib/io', PATH));
addpath(sprintf('%s/lib/sigproc', PATH));
addpath(sprintf('%s/lib/stat', PATH));
addpath(sprintf('%s/lib/string', PATH));
addpath(sprintf('%s/lib/util', PATH));

addpath(sprintf('%s/lib/classifier', PATH));
addpath(sprintf('%s/lib/classifier/ensemble', PATH));
addpath(sprintf('%s/lib/classifier/deep', PATH));

addpath(sprintf('%s/ext/fmri_core_new', PATH));
addpath(sprintf('%s/ext/hashtable', PATH));
addpath(sprintf('%s/ext/libsvm', PATH));
addpath(sprintf('%s/ext/pca_ica', PATH));
addpath(genpath(sprintf('%s/ext/DeepLearnToolbox', PATH)));
