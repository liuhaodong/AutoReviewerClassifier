function [out] = smooth(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};
denoise_N = varargin{2};
bandpass = varargin{3};
sampling_rate = varargin{4};

for d = 1:length(data)
    data{d}.rawwave.unsmoothed = data{d}.rawwave.signal;
    % butterworth bandpass
    [a, b] = butter(2, bandpass * 2 / sampling_rate);
    data{d}.rawwave.signal = filter(a, b, data{d}.rawwave.signal);
    
    %soft thresholding
    [thr, sorh, keepapp] = ddencmp('den', 'wv', data{d}.rawwave.signal); % find the threshholding value
    data{d}.rawwave.signal = wdencmp('gbl', data{d}.rawwave.signal, 'db3', denoise_N, thr, sorh, keepapp); % de-noising using the threshholding value
    
    data{d}.rawwave.signal = wica(data{d}.rawwave.signal);
end

out = data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end
