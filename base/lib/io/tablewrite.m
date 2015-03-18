function tablewrite(file, M, H, T, C)

NUMERIC = 0;
STRING = 1;
DATENUM = 2;

fid = fopen(file, 'w');

for h = 1:length(H),
	fprintf(fid, '%s', H{h});

	if h ~= length(H), fprintf(fid, '\t'); end
end % h

fprintf(fid, '\n');

for i = 1:size(M,1),
	for j = 1:size(M,2),
		switch T(j),
		case NUMERIC, fprintf(fid, '%.4f', M(i,j));
		case STRING, temp = C{j}(M(i,j)); fprintf(fid, '%s', temp{:});
		case DATENUM, fprintf(fid, '%s', datestr(M(i,j), 'yyyy-mm-dd HH:MM:SS.FFF'));
		end

		if j ~= size(M,2), fprintf(fid, '\t'); end
	end % i
	fprintf(fid, '\n');
end % j

fclose(fid);
