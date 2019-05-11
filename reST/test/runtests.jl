using Test: @testset, @test, @test_skip

# tools
using Test: @inferred

# test others
using Test: @test_throws, @test_logs, @test_deprecated, @test_warn, @test_nowarn, @test_broken

@time using PyCall

include("./test_tables.jl")
