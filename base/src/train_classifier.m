function out = train_classifier(varargin)

data = varargin{1};
classifier = varargin{2};
if length(varargin) > 2
    params = varargin{3};
end

train.in = data.feat_M;
train.out = data.task_M(:, strcmp(data.task_H, 'COND'));
ok = 1;

if strcmp(classifier, 'svm'),
    options = optimset('maxiter',10000);
    try,
        c = svmtrain(train.in, train.out,...
            'kernel_function','linear','options', options, 'boxconstraint', 2);
    catch err,
        err
        ok = 0;
        if (strcmp(err.identifier, 'stats:svmtrain:NoConvergence')),
        else,
            error('run_classification.m\between\svm');
        end
    end
elseif strcmp(classifier, 'libsvm'),
    try,
        c = svmtrain(train.out, train.in, '-t 1 -q');
    catch
        ok = 0;
    end
elseif strcmp(classifier, 'deep'),
    c = deeptrain(train.in, train.out, params);
elseif strcmp(classifier, 'ensemble'),
    c = ensembletrain(train.in, train.out);
elseif strcmp(classifier, 'ensembleADA')
    c = adaBoostM1train(train.in, train.out, params);
elseif strcmp(classifier, 'ensembleADA2')
    c = adaBoostertrain(train.in, train.out, params);
elseif strcmp(classifier, 'dbn'),
    c = deepbelieftrain(train.in, train.out, params);
elseif strcmp(classifier, 'dtree'),
    c = dtreetrain(train.in, train.out);
elseif strcmp(classifier, 'stack'),
    c = stacktrain(train.in, train.out, params);
    elseif strcmp(classifier, 'stackADA'),
    c = stacktrainADA(train.in, train.out, params);
else
    try,
		c = trainClassifier(train.in, train.out, classifier);
	catch
		ok = 0;
	end
end

c_struct.type = classifier;
c_struct.ok = ok;
if c_struct.ok == 1,
    c_struct.classifier = c;
    c_struct.num_classes = length(unique(data.task_M(:,strcmp(data.task_H, 'COND'))));
end

out = c_struct;

end
