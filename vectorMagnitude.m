function m=vectorMagnitude(t_vector)
sumSquares = 0;
for component =t_vector
    sumSquares = sumSquares + component^2;
end
m = sqrt(sumSquares);
end