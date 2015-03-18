function [out] = read_task(varargin)

% Input:
%
% expt.task_file
% expt.cache
% expt.cache_task
%
% Output:
%
% H
% M
% expt.machines
% expt.subjects
% expt.blocks

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
    fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

task_file = varargin{1};

[M H T C] = tableread(task_file);
list = upper(H); enum = 1; enum_list;

task.M = M;
task.H = H;
task.T = T;
task.C = C;

for t = 1:size(M, 1),
    task.TASK(t) = t;
end % t

out = task;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end
