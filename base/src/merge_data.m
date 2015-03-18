function out = merge_data(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

sensor_names = varargin{1};
datas = varargin{2};

sensor_data = load_cached_object(datas{1});
shared_fields = {'M'; 'H'; 'T'; 'C'; 'TASK'};
for fn_i = 1:length(shared_fields)
    fn = shared_fields{fn_i};
    data.(fn) = sensor_data.(fn);
end
data.sensors = [];
data.sensor_names = sensor_names;
for d = 1:numel(datas)
    if (d ~= 1)
        sensor_data = load_cached_object(datas{d});
    end
    fns = fieldnames(sensor_data);
    for fn_i = 1:length(fns)
        fn = fns{fn_i};
        if ismember(fn, shared_fields)
            continue;
        end
        data.sensors(d).(fn) = sensor_data.(fn);
    end
end

out = data;

out = cache_exit(INTERN_cache_desc, out);
end