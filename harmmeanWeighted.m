% WeightedHarmonicMean = harmmeanWeighted(X, Weight)
function WeightedHarmonicMean = harmmeanWeighted(X, Weight)
    if isempty(X) || isempty(Weight) || ~isnumeric(X) || ~isnumeric(Weight)
        error('A certain input is empty or not numeric.');
    end
    X = reshape(X, 1, []);
    if any(X == 0)
        error('X contains 0.');
    end
    Weight = reshape(Weight, 1, []);
    if any(Weight < 0)
        error('The weight list contains negative value(s).');
    end
    if (sum(Weight) ~= 1)
        error('The sum of weight(s) is not equal to 1.')
    end
    if (length(X) ~= length(Weight))
        error('Value(s) and weight(s) are not paired.');
    end
    
    WeightedHarmonicMean = 1 / ((1 ./ X) * Weight');
end
