function [out] = calibrate(varargin)

global DEBUG VERBOSE;
% Print TicToc for profile reasons
if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};
bands = varargin{2};
rest = varargin{3};

% load calibration data into a table for later use
cond_I = strcmp(data.H(:), 'cond');
subject_I = strcmp(data.H(:), 'subject');
start_I = strcmp(data.H(:), 'start_time');
end_I = strcmp(data.H(:), 'end_time');
calibration_I_bool = data.M(:, cond_I) == rest;
calibration_I = find(calibration_I_bool);
nonrest_I = find(~calibration_I_bool);
calibration_data = {};
for i = 1:length(calibration_I),
    c_i = calibration_I(i);
    epochs = data.epochs{c_i};
    calibration_datum = struct;
    for e_i = 1:numel(epochs),
        epoch = epochs(e_i);
        if isfield(epoch, 'features')
            fns = fieldnames(epoch.features);
            for fn_i = 1:length(fns)
                fn = fns{fn_i};
                if isfield(calibration_datum, fn)
                    calibration_datum.(fn) = [calibration_datum.(fn) epoch.features.(fn)];
                else
                    calibration_datum.(fn) = epoch.features.(fn);
                end
            end
        end
    end
    if (length(fieldnames(calibration_datum)) > 0)
        fns = fieldnames(calibration_datum);
        for fn_i = 1:length(fns)
            fn = fns{fn_i};
            calibration_datum.(fn) = mean(calibration_datum.(fn));
        end
        calibration_data{end+1}.features = calibration_datum;
        calibration_data{end}.time = (data.M(c_i, start_I) + data.M(c_i, end_I)) / 2;
        calibration_data{end}.subject = data.M(c_i, subject_I);
    end
end

% calibration non-rest data
for i = 1:length(nonrest_I),
    d_i = nonrest_I(i);
    epochs = data.epochs{d_i};
    % continue if there are no epochs or no suitable data
    if isempty(epochs)
        continue;
    elseif ~isfield(epochs(1), 'features')
        continue;
    end
    % find the nearest time
    time = (data.M(d_i, start_I) + data.M(d_i, end_I)) / 2;
    subject = data.M(d_i, subject_I);
    BIG = 999999;
    dist = cellfun(@(dat) (dat.subject ~= subject) * BIG + abs(time - dat.time), calibration_data);
    % if no rest calibration is found, then empty out this epoch
    if  min(dist) > BIG
        data.epochs{d_i} = []; % TODO: log warning?
        continue;
    end
    calibration = calibration_data{find(dist(:) == min(dist))}.features;
    for e_i = 1:numel(epochs)
        epoch = epochs(e_i);
        fns = fieldnames(epoch.features);
        for fn_i = 1:length(fns)
            fn = fns{fn_i};
            data.epochs{d_i}(e_i).features.(fn) = epoch.features.(fn) - calibration.(fn);
        end
    end
end

out = data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);

end
