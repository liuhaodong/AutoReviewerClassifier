function [ out ] = gen_wavelet_features(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};
degree = varargin{2};
detail = varargin{3};

lengths = arrayfun(@(x) length(x.time), data.RAWWAVE);
min_length = min(lengths(lengths ~= 0));

for t = 1:size(data.M,1),
    if (length(data.RAWWAVE(t).time) < min_length),
        data.wavelet_features{t} = [];
        continue;
    end
    
    xs = data.RAWWAVE(t).signal(1:min_length);
    [Lo_D,Hi_D,Lo_R,Hi_R] = wfilters('db6');
    [C, L] = wavedec(xs, 3, Lo_D, Hi_D);
    wave = [];
    for l = 1:length(L)-1
        right = sum(L(1:l));
        left = sum(L(1:l)) - L(l) + 1;
        subwave = C(left:right);
        subwave = downsample(subwave, max(1, ceil(L(l)/detail)));
        wave = vertcat(wave, subwave);
    end
    for i = 1:length(wave),
        task_features.(sprintf('wavelet_%d', i)) = wave(i);
    end
    
    data.wavelet_features{t} = task_features;
end

out = data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end