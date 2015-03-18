function out = deepapply(nn, train_x)
% convert x to [0, 1) range
train_x = vector_to_deep(train_x);
train_x = train_x';
[~, out, ~] = mynnpredict(nn, train_x);
out = out';
end