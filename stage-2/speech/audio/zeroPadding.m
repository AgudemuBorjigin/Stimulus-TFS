function [a, b] = zeroPadding(a, b)
if length(a) > length(b)
    b = [b; zeros(length(a) - length(b), 1)];
else
    a = [a; zeros(length(b) - length(a), 1)];
end
end