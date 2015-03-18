function postprocess_results(varargin)

data = varargin{1};
result_folder = varargin{2};
result_file = varargin{3};

% 0. task

task_file = sprintf('%s/%s.xls', result_folder, result_file);

[M H T C] = tableread(task_file);
list = upper(H); enum = 1; enum_list;

if exist(sprintf('%s/mapping.xls', '../data/'), 'file'),
	mapping_file = sprintf('%s/mapping.xls', '../data/');
	[mapping.user_id mapping.subject] = textread(mapping_file, '%s %s', 'headerlines', 1);

	student_file = sprintf('%s/student.xls', '../data/');
	[student.user_id student.num_eeg student.reading_level student.age] = textread(student_file, '%s %d %d %d', 'headerlines', 1);

	subject = hashtable;

	for s = 1:length(mapping.subject),
		s2 = strlocate(mapping.user_id(s), student.user_id);

		temp = struct;
		temp.user_id = student.user_id{s};
		temp.num_eeg = student.num_eeg(s);
		temp.reading_level = student.reading_level(s);
		temp.age = student.age(s);

		subject(mapping.subject{s}) = temp;
	end % s
end % exist

% Overall

I_notnan = ~isnan(M(:,Y));
I = I_notnan;

N = sum(I);
ACC = mean(M(I,Y) == M(I,EY));

score = M(I,RESULTS(2)) - M(I,RESULTS(1));
[X0,Y0,T0,AUC0] = perfcurve(M(I,Y), ones(size(score)), 2);
[X1,Y1,T1,AUC1] = perfcurve(M(I,Y), score, 2);

fprintf('\n');
fprintf('SUBJECT %s, N %d, ACC %.4f, AUC %.4f\n', 'AVG', N, ACC, AUC1);

return

hid = figure;
hold all;
plot(X0,Y0,'--k');
plot(X1,Y1,'--r');
hold off;

title('ROC');
ylabel('True positive rate');
xlabel('False positive rate');
legend(sprintf('MODEL %s, AUC = %.4f', 'Majority', AUC0), ...
		sprintf('MODEL %s, AUC = %.4f', 'Classifier', AUC1) );

roc_tif = sprintf('%s/%s.roc.%s.tif', result_folder, mfilename, result_file);
saveas(hid, roc_tif);
return
% 1. Subject

fprintf('\n');

subject_result_file = sprintf('%s/%s.subject.%s.xls', result_folder, mfilename, result_file);
fid = fopen(subject_result_file, 'w');
%fprintf(fid, 'SUBJECT\tN\tACC\tAUC\n');
fprintf(fid, 'SUBJECT\tN\tACC\tAUC\tNUM_EEG\tREADING_LEVEL\tAGE\tUSER_ID\n');

X_subject = [];
for s = nanunique(M(:,SUBJECT))',
	I_within = M(:,SUBJECT) == s;
	I = and(I_within, I_notnan);

	if sum(I) == 0, continue; end;

	N = sum(I);
	ACC = mean(M(I,Y) == M(I,EY));
	[X1,Y1,T1,AUC1] = perfcurve(M(I,Y), M(I,RESULTS(2)) - M(I,RESULTS(1)), 2);

	if exist('subject', 'var'),
		temp = subject(mapping.subject{s});
		num_eeg = temp.num_eeg;
		reading_level = temp.reading_level;
		age = temp.age;
		user_id= temp.user_id;

		X_subject(end+1,:) = [s, N, ACC, AUC1, num_eeg, reading_level, age];

		fprintf('SUBJECT %d, N %d, ACC %.4f, AUC %.4f, NUM_EEG %d, READING_LEVEL %d, AGE %d, USER_ID %s\n', s, N, ACC, AUC1, num_eeg, reading_level, age, user_id);
		fprintf(fid, '%d\t%d\t%.4f\t%.4f\t%d\t%d\t%d\t%s\n', s, N, ACC, AUC1, num_eeg, reading_level, age, user_id);

	else,
		X_subject(end+1,:) = [s, N, ACC, AUC1];

		fprintf('SUBJECT %d, N %d, ACC %.4f, AUC %.4f\n', s, N, ACC, AUC1);
		fprintf(fid, '%d\t%d\t%.4f\t%.4f\n', s, N, ACC, AUC1);

	end % exist

end % s

fclose(fid);

hid = figure;

[dummy I] = sort(X_subject(:,2), 'descend');
X_subject = X_subject(I,:);

x = 1:size(X_subject(:,1));
y1 = X_subject(:,2);
y2 = X_subject(:,[3 4]);

[hAx, hLine1, hLine2] = plotyy(x, y1, x, y2, 'bar', 'plot');

set(hLine2(1), 'color', 'green');
set(hLine2(2), 'color', 'red');
set(hAx, {'ycolor'}, {'b';'r'})

title('Subject');
ylabel(hAx(1), 'Number of trials');
ylabel(hAx(2), 'ACC (green) / AUC (red)');
xlabel('Subject');

subject_tif = sprintf('%s/%s.subject.%s.tif', result_folder, mfilename, result_file);
saveas(hid, subject_tif);

% 2. Longitudinal

fprintf('\n');

longitudinal_result_file = sprintf('%s/%s.longitudinal.%s.xls', result_folder, mfilename, result_file);
fid = fopen(longitudinal_result_file, 'w');
fprintf(fid, 'YEAR\tMONTH\tN\tACC\tAUC\n');

%ts = timeseries(M(:,Y) == M(:,EY), datestr(M(:,START_TIME)));
%ts.Name = 'Accuracy';
%ts.TimeInfo.Units = 'months';
%plot(ts);

V = cellstr(datestr(M(:,START_TIME), 'yyyy-mm'));

X_longitudinal = [];
for v = unique(V)',
	I_time = strcmp(v{:}, V);
	I = and(I_time, I_notnan);

	[year month day hour min sec] = datevec(v{:});

	if length(unique(M(I,Y))) < 2,
		N = NaN;
		ACC = NaN;
		AUC1 = NaN;
	else,
		N = sum(I);
		ACC = mean(M(I,Y) == M(I,EY));
		[X1,Y1,T1,AUC1] = perfcurve(M(I,Y), M(I,RESULTS(2)) - M(I,RESULTS(1)), 2);
	end

	X_longitudinal(end+1,:) = [year, month, N, ACC, AUC1];

	fprintf('YEAR %d, MONTH %d, N %d, ACC %.4f, AUC %.4f\n', year, month, N, ACC, AUC1);
	fprintf(fid, '%d\t%d\t%d\t%.4f\t%.4f\n', year, month, N, ACC, AUC1);
end % v

fclose(fid);

hid = figure;

x = 1:size(X_longitudinal(:,1));
y1 = X_longitudinal(:,3);
y2 = X_longitudinal(:,[4 5]);

[hAx, hLine1, hLine2] = plotyy(x, y1, x, y2, 'bar', 'plot');

set(hAx, 'XTick', 1:length(x));
set(hAx, 'XTickLabel', unique(V));
set(hLine2(1), 'color', 'green');
set(hLine2(2), 'color', 'red');
set(hAx, {'ycolor'}, {'b';'r'})

title('Longitudinal');
ylabel(hAx(1), 'Number of trials');
ylabel(hAx(2), 'ACC (green) / AUC (red)');
xlabel('Date');

longitudinal_tif = sprintf('%s/%s.longitudinal.%s.tif', result_folder, mfilename, result_file);
saveas(hid, longitudinal_tif);
