function [out] = align_data(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
    fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

task_data = varargin{1};
eeg_data = varargin{2};
sampling_rate = varargin{3};

list = upper(task_data.H); enum = 1; enum_list;

eeg_subjects = cell(length(eeg_data));
for s = 1:length(eeg_data),
	eeg_subjects{s} = eeg_data{s}.subject;
end % s

%% Create M
eeg = eeg_data{1}; % load something

% init data arrays
task_data.('INTERN_QUALITY') = zeros(size(task_data.M,1), 1);
aligned_rawwave.time = cell(size(task_data.M,1), 1);
aligned_rawwave.signal = cell(size(task_data.M,1), 1);
aligned_rawwave.unsmoothed = cell(size(task_data.M,1), 1);

for t = 1:size(task_data.M,1),
    subject = task_data.C{SUBJECT}(task_data.M(t,SUBJECT));
    start_time = task_data.M(t,START_TIME);
    end_time = task_data.M(t,END_TIME);
    
    % get EEG data
    if ~strcmp(eeg.subject, subject),
		s = find(strcmp(eeg_subjects, subject));
		if ~isempty(s),
			eeg = eeg_data{s};
		else,
			continue;
		end
    end
    
    % align rawwave
    I = find(and(start_time <= eeg.rawwave.time, eeg.rawwave.time <= end_time));
    ts = eeg.rawwave.time(I);
    xs = eeg.rawwave.signal(I);
    expected_samples = etime(datevec(end_time), datevec(start_time)) * sampling_rate;
    task_data.('INTERN_QUALITY')(t) = length(xs) / expected_samples;

    % store rawwave
    aligned_rawwave.time{t} = ts;
    aligned_rawwave.signal{t} = xs;
    aligned_rawwave.unsmoothed{t} = eeg.rawwave.unsmoothed(I);
end % t

task_data.('RAWWAVE') = struct('time', aligned_rawwave.time, 'signal', aligned_rawwave.signal, 'unsmoothed', aligned_rawwave.unsmoothed); 

out = task_data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end
