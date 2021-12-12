import Base: +, -, ==, hash
using Plots

include("Hand.jl")

plot(hand, xlabel = "Card", ylabel = "Frequency", xlims = (1, 30))

hand = Hand([])
anim = @animate for i = 1:100
    hand = add_optimal(hand)
    plot(hand, xlabel = "Card", ylabel = "Frequency", xlims = (1, 30))
end

gif(anim, "optimal_hand.gif", fps = 120)

bad_hand = Hand(rand(1:10, 10))
good_hand = Hand([])
for _ = 1:sum(bad_hand.cards)
    good_hand = add_optimal(good_hand)
end

starting_distance = distance(good_hand, bad_hand)
dist = distance(good_hand, bad_hand)
dist_vect = Int[]
while dist != 0
    good_hand = add_optimal(good_hand)
    bad_hand = add_optimal(bad_hand)
    dist = distance(good_hand, bad_hand)
    push!(dist_vect, dist)
end

Plots.plot(dist_vect)
