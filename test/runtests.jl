using FlipPA
using Test
using FlipPA: Pairwise, UpperEdge, _compare_svdvals
using FlipPA: PAconfig
using StableRNGs

@testset "Comparison methods" begin
    # Low-rank where stopping at first violation != counting nonviolations
    σ = 4:-0.1:1
    σt = [[σ[1:3] .+ t; σ[4]; σ[5:end] .+ t] for t in -0.5:0.1:0.5]

    @testset "Pairwise: $(i/10) <= quantile < $((i+1)/10)" for i in 0:9
        @test _compare_svdvals(σ, σt, i / 10, Pairwise()) == (i < 5 ? 3 : 0)
        @test _compare_svdvals(σ, σt, (i + 1) / 10 - 1e-10, Pairwise()) == (i < 5 ? 3 : 0)
    end
    @testset "Upperedge: $(i/10) <= quantile < $((i+1)/10)" for i in 0:9
        @test _compare_svdvals(σ, σt, i / 10, UpperEdge()) == max(5 - i, 0)
        @test _compare_svdvals(σ, σt, (i + 1) / 10 - 1e-10, UpperEdge()) == max(5 - i, 0)
    end

    # Full-rank where all are selected
    σ = 4:-0.1:3.6
    σt = [σ .+ t for t in -0.5:0.1:0.5]

    @test _compare_svdvals(σ, σt, 0, Pairwise()) == length(σ)
    @test _compare_svdvals(σ, σt, 0, UpperEdge()) == length(σ)
end

@testset "Parallel analysis methods" begin
    @testset "Config" begin
        @testset "quantile=$quantile, trials=$trials, cmp=$cmp, seed=$seed" for quantile in 0:0.1:1, trials in [1, 10, 100], cmp in [Pairwise(), UpperEdge()], seed in 0:3

            rng = StableRNG(seed)
            @test PAconfig(quantile, trials, cmp, rng) isa PAconfig{Float64,Int64,typeof(cmp),StableRNGs.LehmerRNG}
        end
    end

    @testset "flippa" begin
        @testset "seed=$seed, signalrank=$k" for seed in 0:2, k in 0:2
            rng = StableRNG(seed)
            n, p = 60, 40

            S = 4 * randn(rng, p, k) * randn(rng, k, n) / sqrt(p * n)
            N = randn(rng, p, n) / sqrt(n)
            X = S + N

            @test flippa(X; rng=StableRNG(seed), trials=20) == k
            @test flippa(X; rng=StableRNG(seed), trials=20, quantile=1) == flippa(X; rng=StableRNG(seed), trials=20, quantile=1.0)
            @test flippa(X; rng=StableRNG(seed), trials=20, quantile=0) == flippa(X; rng=StableRNG(seed), trials=20, quantile=0.0)
        end
    end

    @testset "permpa" begin
        @testset "seed=$seed, signalrank=$k" for seed in 0:2, k in 1:2
            rng = StableRNG(seed)
            n, p = 60, 40

            S = 4 * randn(rng, p, k) * randn(rng, k, n) / sqrt(p * n)
            N = randn(rng, p, n) / sqrt(n)
            X = S + N

            @test permpa(X; rng=StableRNG(seed), trials=20) == k
            @test permpa(X; rng=StableRNG(seed), trials=20, quantile=1) == permpa(X; rng=StableRNG(seed), trials=20, quantile=1.0)
            @test permpa(X; rng=StableRNG(seed), trials=20, quantile=0) == permpa(X; rng=StableRNG(seed), trials=20, quantile=0.0)
        end
    end
end
