import Base: +, -, ==, hash
import Plots: plot, bar


struct Hand
    cards::Vector{Int}
    Hand(cards) = new(remove_trailing_zeros(cards))
end

Hand() = Hand([])

function _rtz(a, len=length(a))
    counter = 0
    for i = len:-1:1
        if a[i] == 0
            counter += 1
        else
            break
        end
    end
    return counter
end


remove_trailing_zeros(a) =  a[1:length(a) - _rtz(a, length(a))]


function remove_trailing_zeros!(a)
    len = length(a)
    deleteat!(a, len-_rtz(a, len)+1:len)
end


function +(hand::Hand, card::Int)
    newcards = copy(hand.cards)
    len = length(hand.cards)
    if len < card
        @inbounds for _ = len+1:card
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


function hash(hand::Hand, h::UInt)
    h = hash(hand.cards, h)
end

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


plot(hand::Hand; kwargs...) = bar(hand::Hand; kwargs...)
bar(hand::Hand; kwargs...) = bar(1:length(hand.cards), hand.cards, legend = :none; kwargs...)


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

DAG = Set{Hand}()
root = Hand([])
push!(DAG, root)
push!(DAG, Hand())
push!(DAG, Hand([1, 1]))

for hand in DAG
    for child in get_children(hand)
        push!(children, get_children(hand)...)
    end
end


function add_children(DAG::Set{Hand})
    children = Set{Hand}()
    for hand in DAG
        for child in get_children(hand)
            push!(children, child)
        end
    end
    union(DAG, children)
end

function add_children(DAG::Set{Hand}, level)
    children = Set{Hand}()
    tempDAG = copy(DAG)
    nhands = length(DAG)
    counter = 0
    while counter < nhands
        for hand in DAG
            if sum(hand.cards) <= level
                push!(children, get_children(hand)...)
                nelements += 1
            end
        end
        tempDAG = union(tempDAG, children)
        counter += 1
    end
end