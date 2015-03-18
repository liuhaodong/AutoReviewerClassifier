function [data] = run_prepare_data( expt )

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

%% Experiment

% load task file
task_data = read_task(expt.task_file);

% load and prepare eeg files
datas = {};
for e = 1:length(expt.eeg_files),
    % load eeg file
    eeg_data = read_eeg(expt.eeg_files{e}, expt.sigqual_sample);

    % prepare data
    eeg_data = smooth_eeg(eeg_data, expt.denoise, expt.bandpass, expt.sampling_rate);

    data = align_data(task_data, eeg_data, expt.sampling_rate);

    data = gen_epochs(data, expt.epochs);
    data = gen_epoch_features(data, expt.bands, expt.sampling_rate);
    if isfield(expt, 'rest')
       data = calibrate(data, expt.bands, expt.rest);
    end
    switch expt.feature_set
        case 'higher_order_features'
            data = gen_higher_order_features(data, expt.higher_order_features);
        case 'raw_features'
            data = gen_raw_features(data);
        case 'wavelet_features'
            data = gen_wavelet_features(data, 3, 8);
    end
    datas{e} = data;
end
data = merge_data(expt.eeg_files, datas);

if expt.asymmetry
    data = gen_asymmetry_features(data, 'higher_order_features');
end

% generate feature matrix for classifier
data = gen_feature_matrix(data, expt.normalize, expt.feature_set, expt.asymmetry);
if isfield(expt, 'rest')
    data = filter_data(data, expt.sigqual_percentage, expt.rest);
else
    data = filter_data(data, expt.sigqual_percentage);
end

end