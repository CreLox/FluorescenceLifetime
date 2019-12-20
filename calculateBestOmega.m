% BestOmega = calculateBestOmega(ResolveDecayTimeLowLimit,
% ResolveDecayTimeHighLimit)
function BestOmega = calculateBestOmega(ResolveDecayTimeLowLimit, ...
    ResolveDecayTimeHighLimit)
    BestOmega = 1 / sqrt(ResolveDecayTimeLowLimit * ...
        ResolveDecayTimeHighLimit);
end
