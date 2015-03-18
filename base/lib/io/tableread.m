function [M, H, T, C] = tableread(file, varargin)

delimiter = '	';

NUMERIC = 0;
STRING = 1;
DATENUM = 2;
RAW = 3;

args = varargin;
for i = 1:2:length(args),
	eval(sprintf('%s = args{i+1};', args{i}));
end

lc = linecount(file);
[l0 l1] = lineone(file);
l1_tokens = tokenizer(l1, delimiter);

fid = fopen(file);

% 1. H

line = fgetl(fid);
H = tokenizer(line, delimiter);

for h = 1:length(H),
	if strfind(H{h}, 'rawwave'),
		T(h) = RAW;
	elseif strfind(H{h}, 'time'),
		T(h) = DATENUM;
	elseif strcmp(l1_tokens{h}, 'NaN'),
		T(h) = NUMERIC;
	elseif isnan(str2double(l1_tokens{h})),
		T(h) = STRING;
	else,
		T(h) = NUMERIC;
	end % if
end % h

% 2. M, C

M = nan(lc-1, length(H));
C = cell(lc-1, length(H)); 

i = 0;
while ~feof(fid),
	line = fgetl(fid);
	i = i + 1;

	tokens = tokenizer(line, delimiter);
	
	for j = 1:length(tokens),
		switch T(j),
			case NUMERIC, M(i,j) = str2double(tokens{j});
			case DATENUM, M(i,j) = datenum(tokens{j});
			case STRING, C{i,j} = tokens{j};
			case RAW, C{i,j} = tokens{j};
		end
    end % j
end

for h = 1:length(H),
	switch T(h),
		case STRING, C2{h} = unique(C(:,h));
		case RAW, C2{h} = C(:,h);
		otherwise C2{h} = [];
	end
end % h

for i = 1:size(M,1),
	for j = 1:size(M,2),
		switch T(j),
			case STRING, M(i,j) = find(strcmp(C2{j}, C{i,j}));
		end
	end % j
end % i

C = C2;

fclose(fid);

function [lc] = linecount(file)

fid = fopen(file, 'r');

lc = 0;
while ~feof(fid),
	line = fgetl(fid);
	lc = lc + 1;
end

fclose(fid);

function [l0 l1] = lineone(file)

fid = fopen(file, 'r');

l0 = fgetl(fid);
l1 = fgetl(fid);

fclose(fid);
