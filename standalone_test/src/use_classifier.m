function use_classifier(expt)
run_setup;
data = run_prepare_data(expt);
data = load_cached_object(data);
c = load(sprintf('%s/c.mat', expt.result));
results = apply_classifier(data, c.trained_classifier, expt.classifier.params);
tasks_idxs = data.task_M(:, strcmp(data.task_H, 'TASK'));
results = horzcat(tasks_idxs, results);
csvwrite('outs.csv', results);
end
