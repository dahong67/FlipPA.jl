## Comparison methods

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
