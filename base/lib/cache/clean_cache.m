function clean_cache()
    global CACHE INDEX;
    
    newIndex.desc = {};
    newIndex.files = {};
    for i = 1:numel(INDEX.desc)
        desc = INDEX.desc{i};
        fname = sprintf('%s/%s', CACHE, INDEX.files{i});
        if ~exist(fname, 'file'),
            continue;
        end
        if is_experimental(desc) == 1,
            continue;
        end
        newIndex.desc{end+1} = INDEX.desc{i};
        newIndex.files{end+1} = INDEX.files{i};
    end
    INDEX = newIndex;
end

function experimental = is_experimental(desc)
    experimental = 0;
    if isfield(desc, 'INTERN_experimental')
        experimental = 1;
        return;
    end
    if isfield(desc, 'vars')
        for i = 1:numel(desc.vars)
            experimental = experimental + is_experimental(desc.vars{i});
        end
    end
end
        
            
        