function out = describe_task(varargin)
%DESCRIBE_TASK Summary of this function goes here
%   Detailed explanation goes here
data = varargin{1};
t = varargin{2};

plot_rows = 5;
sensor_cnt = length(data.sensors);
for s = 1:sensor_cnt
    sensor = data.sensors(s);
    figure(3);
    
	% unsmoothed eeg
    subplot(plot_rows, sensor_cnt, 1 * sensor_cnt + (s - 1));
    plot(sensor.RAWWAVE(t).time, sensor.RAWWAVE(t).unsmoothed);
    set(gca, 'XTickLabel', '')
    xlabel(sprintf('Time (%s to %s)', datestr(min(sensor.RAWWAVE(t).time)), datestr(max(sensor.RAWWAVE(t).time))));
    title('unsmoothed eeg');
    unsmoothed_ylim = ylim

	% smoothed eeg

    subplot(plot_rows, sensor_cnt, 2 * sensor_cnt + (s - 1));
    plot(sensor.RAWWAVE(t).time, sensor.RAWWAVE(t).signal);
    set(gca, 'XTickLabel', '')
    xlabel(sprintf('Time (%s to %s)', datestr(min(sensor.RAWWAVE(t).time)), datestr(max(sensor.RAWWAVE(t).time))));
    title('smoothed eeg');
    ylim(unsmoothed_ylim);

    epochs = sensor.epochs{t};

    if length(epochs) > 0
        epoch_x = nan(length(epochs), length(sensor.RAWWAVE(t).time));
        epoch_y = epoch_x;

        for e = 1:length(epochs),
            epoch = epochs(e);
            epoch_x(e, 1:length(epoch.time)) = epoch.time;
            epoch_y(e, 1:length(epoch.signal)) = epoch.signal;
        end

		% epochs

        subplot(plot_rows, sensor_cnt, 3 * sensor_cnt + (s - 1));
        plot(epoch_x', epoch_y'); 
        out = epoch_y;
        xlabel(sprintf('Time (%s to %s)', datestr(min(sensor.RAWWAVE(t).time)), datestr(max(sensor.RAWWAVE(t).time))));
        title('epochs');
        ylim(unsmoothed_ylim);

		% epoch features

        epoch_feats_H = fieldnames(epochs(1).features);
        epoch_feats = nan(length(epochs), length(epoch_feats_H));
        for e = 1:length(epochs),
            epoch = epochs(e);
            for f = 1:length(epoch_feats_H)
                epoch_feats(e, f) = epoch.features.(epoch_feats_H{f});
            end
        end
        subplot(plot_rows, sensor_cnt, 4 * sensor_cnt + (s - 1));
        bar(epoch_feats);
        legend(epoch_feats_H);
        title('epoch features');
    end

	% task features

    feats = sensor.higher_order_features{1};
    feats_H = fieldnames(feats);
    feats_M = nan(length(feats_H), 1);
    for f = 1:numel(feats_H)
        feats_M(f) = feats.(feats_H{f});
    end
    subplot(plot_rows, sensor_cnt, 5 * sensor_cnt + (s - 1));
    bar(feats_M);
    set(gca,'XTickLabel', feats_H);
    title('task features');
end
