# This file is part of the IntervalArithmetic.jl package; MIT licensed

#=  This file contains the functions described in sections 9.3 of the
    IEEE Std 1788-2015 (Set operations) and required for set-based flavor
    in section 10.5.7. Some other related functions are also present.
=#

"""
    intersect(a, b)
    ∩(a,b)

Returns the intersection of the intervals `a` and `b`, considered as
(extended) sets of real numbers. That is, the set that contains
the points common in `a` and `b`.

Implement the `intersection` function of the IEEE Std 1788-2015 (section 9.3).
"""
function intersect(a::F, b::F) where {F <: AbstractFlavor}
    isdisjoint(a, b) && return emptyinterval(F)
    return F(max(a.lo, b.lo), min(a.hi, b.hi))
end

intersect(a::F, b::G) where {F <: AbstractFlavor, G <: AbstractFlavor} =
    intersect(promote(a, b)...)

function intersect(a::Complex{F}, b::Complex{F}) where {F <: AbstractFlavor}
    isdisjoint(a, b) && return emptyinterval(Complex{F})
    return complex(intersect(real(a), real(b)), intersect(imag(a), imag(b)))
end

"""
    intersect(a::Interval{T}...) where T

Return the n-ary intersection of its arguments.

This function is applicable to any number of input intervals, as in
`intersect(a1, a2, a3, a4)` where `ai` is an interval.
If your use case needs to splat the input, as in `intersect(a...)`, consider
`reduce(intersect, a)` instead, because you save the cost of splatting.
"""
function intersect(a::F...) where {F <: AbstractFlavor}
    low = maximum(broadcast(ai -> ai.lo, a))
    high = minimum(broadcast(ai -> ai.hi, a))

    !is_valid_interval(low, high) && return emptyinterval(F)
    return Interval(low, high)
end

"""
    hull(a, b)

Return the "interval hull" of the intervals `a` and `b`, considered as
(extended) sets of real numbers, i.e. the smallest interval that contains
all of `a` and `b`.

Implement the `converxHull` function of the IEEE Std 1788-2015 (section 9.3).
"""
hull(a::F, b::F) where {F <: AbstractFlavor} = F(min(a.lo, b.lo), max(a.hi, b.hi))
hull(a::Complex{F},b::Complex{F}) where {F <: AbstractFlavor} =
    complex(hull(real(a), real(b)), hull(imag(a), imag(b)))

"""
    union(a, b)
    ∪(a,b)

Return the union (convex hull) of the intervals `a` and `b`; it is equivalent
to `hull(a,b)`.

Implement the `converxHull` function of the IEEE Std 1788-2015 (section 9.3).
"""
union(a::AbstractFlavor, b::AbstractFlavor) = hull(a, b)
union(a::Complex{<:AbstractFlavor},b::Complex{<:AbstractFlavor}) = hull(a, b)

"""
    setdiff(x::Interval, y::Interval)

Calculate the set difference `x ∖ y`, i.e. the set of values
that are inside the interval `x` but not inside `y`.

Returns an array of intervals.
The array may:

- be empty if `x ⊆ y`;
- contain a single interval, if `y` overlaps `x`
- contain two intervals, if `y` is strictly contained within `x`.
"""
function setdiff(x::F, y::F) where {F <: AbstractFlavor}
    intersection = x ∩ y

    isempty(intersection) && return [x]
    intersection == x && return F[]  # x is subset of y; setdiff is empty

    x.lo == intersection.lo && return [F(intersection.hi, x.hi)]
    x.hi == intersection.hi && return [F(x.lo, intersection.lo)]

    return [F(x.lo, y.lo), F(y.hi, x.hi)]

end