function [out] = read_eeg(varargin)

% Input:
%
% expt.eeg_files

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

eeg_file = varargin{1};
sigqual_sample = varargin{2};

%% Load
[M H T C] = tableread(eeg_file);
list = upper(H); enum = 1; enum_list;

RAW = cell(size(M,1), 1);
for t = 1:size(M,1),
	RAW{t} = str2num(C{RAWWAVE}{t});
end % t

% M_SIGNAL, M_RAW

% Create the matrix M_SIGNAL, which contains all data from the EEG file except raw signal in numeric form
% (Machine name replaced with index of machine in list of machines, dates replaced with date strings, etc.)
% Form of M_SIGNAL: first column has subject ID, second/third have start/end time, remaining ones have EEG feature data
% This version of the loop requires the Excel file to contain the numeric date with just : and / as separators
% (no extra letters or AM/PM), but runs faster than the other one

all_data = {};
for s = unique(M(:,SUBJECT))',
    % grab this subject's data
    I = M(:,SUBJECT) == s;
	M_SIGNAL = M(I,:);
	M_RAW = RAW(I);
    
    % Convert rawwave matrix format into linear stream
    M_RAW_SIGNAL = cell2mat(M_RAW')';
    M_RAW_TIME = nan(size(M_RAW_SIGNAL));
    idx = 1;
    for t = 1:size(M_RAW, 1),
        nsample = length(M_RAW{t});
        if M_SIGNAL(t, SIGQUAL) > sigqual_sample,
            % nan out bad samples
            M_RAW_SIGNAL(idx:idx + nsample - 1) = NaN;
        elseif M_SIGNAL(t, END_TIME) <= M_SIGNAL(t, START_TIME),
            % nan out corrupted time stamps
            M_RAW_SIGNAL(idx:idx + nsample - 1) = NaN;
        else,
            % if the sample is good, add time data
            T = M_SIGNAL(t,START_TIME) + (0:nsample)' .* ( M_SIGNAL(t,END_TIME) - M_SIGNAL(t,START_TIME) ) / nsample;
            M_RAW_TIME(idx:idx + nsample - 1) = T(1:end-1);
        end
        idx = idx + nsample;
    end % t

    % remove all nans (bad values)
    M_RAW_SIGNAL = M_RAW_SIGNAL(~isnan(M_RAW_SIGNAL));
    M_RAW_TIME = M_RAW_TIME(~isnan(M_RAW_TIME));
    
    % write data to the struct
    data.subject = C{SUBJECT}{s};
    data.rawwave.time = M_RAW_TIME;
    data.rawwave.signal = M_RAW_SIGNAL;
    
    all_data{end + 1} = data;
end

out = all_data;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end
