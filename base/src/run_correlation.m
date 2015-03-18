if exist('VERBOSE', 'var') && ~isempty(strfind(VERBOSE, '-printTicToc')),
	fprintf('FUNCTION %s, TOC %.2f min\n', mfilename, toc / 60);
end

[M H T C] = tableread(sprintf('%s/%s', expt.result, 'hof.xls'));

% I_FEATURE, I_SIGNAL

%I_FEATURE = find(strcmp(H, 'cond')):find(strcmp(H, 'clock'));
I_FEATURE = find(strcmp(H, 'orientation')):find(strcmp(H, 'clock'));
%I_FEATURE = find(strcmp(H, 'goal')):find(strcmp(H, 'clock'));

%I_SIGNAL = find(strcmp(H, 'SENSOR1_MEAN_BAND_1_3')):find(strcmp(H, 'SENSOR1_MEAN_BAND_30_100'));
%I_SIGNAL = [find(strcmp(H, 'SENSOR1_MEAN_BAND_1_3')):find(strcmp(H, 'SENSOR1_MEAN_BAND_30_100')) find(strcmp(H, 'SENSOR2_MEAN_BAND_1_3')):find(strcmp(H, 'SENSOR2_MEAN_BAND_30_100'))];
I_SIGNAL = [find(strcmp(H, 'SENSOR1_MEAN_BAND_1_3')):find(strcmp(H, 'SENSOR1_MEAN_BAND_30_100')) find(strcmp(H, 'SENSOR2_MEAN_BAND_1_3')):find(strcmp(H, 'SENSOR2_MEAN_BAND_30_100')) find(strcmp(H, 'ASYMMETRY_ASYM_MEAN_BAND_1_3')):find(strcmp(H, 'ASYMMETRY_ASYM_MEAN_BAND_30_100'))];

blocks = C{find(strcmp(H, 'block'))};

%for b = unique(M(:,find(strcmp(H, 'block'))))',
for b = 1,
	I = true(size(M,1), 1);
	%I = and(I, M(:,find(strcmp(H, 'block'))) == b);
	I = and(I, sum(isnan(M(:,[I_SIGNAL I_FEATURE])),2) == 0);

	C = 1 - squareform(nanpdist(M(I,:)', 'correlation'));

	figure;
	imagesc(C(I_FEATURE,I_SIGNAL)); 
	title(sprintf('BLOCK %s, N %d', blocks{b}, sum(I)));
	set(gca, 'YTick', 1:length(I_FEATURE), 'YTickLabel', H(I_FEATURE));
	set(gca, 'XTick', 1:length(I_SIGNAL), 'XTickLabel', H(I_SIGNAL));
	colorbar;
end % b
