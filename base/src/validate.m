function [general_errors, errors] = validate( varargin )

data = varargin{1};

general_errors = {};
errors = [];
for e = 1:size(data.M, 1),
    errors{e}.error = [];
end

% check Rawwave
if isfield(data, 'RAWWAVE'),
    for d = 1:size(data.M, 1),
        if length(data.RAWWAVE(d).time) == 0,
            errors{d}.error{end+1}.type = 'rawwave empty';
        end
    end
else
    general_errors{end+1} = 'no rawwave';
end


% check Epochs
if isfield(data, 'epochs'),
    for d = 1:size(data.M, 1),
        if length(data.epochs{d}) == 0,
            errors{d}.error{end+1} = 'no epochs';
        else
            for e = 1:numel(data.epochs{d}),
                if length(data.epochs{d}(e).time) == 0,
                    errors{d}.error{end+1}.type = 'epoch empty';
                    errors{d}.error{end}.detail = e;
                end
                if ~isfield(data.epochs{d}(e), 'features'),
                    errors{d}.error{end+1} = 'no epoch features';
                    errors{d}.error{end}.detail = e;
                end
            end
        end
    end
else
    general_errors{end+1} = 'no epochs';
end

% check higher order features
if isfield(data, 'higher_order_features'),
    for d = 1:size(data.M, 1),
        if ~isempty(data.higher_order_features(d)),
            errors{d}.error{end+1}.type = 'no features';
        end
    end
else
    general_errors{end+1} = 'no features';
end

% count errors
for e = 1:size(data.M, 1),
    for e2 = 1:numel(errors{e}.error),
        sprintf('task #%d: %s', e, errors{e}.error{e2})
    end
end


end