function load_cache()
global CACHE INDEX;
    
index_loc = sprintf('%s/index.mat', CACHE);
INDEX.desc = {};
INDEX.files = {};
if exist(index_loc, 'file'),
    load(index_loc);
    INDEX = index;
end
end

