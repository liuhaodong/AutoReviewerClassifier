function [deep_x, deep_y] = vector_to_deep(varargin)
train_x = varargin{1};
if (length(varargin) > 1)
    train_y = varargin{2};
    if (length(varargin) > 2)
        num_cond = varargin{3};
    else
        num_cond = numel(unique(train_y));
    end
    % convert y to padded version
    train_y_padded = zeros(length(train_y), num_cond);
    for y_i = 1:length(train_y)
        train_y_padded(y_i, train_y(y_i)) = 1;
    end
    deep_y = double(train_y_padded);
end
if isempty(train_x)
    deep_x = [];
    return;
end
% convert x to [0, 1) range
% allow us to deal with outliers
train_max = mean(prctile(train_x,99.9, 2));
train_min = mean(prctile(train_x,0.1, 2));
%train_max = max(max(train_x));
%train_min = min(min(train_x));
train_x = min(train_max, train_x);
train_x = max(train_min, train_x);
train_x = train_x - (train_max + train_min) / 2;
train_x = train_x / (train_max - train_min) + 0.5;
deep_x = double(train_x);

end