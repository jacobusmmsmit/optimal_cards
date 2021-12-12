import Base: +, -, ==, push!
using Plots

function remove_trailing_zeros(a::AbstractVector)
    counter = 0
    len = length(a)
    for i = len:-1:1
        if a[i] == 0
            counter += 1
        else
            break
        end
    end
    a[1:len-counter]
end

function remove_trailing_zeros!(a::AbstractVector)
    counter = 0
    len = length(a)
    for i = len:-1:1
        if a[i] == 0
            counter += 1
        else
            break
        end
    end
    deleteat!(a, len-counter+1:len)
end

struct Hand
    cards::Vector{Int}
    Hand(cards) = new(remove_trailing_zeros(cards))
end


function +(hand::Hand, card::Int)
    newcards = copy(hand.cards)
    len = length(hand.cards)
    if len < card
        for i = len+1:card
            push!(newcards, 0)
        end
    end
    newcards[card] += 1
    return Hand(newcards)
end


function -(hand::Hand, card::Int)
    newcards = copy(hand.cards)
    len = length(hand.cards)
    if len < card
        for i = len+1:card
            push!(newcards, 0)
        end
    end
    if newcards[card] > 0
        newcards[card] -= 1
    end
    return Hand(newcards)
end


==(hand1::Hand, hand2::Hand) = all(.==(hand1.cards, hand2.cards))


function evaluate(hand::Hand)
    cards = hand.cards
    best = 0
    tot = sum(cards)
    for (number, count) in enumerate(cards)
        best = max(best, number * count)
    end
    return best // tot
end


function add_optimal(hand::Hand)
    candidate_cards = 1:length(remove_trailing_zeros(hand.cards))+1
    card_to_add = findmin([evaluate(hand + i) for i in candidate_cards])[2]
    return hand + card_to_add
end


# hand = Hand([])
# for _ = 1:100
#     hand = add_optimal(hand)
# end

plot(hand::Hand; kwargs...) = bar(hand::Hand; kwargs...)
bar(hand::Hand; kwargs...) = bar(1:length(hand.cards), hand.cards, legend = :none; kwargs...)

# plot(hand, xlabel = "Card", ylabel = "Frequency", xlims = (1, 30))

# hand = Hand([])
# anim = @animate for i = 1:100
#     hand = add_optimal(hand)
#     plot(hand, xlabel = "Card", ylabel = "Frequency", xlims = (1, 30))
# end

# gif(anim, "optimal_hand.gif", fps = 120)

function get_parents(hand::Hand)
    # nparents = length(filter(a -> a != 0, hand.cards))
    parents = Hand[]
    for i = 1:length(hand.cards)
        newcards = (hand - i).cards
        remove_trailing_zeros!(newcards)
        if Hand(newcards) != hand
            push!(parents, Hand(newcards))
        end
    end
    parents
end

function get_children(hand::Hand)
    children = Hand[]
    for i = 1:length(hand.cards)+1
        newcards = (hand + i).cards
        push!(children, Hand(newcards))
    end
    children
end


function isparent(candidate::Hand, child::Hand)
    all(child.cards .- candidate.cards .>= 0)
end


ischild(candidate::Hand, parent::Hand) = isparent(parent, candidate)

function distance(hand1::Hand, hand2::Hand)
    h1 = hand1.cards
    h2 = hand2.cards
    if length(h1) > length(h2)
        push!(h2, [0 for _ = 1:length(h1)-length(h2)]...)
    end
    if length(h2) > length(h1)
        push!(h1, [0 for _ = 1:length(h2)-length(h1)]...)
    end
    sum(h1 - h2 .!= 0)
end

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
good_hand

1
# Beware, everything from here down breaks bigtime


# function push!(set::Set{Hand}, hand::Hand)
#     for item in set
#         if item == hand
#             return set
#         end
#     end
#     set.dict[hand] = nothing
#     set
# end

# DAG = Set{Hand}()
# root = Hand([])
# push!(DAG, root)
# push!(DAG, Hand([]))
# DAG.dict[Hand([1])] = nothing
# function add_children(DAG::Set{Hand})
#     children = Set{Hand}()
#     for hand in DAG
#         current_children = filter(x -> !(x in DAG), get_children(hand))
#         push!(children, current_children...)
#     end
#     union(DAG, children)
# end

# function add_children(DAG::Set{Hand}, level)
#     children = Set{Hand}()
#     for hand in DAG
#         if sum(hand.cards) <= level
#             push!(children, get_children(hand)...)
#         end
#     end
#     union(DAG, children)
# end

# DAG = add_children(DAG)
# intersect(DAG, DAG)

# d = Dict(Hand([]) => 1)
# push!(d, Hand([1]) => 1)

# get_children(hand)
# filter(x -> !(x in DAG), get_children(hand))
# DAG
# Hand([1]) in DAG
# get_children(hand)
# DAG
# hand

