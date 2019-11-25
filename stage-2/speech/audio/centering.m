function b = centering(a, b)
lenDiff = length(a) - length(b);
if rem(lenDiff, 2)
    b = [zeros(fix(lenDiff/2), 1);b;zeros(fix(lenDiff/2)+1, 1)];  
else
    b = [zeros(lenDiff/2, 1);b;zeros(lenDiff/2, 1)];  
end
end