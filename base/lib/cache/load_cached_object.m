function data = load_cached_object(desc)
    if (~isfield(desc, 'INTERN_name')),
        data = desc;
        return; % this is not a cache descriptor
    end
    
    global CACHE;
    id = find_object_in_cache(desc);
    if strcmp(id, ''),
        error('object should be cached but is not found');
    end
    fname = sprintf('%s/%s', CACHE, id);
    if exist(fname, 'file'),
        load(fname);
    end
end
