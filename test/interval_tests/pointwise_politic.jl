# Initially adapted from NumberIntervals.jl
# https://github.com/gwater/NumberIntervals.jl

function istrue(politic, bool)
    if politic == :ternary || politic == :is_all
        return bool
    end

    return true in bool && !(false in bool)
end

isfalse(politic, bool) = !istrue(politic, bool)

function isunkown(politic, bool)
    politic == :ternary && return ismissing(bool)
    politic == :is_all && return !bool

    return true in bool && false in bool
end

@testset "BooleanInterval" begin
    @test true in BooleanInterval(true)
    @test !(false in BooleanInterval(true))
    @test false in BooleanInterval(false)
    @test !(true in BooleanInterval(false))
    @test true in BooleanInterval(true, false)
    @test false in BooleanInterval(true, false)
    @test true in BooleanInterval(missing)
    @test false in BooleanInterval(missing)
    @test_throws ArgumentError BooleanInterval(true, true)
    @test_throws ArgumentError BooleanInterval(false, false)
end

a = Interval(-1, 0)
b = Interval(-0.5, 0.5)
c = Interval(0.5, 2)
d = Interval(0.25, 0.8)
f = Interval(1)
z = zero(Interval{Float64})

for politic in (:is_all, :interval, :ternary)
    @eval istrue(bool) = istrue($(QuoteNode(politic)), bool)
    @eval isfalse(bool) = isfalse($(QuoteNode(politic)), bool)
    @eval isunkown(bool) = isunkown($(QuoteNode(politic)), bool)

    @eval IntervalArithmetic.pointwise_politic() = PointwisePolitic{$(QuoteNode(politic))}()

    @testset ":$politic pointwise politic" begin
        @testset "Number comparison" begin
            @test istrue(a < c)
            @test istrue(c > a)
            @test isunkown(a < b)
            @test isunkown(c > b)
            @test isfalse(c < a)
            @test isfalse(a > c)
            @test istrue(z == z)
            @test istrue(z != c)
            @test isunkown(a == b)
            @test isunkown(b != c)
            @test istrue(b <= c)
            @test isfalse(f < f)
        end

        @testset "Testing for zero" begin
            @test isfalse(iszero(c))
            @test istrue(iszero(z))
            @test isunkown(iszero(a))
            @test isunkown(iszero(b))
        end

        @testset "isinteger" begin
            @test istrue(isinteger(z))
            @test istrue(isinteger(Interval(4)))
            @test isfalse(isinteger(Interval(4.5)))
            @test isunkown(isinteger(c))
            @test isfalse(isinteger(d))
        end

        @testset "isfinite" begin
            @test istrue(isfinite(a))
            @test istrue(isfinite(b))
            @test istrue(isfinite(c))
            @test istrue(isfinite(z))
            # NOTE This depends on the flavor. We test it here for the
            # :set_based flavor only
            @test istrue(isfinite(Interval(0., Inf)))
        end
    end
end

let politic = :ieee1788
    @eval istrue(bool) = istrue($(QuoteNode(politic)), bool)
    @eval isfalse(bool) = isfalse($(QuoteNode(politic)), bool)

    @eval IntervalArithmetic.pointwise_politic() = PointwisePolitic{$(QuoteNode(politic))}()
    @show(IntervalArithmetic.pointwise_politic())
    @testset ":$politic pointwise politic" begin
        @testset "Number comparison" begin
            @test istrue(a < c)
            @test istrue(c > a)
            @test istrue(a < b)
            @test istrue(c > b)
            @test isfalse(c < a)
            @test isfalse(a > c)
            @test istrue(z == z)
            @test istrue(z != c)
            @test isfalse(a == b)
            @test istrue(b != c)
            @test istrue(b <= c)
            @test isfalse(f < f)
        end

        @testset "Testing for zero" begin
            @test isfalse(iszero(c))
            @test istrue(iszero(z))
            @test isfalse(iszero(a))
            @test isfalse(iszero(b))
        end

        @testset "isinteger" begin
            @test istrue(isinteger(z))
            @test istrue(isinteger(Interval(4)))
            @test isfalse(isinteger(Interval(4.5)))
            @test isfalse(isinteger(c))
            @test isfalse(isinteger(d))
        end

        @testset "isfinite" begin
            @test istrue(isfinite(a))
            @test istrue(isfinite(b))
            @test istrue(isfinite(c))
            @test istrue(isfinite(z))
            # NOTE This depends on the flavor. We test it here for the
            # :set_based flavor only
            @test istrue(isfinite(Interval(0., Inf)))
        end
    end
end