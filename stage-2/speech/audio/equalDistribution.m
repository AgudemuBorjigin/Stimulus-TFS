function list = equalDistribution(totaltrials, nelements)
if fix(totaltrials/nelements) < 1
    list = 1:totaltrials;
else
    list = repmat(1:nelements, 1, fix(totaltrials/nelements));
    list = [list, 1:mod(totaltrials, nelements)];
end
end