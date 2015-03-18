function classifier_struct = dtreetrain(feat, out)

% Many customizable possibilities in terms of name/value pairs
classifier_struct = classregtree(feat,cellstr(num2str(out(:))));
end