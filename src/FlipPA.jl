module FlipPA

## Imports/Exports
using LinearAlgebra: svdvals
using Random: default_rng, shuffle, AbstractRNG
using Statistics: quantile

export flippa, permpa

## Comparison methods
abstract type ComparisonMethods end
struct Pairwise <: ComparisonMethods end
struct UpperEdge <: ComparisonMethods end

function _compare_svdvals(σ, σt, α, ::Pairwise)
    khp1 = findfirst(kp1 -> σ[kp1] <= quantile(getindex.(σt, kp1), α), 1:length(σ))
    return !isnothing(khp1) ? khp1 - 1 : length(σ)
end
function _compare_svdvals(σ, σt, α, ::UpperEdge)
    σt1 = quantile(getindex.(σt, 1), α)
    khp1 = findfirst(kp1 -> σ[kp1] <= σt1, 1:length(σ))
    return !isnothing(khp1) ? khp1 - 1 : length(σ)
end

## Parallel analysis

# Config
struct PAconfig{S<:AbstractFloat,T<:Integer,C<:ComparisonMethods,R<:AbstractRNG}
    quantile::S
    trials::T
    cmp::C
    rng::R

    function PAconfig{S,T,C,R}(quantile::S, trials::T, cmp::C, rng::R) where {S<:AbstractFloat,T<:Integer,C<:ComparisonMethods,R<:AbstractRNG}
        zero(S) <= quantile <= one(S) ||
            throw(DomainError(quantile, "`quantile` must be within [0,1]."))
        zero(T) < trials ||
            throw(DomainError(trials, "`trials` must be positive."))
        return new{S,T,C,R}(quantile, trials, cmp, rng)
    end
end
PAconfig(quantile::S, trials::T, cmp::C, rng::R) where {S<:AbstractFloat,T<:Integer,C<:ComparisonMethods,R<:AbstractRNG} =
    PAconfig{S,T,C,R}(quantile, trials, cmp, rng)

# Signflipping
"""
    flippa(X; quantile=1.0, trials=100, comparison=FlipPA.UpperEdge(), rng=default_rng())

Estimate the signal rank of the data `X` using random signflips.

# Optional keyword arguments
+ `quantile` : quantile for the comparison, `default = 1.0`
+ `trials` : number of signflip trials to run, `default = 100`
+ `comparison` : comparison method to use, `default = FlipPA.UpperEdge()`
+ `rng` : random number generator, `default = default_rng()`
"""
flippa(X::AbstractMatrix; quantile=1.0, trials=100, comparison=UpperEdge(), rng=default_rng()) =
    _flippa(X::AbstractMatrix, PAconfig(convert(AbstractFloat, quantile), trials, comparison, rng))
function _flippa(X::AbstractMatrix, config::PAconfig)
    σ = svdvals(X)
    σt = [svdvals(X .* rand(config.rng, (-1, 1), size(X))) for _ in 1:config.trials]
    return _compare_svdvals(σ, σt, config.quantile, config.cmp)
end

# Permutation
"""
    permpa(X; quantile=1.0, trials=100, comparison=FlipPA.UpperEdge(), rng=default_rng())

Estimate the signal rank of the data `X` by permuting the entries of each column.

# Optional keyword arguments
+ `quantile` : quantile for the comparison, `default = 1.0`
+ `trials` : number of signflip trials to run, `default = 100`
+ `comparison` : comparison method to use, `default = FlipPA.UpperEdge()`
+ `rng` : random number generator, `default = default_rng()`
"""
permpa(X::AbstractMatrix; quantile=1.0, trials=100, comparison=UpperEdge(), rng=default_rng()) =
    _permpa(X::AbstractMatrix, PAconfig(convert(AbstractFloat, quantile), trials, comparison, rng))
function _permpa(X::AbstractMatrix, config::PAconfig)
    σ = svdvals(X)
    σt = [svdvals(mapslices(v -> shuffle(config.rng, v), X, dims=1)) for _ in 1:config.trials]
    return _compare_svdvals(σ, σt, config.quantile, config.cmp)
end

end
