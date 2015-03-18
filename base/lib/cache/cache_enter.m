function [INTERN_success, INTERN_cache_desc, args] = cache_enter(args)
    
    global CACHE EXPERIMENTAL;
    INTERN_cache_desc.vars = args;
    INTERN_success = -1;
    if exist('CACHE', 'var') && ~strcmp(CACHE, ''),
        INTERN_cache_desc.vars = args;
        [INTERN_ST,INTERN_I] = dbstack;
        INTERN_cache_desc.INTERN_name = INTERN_ST(2).name;
        text = fileread(INTERN_ST(2).file);
        INTERN_cache_desc.INTERN_hash = string2hash(text);
        if ~isempty(find(strcmp(EXPERIMENTAL, INTERN_cache_desc.INTERN_name)))
            INTERN_cache_desc.INTERN_experimental = 1;
        end
        [INTERN_success, args] = read_cache(INTERN_cache_desc);
    end
end

function [success, vars] = read_cache(cache_desc)
    success = 0;
    vars = cache_desc.vars;
    if ~strcmp(find_object_in_cache(cache_desc), ''),
        success = 1;
        return;
    end
    
    for i = 1:numel(vars),
        v = vars{i};
        vars{i} = load_cached_object(v);
    end
end