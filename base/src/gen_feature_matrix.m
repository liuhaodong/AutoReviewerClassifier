function [out] = gen_feature_matrix(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};
normalize = varargin{2};
feature_set = varargin{3};
asymmetry = varargin{4};

% TODO: drop this line
%data = merge_data({'s1'}, {data});

%%%% generate task level features %%%%

% H
H = {};
for s = 1:length(data.sensor_names),
    sensor_name = data.sensor_names{s};
    sensor = data.sensors(s);
    for t = 1:length(sensor.(feature_set)),
        if ~isempty(sensor.(feature_set){t})
            fns = fieldnames(sensor.(feature_set){t});
            break;
        end
    end
    for f = 1:length(fns)
        feature = fns{f};
        H{end + 1} = sprintf('sensor%d_%s', s, feature);
    end
end

if asymmetry
    feats = data.asymmetry_features;
    for t = 1:length(feats),
        if ~isempty(feats{t})
            fns = fieldnames(feats{t});
            break;
        end
    end
    for f = 1:length(fns)
        feature = fns{f};
        H{end + 1} = sprintf('asymmetry_%s', feature);
    end
end

H = [upper(H) 'SUBJECT' 'BLOCK' 'TASK' 'COND' 'INTERN_QUALITY'];
list = H; enum = 1; enum_list;

% M
M = NaN(size(data.M,1), length(H));

for t = 1:size(data.M,1),
    for s = 1:length(data.sensors),
        sensor = data.sensors(s);
        feats = sensor.(feature_set){t};
        if isempty(feats)
            continue;
        end
        fns = fieldnames(feats);
        for f = 1:length(fns)
            idx = strcmp(H, sprintf('SENSOR%d_%s', s, upper(fns{f})));
            M(t, idx) = feats.(fns{f});
        end % f
    end
    
    if asymmetry
        feats = data.asymmetry_features{t};
        if ~isempty(feats)
            fns = fieldnames(feats);
            for f = 1:length(fns)
                idx = strcmp(H, sprintf('ASYMMETRY_%s', upper(fns{f})));
                M(t, idx) = feats.(fns{f});
            end % f
        end
    end
    
	M(t, [SUBJECT BLOCK TASK COND INTERN_QUALITY]) = [ ...
		data.M(t, strcmp(data.H, 'subject')), ...
		data.M(t, strcmp(data.H, 'block')), ...
		data.TASK(t), ...
		data.M(t, strcmp(data.H, 'cond')), ...
		data.sensors(1).INTERN_QUALITY(t) ]; %TODO fix this
end % t

% Normalize all data per subject
if normalize,
    subjects = unique(M(:, SUBJECT));
    for s = 1:length(subjects),
        I_subject = M(:, SUBJECT) == s;
        M_subject = M(I_subject, 1:SUBJECT - 1);
        % compute the zscore ignoring nan
        M(I_subject, 1:SUBJECT - 1) = (M_subject - repmat(nanmean(M_subject), size(M_subject, 1), 1)) ...
            ./ repmat(nanstd(M_subject), size(M_subject, 1), 1);
    end % s
end % normalize

data.feat_H = H(1:SUBJECT  - 1);
data.feat_M = M(:, 1:SUBJECT - 1);
data.task_H = H(SUBJECT:end);
data.task_M = M(:, SUBJECT:end);

%%%% generate epoch level features %%%%

% H
epoch_headers = {};
data.sensors(1).epochs{t};
for t = 1:length(data.TASK)
    if isempty(data.sensors(1).epochs{t}) || ~isfield(data.sensors(1).epochs{t}(1), 'features')
        continue;
    else
        feats = data.sensors(1).epochs{t}(1).features;
        fns = fieldnames(feats);
        for s = 1:length(data.sensors)
            for f = 1:length(fns)
                epoch_headers{end + 1} = sprintf('sensor%d_%s', s, fns{f});
            end
        end
        break;
    end
end

epoch_headers = upper(epoch_headers);

% M
epoch_M = NaN(0, length(epoch_headers));
epoch_idx = NaN(0, 1);
for t = 1:length(data.TASK)
    reference_epochs = data.sensors(1).epochs{t};
    for e = 1:length(reference_epochs)
        bad = 0;
        row = NaN(1, length(epoch_headers));
        for s = 1:length(data.sensors)
            if (length(data.sensors(s).epochs{t}) < length(reference_epochs))
                bad = 1;
                break;
            end
            epoch = data.sensors(s).epochs{t}(e);
            if ~isfield(epoch, 'features')
                bad = 1;
                break;
            else
                feats = epoch.features;
            end
            fns = fieldnames(feats);
            for f = 1:length(fns)
                idx = strcmp(epoch_headers, sprintf('SENSOR%d_%s', s, upper(fns{f})));
                row(idx) = feats.(fns{f});
            end % f
        end
        if ~bad
            epoch_M(end+1, :) = row;
            epoch_idx(end+1, 1) = t;
        end
    end % e
end % t

data.epoch.H = epoch_headers;
data.epoch.M = epoch_M;
data.epoch.idx = epoch_idx;

sprintf('%d features', size(data.feat_M, 2))

out = data; 

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end