function out = apply_classifier(varargin)

data = varargin{1};
c = varargin{2};
if length(varargin) > 2
    params = varargin(3);
end
feats = data.feat_M;
results = zeros(size(data.feat_M, 1), c.num_classes);

if strcmp(c.type, 'svm')
    predictions = svmclassify(c.classifier, feats);
    for p = 1:numel(predictions)
        results(p, predictions(p)) = 1;
    end
elseif strcmp(c.type, 'libsvm')
    [predictions, acc, dec] = svmpredict(zeros(size(feats, 1), 1), feats, c.classifier, '-q');
    for p = 1:numel(predictions)
        results(p, predictions(p)) = 1;
    end
elseif strcmp(c.type, 'deep'),
    results = deepapply(c.classifier, feats);
elseif strcmp(c.type, 'ensemble'),
    results = ensembleapply(c.classifier, feats);
elseif strcmp(c.type, 'ensembleADA'),
    results = adaapply(c.classifier,feats);
elseif strcmp(c.type, 'ensembleADA2'),
    results = ada2apply(c.classifier,feats);    
elseif strcmp(c.type, 'dbn'),
    predictions = deepbeliefapply(c.classifier, feats);
    for p = 1:numel(predictions)
        results(p, predictions(p)) = 1;
    end
elseif strcmp(c.type, 'dtree'),
    results = dtreeapply(c.classifier,feats);
elseif strcmp(c.type, 'stack'),
    predictions = stackapply(c.classifier, feats);
    for p = 1:numel(predictions)
        results(p, predictions(p)) = 1;
    end
elseif strcmp(c.type, 'stackADA'),
    predictions = stackapplyADA(c.classifier, feats);
    for p = 1:numel(predictions)
        results(p, predictions(p)) = 1;
    end
else
    results = applyClassifier(feats, c.classifier);
end

out = results;

end

