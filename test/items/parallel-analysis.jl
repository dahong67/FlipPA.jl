## Parallel analysis methods

@testitem "PAconfig" begin
    using FlipPA: PAconfig, Pairwise, UpperEdge
    using StableRNGs

    @testset "quantile=$quantile, trials=$trials, cmp=$cmp, seed=$seed" for quantile in
                                                                            0:0.1:1,
        trials in [1, 10, 100],
        cmp in [Pairwise(), UpperEdge()],
        seed in 0:3

        rng = StableRNG(seed)
        @test PAconfig(quantile, trials, cmp, rng) isa
              PAconfig{Float64,Int64,typeof(cmp),StableRNGs.LehmerRNG}
    end
end

@testitem "flippa" begin
    using StableRNGs

    @testset "seed=$seed, signalrank=$k" for seed in 0:2, k in 0:2
        rng = StableRNG(seed)
        n, p = 60, 40

        S = 4 * randn(rng, p, k) * randn(rng, k, n) / sqrt(p * n)
        N = randn(rng, p, n) / sqrt(n)
        X = S + N

        @test flippa(X; rng = StableRNG(seed), trials = 20) == k
        @test flippa(X; rng = StableRNG(seed), trials = 20, quantile = 1) ==
              flippa(X; rng = StableRNG(seed), trials = 20, quantile = 1.0)
        @test flippa(X; rng = StableRNG(seed), trials = 20, quantile = 0) ==
              flippa(X; rng = StableRNG(seed), trials = 20, quantile = 0.0)
    end
end

@testitem "permpa" begin
    using StableRNGs

    @testset "seed=$seed, signalrank=$k" for seed in 0:2, k in 1:2
        rng = StableRNG(seed)
        n, p = 60, 40

        S = 4 * randn(rng, p, k) * randn(rng, k, n) / sqrt(p * n)
        N = randn(rng, p, n) / sqrt(n)
        X = S + N

        @test permpa(X; rng = StableRNG(seed), trials = 20) == k
        @test permpa(X; rng = StableRNG(seed), trials = 20, quantile = 1) ==
              permpa(X; rng = StableRNG(seed), trials = 20, quantile = 1.0)
        @test permpa(X; rng = StableRNG(seed), trials = 20, quantile = 0) ==
              permpa(X; rng = StableRNG(seed), trials = 20, quantile = 0.0)
    end
end
