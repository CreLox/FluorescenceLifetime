% WeightedHarmonicMean = harmmeanWeighted(X, Weight)
function WeightedHarmonicMean = harmmeanWeighted(X, Weight)
    if isempty(X) || isempty(Weight) || ~isnumeric(X) || ~isnumeric(Weight)
        error('some input is empty or not numeric.');
    end
    X = reshape(X, 1, []);
    Weight = reshape(Weight, 1, []);
    
    if any(Weight < 0)
        error('some weight is negative.');
    end
    if (sum(Weight) ~= 1)
        error('sum of weight(s) is not equal to 1.')
    end
    if (length(X) ~= length(Weight))
        error('value(s) and weight(s) are not paired.');
    end
    
    WeightedHarmonicMean = 1 / ((1 ./ X) * Weight');
end
