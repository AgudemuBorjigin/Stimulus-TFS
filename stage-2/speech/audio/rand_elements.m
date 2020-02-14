function subset = rand_elements(list, numel)
% randomly choose numel number of elements from list and returns the subset
indices = randperm(length(list));
indices = indices(1:numel);
subset = list(indices);
end