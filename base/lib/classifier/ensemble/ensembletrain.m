function classifier_struct = ensembletrain(feat, out)

classifiers = {};
num_classifiers = 5;
train_size = 0.50;

for c = 1:num_classifiers,
    num_rows = size(feat, 1);
    idx = randsample(1:num_rows, ceil(train_size * num_rows));
    feat_c = feat(idx, :);
    out_c = out(idx, :);
    classifiers{c} = train_classifier(vector_to_data(feat_c, out_c), 'libsvm');
end

classifier_struct.classifiers = classifiers;

end