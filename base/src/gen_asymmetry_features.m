function [ out ] = gen_asymmetry_features(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};
feature_set = varargin{2};

for s = 1:length(data.sensor_names),
    sensor_name = data.sensor_names{s};
    sensor = data.sensors(s);
    for t = 1:length(sensor.(feature_set)),
        if ~isempty(sensor.(feature_set){t})
            fns = fieldnames(sensor.(feature_set){t});
        end
    end
end

for t = 1:size(data.M,1);
    asymmetry_features = [];
    if ~isempty(data.sensors(1).(feature_set){t}) && ~isempty(data.sensors(2).(feature_set){t})
        fns = fieldnames(data.sensors(1).(feature_set){t});
        for f = 1:length(fns)
            feature = fns{f};
            asymmetry_features.(sprintf('asym_%s', feature)) = ...
                data.sensors(1).(feature_set){t}.(feature) - data.sensors(2).(feature_set){t}.(feature);
        end
    end
    data.asymmetry_features{t} = asymmetry_features;
end

out = data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end
