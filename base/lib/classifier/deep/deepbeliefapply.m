function predictions = deepbeliefapply(classifier_struct, feat)
feat = vector_to_deep(feat);
predictions = nnpredict(classifier_struct, feat);
end