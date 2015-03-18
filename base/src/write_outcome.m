function write_outcome(desc, outcome)
fname = 'outcome.csv';
if exist(fname, 'file')
    fid = fopen(fname, 'ab+');
else
    fid = fopen(fname, 'wb');
    fprintf(fid, 'desc,time,acc,p,f1,matthews\n');
end
fprintf(fid, '%s,%s,%.2f,%.2f,%.2f,%.2f\n', desc, datestr(now), outcome.acc, outcome.p, outcome.f1, outcome.matthews);
fclose(fid);
end