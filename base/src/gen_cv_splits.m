function out = gen_cv_splits(varargin)

global DEBUG VERBOSE;

if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

% Start Cache
[success, INTERN_cache_desc, varargin] = cache_enter(varargin);
if (success) == 1, out = INTERN_cache_desc; return; end;

data = varargin{1};
cv = varargin{2};
cv_subjects = varargin{3};

H = data.task_H;
M = data.task_M;
list = H; enum = 1; enum_list;

splits = struct('train', {}, 'test', {});
subjects = unique(M(:, SUBJECT));
classes = length(unique(data.task_M(:,strcmp(data.task_H, 'COND'))));

subject_splits = {};
switch cv_subjects,
    case 'within',
        for s = 1:length(subjects),
            subject_splits{end+1} = M(:,SUBJECT) == subjects(s);
        end
    case 'between',
        for s = 1:length(subjects),
            I = M(:,SUBJECT) ~= subjects(s);
            splits(end+1).train = find(I);
            splits(end).test = find(~I);
        end
    otherwise,
        subject_splits{end+1} = logical(ones(size(M, 1), 1));
end

if ~strcmp(cv_subjects, 'between')
    for s = 1:length(subject_splits)
        I = subject_splits{s};
        is = find(I);
        tasks = unique(M(I, TASK));
        blocks = unique(M(I, BLOCK));
        switch cv,
            case 'leave-one-out',
                for i = 1:length(tasks),
                    t = tasks(i);
                    I_t = M(I, TASK) == t;
                    train = I;
                    train(is(I_t)) = 0;
                    test = zeros(length(I), 1);
                    test(is(I_t)) = 1;
                    splits(end+1).train = find(train);
                    splits(end).test = find(test);
                end
            case 'block',
                for i = 1:length(blocks),
                    b = blocks(i);
                    I_t = M(I, BLOCK) == b;
                    train = I;
                    train(is(I_t)) = 0;
                    test = zeros(length(I), 1);
                    test(is(I_t)) = 1;
                    splits(end+1).train = find(train);
                    splits(end).test = find(test);
                end
            case 'random-split',
                test_I = sort(randsample(1:length(is), floor(length(is) * 0.3)));
                test = is(test_I);
                train = is;
                train(test_I) = [];
                splits(end+1).train = train;
                splits(end).test = test;
            case 'random-block',
                test_blocks = sort(randsample(blocks, floor(length(blocks) * 0.3)));
                I_t = ismember(M(I, BLOCK), test_blocks);
                train = I;
                train(is(I_t)) = 0;
                test = zeros(length(I), 1);
                test(is(I_t)) = 1;
                splits(end+1).train = find(train);
                splits(end).test = find(test);
        end
    end
end

% remove underspecified cv folds
i = 1;
while i <= length(splits)
    cv = splits(i);
    if length(unique(M(cv.train, COND))) < classes,
        splits(i) = [];
        continue;
    end
    i = i + 1;
end

out = splits;

% End Cache
out = cache_exit(INTERN_cache_desc, out);
end

