function data = vector_to_data(varargin)

feat = varargin{1};
if (length(varargin) > 1)
    out = varargin{2};
    data.task_M = out;
    data.task_H = {'COND'};
end

data.feat_M = feat;
for c = 1:size(data.feat_M, 2)
    data.feat_H{c} = sprintf('feat_%d', c);
end

end

