function out = cache_exit(INTERN_cache_desc, out)
    global CACHE;
    if exist('CACHE', 'var') && ~strcmp(CACHE, ''),
        write_cache(INTERN_cache_desc, out);
        out = INTERN_cache_desc;
    end
end

function write_cache(desc, data)
    global CACHE INDEX;
    
    unixtime = int32(floor(86400 * (datenum(now()) - datenum('01-Jan-1970'))));
    filename = sprintf('%s.%d.mat', desc.INTERN_name, unixtime);
    save(sprintf('%s/%s', CACHE, filename), 'data', '-v7.3');
    INDEX.desc{end+1} = desc;
    INDEX.files{end+1} = filename;
    index = INDEX;
    save(sprintf('%s/index.mat', CACHE), 'index', '-v7.3');
end
