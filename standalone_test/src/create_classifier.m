function create_classifier(expt)
run_setup;
data = run_prepare_data(expt);
data = load_cached_object(data);
trained_classifier = train_classifier(data, expt.classifier.name, expt.classifier.params);
save(sprintf('%s/c.mat', expt.result), 'trained_classifier');
end
