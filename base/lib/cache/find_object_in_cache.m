function id = find_object_in_cache(desc)
    global CACHE INDEX;
    id = '';
    idx = find(cellfun(@(s) isequal(s, desc), INDEX.desc));
    if ~isempty(idx)
        id = INDEX.files{idx};
        return;
    end
end
