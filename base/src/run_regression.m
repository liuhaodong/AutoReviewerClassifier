if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

warning off;

[M H T C] = tableread(sprintf('%s/%s', expt.result, 'hof.xls'));

for b = unique(M(:,find(strcmp(H, 'block'))))',
	I = find(M(:,find(strcmp(H, 'block'))) == b);
	fprintf('BLOCK %2d %35s, SCORE1 %d, SCORE2 %d\n', ...
		b, C{find(strcmp(H, 'block'))}{M(I(1), find(strcmp(H, 'block')))}, ...
		M(I(end), find(strcmp(H, 'score1'))), M(I(end), find(strcmp(H, 'score2'))) );
end % b

I = M(:,find(strcmp(H, 'block'))) ~= 5;  % BRA vs GER - -7 game
M = M(I,:);

%I = M(:,find(strcmp(H, 'block'))) ~= 6;  % BRA vs NED - -3 game
%M = M(I,:);

I = M(:,find(strcmp(H, 'block'))) ~= 10; % KOR vs ALG - no dual channel
M = M(I,:);

%I = M(:,find(strcmp(H, 'block'))) ~= 11; % KOR vs BEL - missed first half
%M = M(I,:);

I = M(:,find(strcmp(H, 'block'))) ~= 15; % USA vs POR - no dual channel
M = M(I,:);

% I_FEATURE, I_SIGNAL

I_FEATURE = [];
%I_FEATURE = [I_FEATURE find(strcmp(H, 'stim'))];
I_FEATURE = [I_FEATURE find(strcmp(H, 'block'))];

%I_FEATURE = [I_FEATURE find(strcmp(H, 'cond'))];
%I_FEATURE = [I_FEATURE find(strcmp(H, 'team'))];
%I_FEATURE = [I_FEATURE find(strcmp(H, 'orientation'))];
%I_FEATURE = [I_FEATURE find(strcmp(H, 'goal')):find(strcmp(H, 'misc'))];
%I_FEATURE = [I_FEATURE find(strcmp(H, 'clock'))];

I_SIGNAL = [];
I_SIGNAL = [I_SIGNAL find(strcmp(H, 'SENSOR1_MEAN_BAND_1_3')):find(strcmp(H, 'SENSOR1_MEAN_BAND_30_100'))];
I_SIGNAL = [I_SIGNAL find(strcmp(H, 'SENSOR2_MEAN_BAND_1_3')):find(strcmp(H, 'SENSOR2_MEAN_BAND_30_100'))];
I_SIGNAL = [I_SIGNAL find(strcmp(H, 'ASYMMETRY_ASYM_MEAN_BAND_1_3')):find(strcmp(H, 'ASYMMETRY_ASYM_MEAN_BAND_30_100'))];

blocks = C{find(strcmp(H, 'block'))};

L = H(I_FEATURE);
Y = M(:,I_SIGNAL);
X = M(:,I_FEATURE);

L{end+1} = 'const';
X(:,end+1) = ones(size(X,1), 1);

L{end+1} = 'period';
period = 15;
X(:,end+1) = floor(M(:,find(strcmp(H, 'clock'))) / period) * period;

%L{end+1} = 'scoring';
%X(:,end+1) = M(:,find(strcmp(H, 'goal')));

%L{end+1} = 'shooting';
%X(:,end+1) = sum(M(:,find(strcmp(H, 'deny')):find(strcmp(H, 'kick'))),2);

%L{end+1} = 'fouling';
%X(:,end+1) = sum(M(:,find(strcmp(H, 'offside')):find(strcmp(H, 'card'))),2);

%L{end+1} = 'happy';
%X(:,end+1) = M(:,find(strcmp(H, 'team'))) .* M(:,find(strcmp(H, 'orientation'))) .* M(:,find(strcmp(H, 'goal')));

L{end+1} = 'important';
X(:,end+1) = abs(M(:,find(strcmp(H, 'orientation')))) > 1;

%L{end+1} = 'winning';
%X(:,end+1) = ( M(:,find(strcmp(H, 'score2'))) - M(:,find(strcmp(H, 'score1'))) ) .* sign(M(:,find(strcmp(H, 'orientation'))));

% expanding 1 column of categorial values to multiple columns of binary values

L2 = {};
X2 = [];

for f = 1:size(X,2),
	uXf = nanunique(X(:,f));

	if length(uXf) > 2,
	%if length(uXf) > 2 && ~ismember(L{f}, {'clock', 'period', 'winning'}),
		%for f2 = 1:length(uXf),
		for f2 = 1:length(uXf) - 1,
			temp = zeros(size(X,1), 1);
			temp(X(:,f) == uXf(f2)) = 1;

			L2{end+1} = sprintf('%s_%d', L{f}, uXf(f2));
			X2(:,end+1) = temp; 
		end % f2
	else,
		L2{end+1} = L{f};
		X2(:,end+1) = X(:,f);
	end
end % f

L = L2;
X = X2;

%for f = 1:size(X,2),
	%X(:,f) = (X(:,f) - min(X(:,f))) + 1;
%end % f

%I = ~isnan(sum(M(:,I_SIGNAL),2));
%Y(I,:) = zscore(Y(I,:));

%X = rand(size(X));

clear R;
%for b = unique(M(:,find(strcmp(H, 'block'))))',
for b = 1,
	I = true(size(M,1), 1);
	%I = and(I, M(:,find(strcmp(H, 'block'))) == b);
	I = and(I, sum(isnan([Y X]),2) == 0);

	clear B;
	for c = 1:length(I_SIGNAL),
		[beta bint r rint stats] = regress(Y(I,c), X(I,:));

		B(:,c) = beta;
		R(b,c) = stats(1);
	end % c

	figure;
	imagesc(B); 
	%imagesc(B(find(strcmp(L,'block_14'))+1:end,:)); 
	set(gca, 'YTick', 1:length(L), 'YTickLabel', L);
	%set(gca, 'YTick', 1:length(L(find(strcmp(L,'block_14'))+1:end)), 'YTickLabel', L(find(strcmp(L,'block_14'))+1:end));
	set(gca, 'XTick', 1:length(I_SIGNAL), 'XTickLabel', H(I_SIGNAL));
	title(sprintf('BLOCK %s, N %d', blocks{b}, sum(I)));
	colorbar;
end % b

%Y(1:10,:)
%X(1:10,:)

%reshape(R,5,[])'

[mean(R) min(R) max(R)]
