function I_c = visualize(varargin)
data = varargin{1};
% remove nans
I_c = [];

if (numel(varargin) > 2)
    I_c{1} = varargin{2};
    I_c{2} = varargin{3};
else
    if (numel(varargin) > 1),
        I = varargin{2};
    else
        I = ~isnan(data.Y);
    end
    classes = unique(data.Y(I));
    classes = classes(~isnan(classes));
    for c_i = 1:length(classes),
        c = classes(c_i);
        I_c{end+1} = find(data.Y == c);
        classnames{c_i} = sprintf('%d', data.cond_dict(sprintf('%d', c)));
    end
end

% expand feature matrix
feat_M = nan(numel(data.Y), numel(data.feat_H));
I_TASK = find(strcmp(data.task_H, 'TASK'));
for f = 1:size(data.feat_M, 1)
    feat_M(data.task_M(f, I_TASK), :) = data.feat_M(f, :);
end

figure(1);
% feature plot
plot_x = nan(numel(I_c), size(feat_M, 2));
for c = 1:numel(I_c)
    plot_x(c, :) = sum(feat_M(I_c{c}, :), 1);
end
bar(plot_x');
set(gca,'XTickLabel', data.feat_H);


title('Feature plot');
ylabel('Value');
xlabel('Features');
legend(classnames);

figure(2);
% rawwave plot
waves = {};
counts = {};
for c = 1:numel(I_c)
    waves{c} = [];
    counts{c} = [];
    for s = 1:numel(data.sensors),
        for d = 1:numel(I_c{c})
            signal = data.sensors(s).RAWWAVE(I_c{c}(d)).signal;
            if (length(signal) > length(waves{c})),
                waves{c} = vertcat(waves{c}, zeros(length(signal) - length(waves{c}), 1));
                counts{c} = vertcat(counts{c}, zeros(length(signal) - length(counts{c}), 1));
            end
            waves{c}(1:length(signal)) = signal + waves{c}(1:length(signal));
            counts{c}(1:length(signal)) = ~isnan(signal) + counts{c}(1:length(signal));
        end
        waves{c} = waves{c}./counts{c};
        subplot(length(I_c), numel(data.sensors), c);
        plot(1:length(waves{c}), waves{c});
    end

	title(sprintf('Rawwave plot, Class %s', classnames{c}));
	ylabel('Amplitude');
	xlabel('Sample');
end

end
