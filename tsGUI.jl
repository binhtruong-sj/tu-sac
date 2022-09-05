macOS = true

if macOS
    gameW = 900
    HEIGHT = gameW
    WIDTH = div(gameW * 16, 9)
    realHEIGHT = HEIGHT * 2
    realWIDTH = WIDTH * 2
    cardXdim = 64
    cardYdim = 210
    zoomCardYdim = 400
else
    gameW = 820
    HEIGHT = gameW
    WIDTH = div(gameW * 16, 9)
    realHEIGHT = div(HEIGHT, 1)
    realWIDTH = div(WIDTH, 1)
    cardXdim = 24
    cardYdim = 80
    zoomCardYdim = 110
end
BACKGROUND = colorant"red"

const tableXgrid = 20
const tableYgrid = 20
const FaceDown = false
const cardGrid = 4
const gameDeckMinimum = 9
gameEnd = false
function gameOver(gameE) 
    if gameE
        global gameEnd = true
    end
end
isGameOver() = gameEnd

global humanPlayer =[true,false,false,false]
playerIsHuman(p) = humanPlayer[p]
"""
table-grid, giving x,y return grid coordinate
"""
tableGridXY(gx, gy) = (gx - 1) * div(realWIDTH, tableXgrid),
(gy - 1) * div(realHEIGHT, tableYgrid)
reverseTableGridXY(x, y) = div(x, div(realWIDTH, tableXgrid)) + 1,
div(y, div(realHEIGHT, tableYgrid)) + 1

module nwAPI
export nwSetup, nwGamePlay, nwGamePlayResult, nwCheckPlayers

function nwSetup(ipAddress)

end

"""
function return nothing, return immediately, not waiting for remote

"""
function nwGamePlay(
    all_hands,
    all_discards,
    all_assets,
    gameDeck,
    pcard;
    gpPlayer = 1,
    gpAction = 0,
) end

"""
    nwGamePlayResult(gpPlayer)
        this would lock-up and wait for result to be ready, return the array
"""
function nwGamePlayResult(gpPlayer) end

end
module TuSacCards

using Random: randperm
import Random: shuffle!

import Base

# Suits/Colors
export T, V, D, X # aliases White, Yellow, Red, Green

# Card, and Suit
export Card, Suit

# Card properties
export suit, rank, high_value, low_value, color

# Lists of all ranks / suits
export ranks, suits, duplicate

# Deck & deck-related methods
export Deck, shuffle!, ssort, full_deck, ordered_deck, ordered_deck_chot, autoShuffle!, dealCards, full_deck_chot
export getCards, rearrange, sort!, rcut, moveCards!
export test_deck, getDeckArray
#####
##### Types
#####

"""
    In TuSac, cards has 4 suit of color: White,Yellow,Red,Green

Encode a suit as a 2-bit value (low bits of a `UInt8`):
- 0 = T rang (White)
- 1 = X anh (Greed)
- 2 = V ang (Yellow)
- 3 = D o (Red)

Suits have global constant bindings: `T`, `V`, `D`, `X`.
"""
struct Suit
    i::UInt8
    Suit(s::Integer) =
        0 ≤ s ≤ 3 ? new(s) : throw(ArgumentError("invalid suit number: $s"))
end


"""
    char

Return the unicode characters:
"""
char(s::Suit) = Char("TVDX"[s.i+1])
Base.string(s::Suit) = string(char(s))
Base.show(io::IO, s::Suit) = print(io, char(s))


"""
Encode a playing card as a 3 bits number [4:2]
The next 2 bits bit[6:5] encodes the suit/color. The
bottom 2 bits bit[1:0] indicates cnt of card of same.

-----: not used (0x0 value)
Tuong: 1
si   : 2
tuong: 3
xe   : 5
phao : 6
ma   : 7
chot : 4
The upper 1 bits bit[2] encode 'groups' as [Tuong-si-tuong],  or
[xe-phao-ma, chot]

bit[1:0] count the 4 cards for each card
bit[6:5] encodes the colors
"""

struct Card
    value::UInt8
    function Card(r::Integer, s::Integer)
        (0 <= r <= 31 && ((r & 0x1c) != 0)) ||
            throw(ArgumentError("invalid card : $r"))
        return new(UInt8((s << 5) | r))
    end
    function Card(i::Integer)
        return new(UInt8(i))
    end
    #=
    function Card(v::Vector{Any})
        Card[Card(e) for e in v]
    end
    =#
end

Card(r::Integer, s::Suit) = Card(r, s.i)

"""
    suit(::Card)
The suit (color) of a card  bit[6:5]
"""
suit(c::Card) = Suit((0x60 & c.value) >>> 5)

"""
    rank(::Card)

The rank of a card
"""
rank(c::Card) = UInt8((c.value & 0x1f))
getvalue(c::Card) = UInt8(c.value)
const T = Suit(0)
const V = Suit(1)
const D = Suit(2)
const X = Suit(3)

# Allow constructing cards with, e.g., `3♡`
Base.:*(r::Integer, s::Suit) = Card(r, s)

function Base.show(io::IO, c::Card)
    r = rank(c)
    rd = r >> 2
    @assert (rd != 0)
    print(io, "Tstcxpm"[rd])
    print(io, suit(c))
end

function rank_string(r::UInt8)
    rr = r >> 2
    @assert rr > 0

    return ("Tstcxpm"[rr])
end

Base.string(card::Card) = rank_string(rank(card)) * string(suit(card))

"""
    high_value(::Card)
    high_value(::Rank)

The high rank value. For example:
 - `Rank(1)` -> 14 (use [`low_value`](@ref) for the low Ace value.)
 - `Rank(5)` -> 5
"""
high_value(c::Card) = rank(c) # no meaning in Tusax

"""
    low_value(::Card)
    low_value(::Rank)

The low rank value. For example:
 - `Rank(1)` -> 1 (use [`high_value`](@ref) for the high Ace value.)
 - `Rank(5)` -> 5
"""
low_value(c::Card) = rank(c)

"""
    color(::Card)

A `Symbol` (`:red`, or `:black`) indicating
the color of the suit or card.
"""
function color(s::Suit)
    if s == 'D'
        return :red
    elseif s == 'T'
        return :white
    elseif s == 'V'
        return :yellow
    else
        return :green
    end
end
color(card::Card) = color(suit(card))

#####
##### Full deck/suit/rank methods
#####

"""
    ranks

A Tuple of ranks `1:7`.
"""
ranks() = 1:7

"""
 For each card, there are duplicate of 4
"""
duplicate() = 0:3

"""
    suits

A Tuple of all suits
"""
suits() = (T, V, D, X)

"""
    full_deck

A vector of a cards
containing a full deck
"""
full_deck() = Card[
    Card((r << 2 | d), s) for s in suits() for d in duplicate() for r in ranks()
]

full_deck_chot() =  Card[
    Card((d|4<<2), s) for s in suits() for d in duplicate()]

function test_deck()
    boid = []
    for i = 1:5
        a = Actor("p1.png")
        a.pos = (100, 100)
        push!(boid, a)
    end
end

#### Deck

"""
    Deck

Deck of cards (backed by a `Vector{Card}`)
"""
struct Deck{C<:Vector}
    cards::C
end

function ssort(deck::Deck)
    ar = []
    for c in deck
        push!(ar, c.value)
    end
    sort!(ar)
    idx = []
    for a in ar
        for (i, card) in enumerate(deck)
            if a == card.value
                push!(idx, i)
                break
            end
        end
    end
    deck.cards .= deck.cards[idx]
    deck
end
function ssort(deck::Vector{Card})
ar = []
for c in deck
    push!(ar, c.value)
end
sort!(ar)
idx = []
for a in ar
    for (i, card) in enumerate(deck)
        if a == card.value
            push!(idx, i)
            break
        end
    end
end
deck .= deck[idx]
deck
end
function rcut(deck::Deck)
    r = rand(30:90)
    idx = union(collect(r:112), collect(1:r-1))
    deck.cards .= deck.cards[idx]
    deck
end

function rearrange(hand::Deck, arr, dst)
    a = collect(1:length(hand))
    c = 0
    for i in arr
        if (i != dst)
            splice!(a, i - c)
            c += 1
        end
    end
    sort!(arr)
    for (i, n) in enumerate(a)
        if n == dst
            splice!(a, i, arr)
            break
        end
    end

    hand.cards .= hand.cards[a]
    hand
end
function getCards(deck::Deck, id)
    if id > length(deck)
        return 0
    end
    if id == 0
        ra = []
        for c in deck
            push!(ra, c.value)
        end
    else
        ra = 0
        for (i, c) in enumerate(deck)
            if i == id
                ra = c.value
                break
            end
        end
    end
    return ra
end


Base.length(deck::Deck) = length(deck.cards)
Base.iterate(deck::Deck, state = 1) = Base.iterate(deck.cards, state)
Base.sort!(deck::Deck) = sort!(deck.cards)

function Base.show(io::IO, deck::Deck)
    for (i, card) in enumerate(deck)
        Base.show(io, card)
        if mod(i, 7) == 0
            println(io)
        else
            print(io, " ")
        end
    end
end

"""
    pop!(deck::Deck, n::Int = 1)
    pop!(deck::Deck, card::Card)
Remove `n` cards from the `deck`.
or
Remove `card` from the `deck`.
"""
Base.pop!(deck::Deck, n::Integer = 1) =
    collect(ntuple(i -> pop!(deck.cards), n))
function Base.pop!(deck::Deck, card::Card)
    L0 = length(deck)
    filter!(x -> x ≠ card, deck.cards)
    L0 == length(deck) + 1 || error("Could not pop $(card) from deck.")
    return card
end

"""
push!
push!(deck::Deck, cards::Vector{Card})
#add `cards` to Deck
"""
function Base.push!(deck::Deck, ncard)
    push!(deck.cards, ncard)
end
function Base.push!(deck::Deck, ncards::Vector{Card})
    for card in ncards
        push!(deck.cards, card)
    end
end

"""
    moveCards!(toDeck::Deck, fDeck::Deck, cards::Deck)
        move cards from fDeck to toDeck
"""
function moveCards!(toDeck::Deck, fDeck::Deck, cards::Deck)
    L0 = length(fDeck)
    for card in cards
        filter!(x -> x ≠ card, fDeck.cards)
        push!(toDeck.cards, card)
    end
    L0 == length(deck) + length(cards) ||
        error("Could not pop $(card) from deck.")
end

"""
    ordered_deck

An ordered `Deck` of cards.
"""
ordered_deck() = Deck(full_deck())
ordered_deck_chot() = Deck(full_deck_chot())

"""
    shuffle!

Shuffle the deck! `shuffle!` uses
`Random.randperm` to shuffle the deck.
"""
function shuffle!(deck::Deck)
    deck.cards .= deck.cards[randperm(length(deck.cards))]
    deck
end

lowhi(r1, r2) = r1 > r2 ? (r2, r1) : (r1, r2)
nextWrap(n::Int, d::Int, max::Int) = ((n + d) > max) ? 1 : (n + d)

"""
"""
function getDeckArray(deck::Deck)
    a = []
    for card in deck
        push!(a, card.value)
    end
    return a
end
"""
"""
function getDeckArray(deck::Vector{Card})
    a = []
    for card in deck
        push!(a, card.value)
    end
    return a
end

"""
autoShuffle:
    gradienDir - (20 or 40) +/- 4

    - is up/left
    + is down/right
"""
function autoShuffle!(deck::Deck, ySize, gradienDir)
    """
        deckCut(dir, a)
        direction: 1,0 ->  hor+right
                0,1 -> ver+down
                    30+/- or 40+/-
    """
    function deckCut(dir, a)
        cardGrid = 4
        r, c = size(a)
        for dr in dir
            if dr < 2
                rangeH = dr == 0 ? r : c
                rangeL = 1
                dr = dr + 29
            else
                if dr > 30
                    g = abs(dr - 40)
                    Grid = div(r, cardGrid)
                else
                    g = abs(dr - 20)
                    Grid = div(c, cardGrid)
                end
                rangeL, rangeH = g * Grid + 1, (g + 1) * Grid

            end
            crl, crh = lowhi(rand(rangeL:rangeH), rand(rangeL:rangeH))
            if dr < 30
                #Horizontally
                cl, ch = crl, crh
                rr = rand(2:r)
                for col = cl:ch
                    save = a[:, col]
                    for n = 1:r
                        rr = nextWrap(rr, 1, r)
                        a[n, col] = save[rr]
                    end
                    #rr = nextWrap(rr,1,r)
                end
            else
                #rl,rh set the BACKGROUND
                rl, rh = crl, crh
                #rc set starting point to rotate
                rc = rand(2:c)
                for row = rl:rh
                    save = a[row, :]
                    for n = 1:c
                        rc = nextWrap(rc, 1, c)
                        a[row, n] = save[rc]
                    end
                    #rc = nextWrap(rc,1,c)
                end
            end
        end

    end
    ###-------------------------------------------

    a = collect(1:112)
    b = reshape(a, ySize, :)

    deckCut(gradienDir, b)
    a = reshape(b, :, 1)
    deck.cards .= deck.cards[a]
    r = rand(1:100)
    if r < 20
        deck = rcut(deck)
    end
    deck
end

end # module
######################################################################

all_hands = []
all_discards = []
all_assets = []



"""
setupActorgameDeck:
    Set up the Full Deck of Actor to use for the whole game, linked to TuSacCards.Card by
    Card.value
"""
function setupActorgameDeck()
    a = []
    b = []
    big = []
    mapToActor = Vector{UInt8}(undef, 128)
    ind = 1
    sc = 0
    for s in ['w', 'y', 'r', 'g']
        for r = 1:7
            for d = 0:3
                if macOS
                    mapr = r < 4 ? r : (r == 4 ? 7 : r - 1)
                    st = string(s, mapr, ".png")
                    big_st = string(s, "-", mapr, ".png")
                    afc = Actor("fc.png")
                else
                    st = string(s, mapr, "xs.png")
                    big_st = string(s, mapr, "s.png")
                    afc = Actor("fcxs.png")
                end
                act = Actor(st)
                big_act = Actor(big_st)

                act.pos = 0, 0
                deckI = (sc << 5) | (r << 2) | d
                mapToActor[deckI] = ind
                push!(a, act)
                push!(b, afc)
                push!(big, big_act)
                ind = ind + 1
            end
        end
        sc = sc + 1
    end
    return a, b, big, mapToActor
end
mask = zeros(UInt8, 112)
actors, fc_actors, big_actors, mapToActors = setupActorgameDeck()

"""
setupDrawDeck:
x,y: starting location
dims: 0: Vertical
      1: Horizontal
      2: Square

      x0,y0 x1,y1 dimensions of box
      state - set to 0
      mx0,my0,mx1,my1 are place holder for state usage
      return array, x0,y0,x1,y1,state, mx0,mx1,my0,my1
"""
function setupDrawDeck(deck::TuSacCards.Deck, gx, gy, xDim, faceDown = false)
    i = 0
    x, y = tableGridXY(gx, gy)
   
    if length(deck) == 0
        l = 1
        if xDim > 20
            xDim = l
            modified_cardYdim = cardYdim
        else
            modified_cardYdim =
                faceDown ? (cardYdim >> 2) : (cardYdim - (cardYdim >> 2))
        end
        yDim = div(l, xDim)
        if (xDim * yDim ) < l
            yDim += 1
        end
        x1 = x + cardXdim * xDim
        y1 = y + modified_cardYdim * yDim
    else
        l = length(deck)
        if xDim > 20
            xDim = l
            modified_cardYdim = cardYdim
        else
            t = (cardYdim >> 4)
            modified_cardYdim =
                faceDown ? (cardYdim - 8*t) : (cardYdim - 5*t)
        end
        for card in deck
            m = mapToActors[card.value]
            px = x + (cardXdim * rem(i, xDim))
            py = y + (modified_cardYdim * div(i, xDim))
            actors[m].pos = px, py
            fc_actors[m].pos = px, py
            if (py + cardYdim * 2) > realHEIGHT
                bpy = py + cardYdim - zoomCardYdim
            else
                bpy = py
            end
            big_actors[m].pos = px, bpy
            if (faceDown)
                mask[m] = mask[m] | 0x1
            else
                mask[m] = mask[m] & 0xFFFFFFFE
            end
            i = i + 1
        end
        yDim = div(l, xDim)
        if xDim * yDim < l
            yDim += 1
        end
        x1 = x + cardXdim * xDim
        y1 = y + modified_cardYdim * yDim
    end
    ra_state = []
    push!(ra_state, x, y, x1, y1, 0, 0, 0, 0, 0, xDim, l)
    return ra_state
end

function getRand1and0(low, high)
    rand_shuffle = []
    for i = 1:rand((low:high))
        for j in rand((0:1))
            push!(rand_shuffle, j)
        end
    end
    return rand_shuffle
end


#ar = TuSacCards.getDeckArray(dd)
#println(ar)

rs = getRand1and0(13, 26)

function organizeHand(ahand::TuSacCards.Deck)
    function tusacSearch(acard::TuSacCards.Card, mode)
        cnt = 0
        if mode == 0  # 4 cards of same kind, same color
            pattern = 0x67
        elseif mode == 1 # 3 of Tst or xpm have to be same color
            pattern = 0x64
        elseif mode == 2 # 3 of Tst or xpm have to be same color
            pattern = 0x64
        end
    end
    TuSacCards.ssort(ahand)
end
"""
array of boxes where cards are stay within
"""
boxes = []

"""
for i in 37:43
    TuSacCards.autoShuffle!(gameDeck,7,i)
    println(gameDeck)
end

TuSacCards.autoShuffle!(gameDeck,7,rs)
println(rs)
println(gameDeck)
"""
function tusacDeal()
    TuSacCards.rcut(gameDeck)
    global player1_hand = TuSacCards.Deck(pop!(gameDeck, 6))
    global player2_hand = TuSacCards.Deck(pop!(gameDeck, 5))
    global player3_hand = TuSacCards.Deck(pop!(gameDeck, 5))
    global player4_hand = TuSacCards.Deck(pop!(gameDeck, 5))
    for i = 2:4
        push!(player1_hand, pop!(gameDeck, 5))
        push!(player2_hand, pop!(gameDeck, 5))
        push!(player3_hand, pop!(gameDeck, 5))
        push!(player4_hand, pop!(gameDeck, 5))
    end
    print(player1_hand)
    setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)

    setupDrawDeck(player4_hand, 1, 2, 2, FaceDown)
    setupDrawDeck(player3_hand, 7, 1, 100, FaceDown)

    setupDrawDeck(player2_hand, 20, 2, 2, FaceDown)
    global human_state = setupDrawDeck(player1_hand, 7, 18, 100, false)

    push!(boxes, human_state)
    global player1_discards = TuSacCards.Deck(pop!(gameDeck, 1))
    global player2_discards = TuSacCards.Deck(pop!(gameDeck, 1))
    global player3_discards = TuSacCards.Deck(pop!(gameDeck, 1))
    global player4_discards = TuSacCards.Deck(pop!(gameDeck, 1))
 
    global player1_assets = TuSacCards.Deck(pop!(gameDeck, 1))
    global player2_assets = TuSacCards.Deck(pop!(gameDeck, 1))
    global player3_assets = TuSacCards.Deck(pop!(gameDeck, 1))
    global player4_assets = TuSacCards.Deck(pop!(gameDeck, 1))

    push!(gameDeck,pop!(player4_assets,1))
    push!(gameDeck,pop!(player3_assets,1))
    push!(gameDeck,pop!(player2_assets,1))
    push!(gameDeck,pop!(player1_assets,1))

    push!(gameDeck,pop!(player4_discards,1))
    push!(gameDeck,pop!(player3_discards,1))
    push!(gameDeck,pop!(player2_discards,1))
    push!(gameDeck,pop!(player1_discards,1))

end

#ar = TuSacCards.getDeckArray(dd)
#println(ar)
const gsOrganize = 1
const gsSetupGame = 2
const gsStartGame = 3
const gsGameLoop = 4

const tsSinitial = 0
const tsSdealCards = 1
const tsSstartGame = 2
const tsGameLoop = 3

tusacState = tsSinitial

function ts(a)
        TuSacCards.Card(a)
end
function tsa(a)
    for e in a
        TuSacCards.Card(e)
    end
end

is_T(v) = (v & 0x1C) == 0x4
is_s(v) = (v & 0x1C) == 0x8
is_t(v) = (v & 0x1C) == 0xc

"""
    c(v) is a chot
"""
isChot(v) = ((v & 0x1C) == 0x10)
"""
    x(v) is a xe
"""
is_x(v) = ((v & 0x1C) == 0x14)
"""
    p(v) is a phao
"""
is_p(v) = (v & 0x1C) == 0x18
"""
    m(v) is a ma
"""
is_m(v) = (v & 0x1C) == 0x1c


"""
    inSuit(a,b): check if a,b is in the same sequence cards (Tst) or (xpm)
"""
inSuit(a, b) = (a & 0xc != 0) && (b & 0xc != 0) && (a & 0xF0 == b & 0xF0)
"""
    inTSuit(a)
     a is either si or tuong

"""
inTSuit(a) = (a&0x1c == 0x08) || (a&0x1c == 0x0C)

"""
    miss(s1,s2): creat the missing card for group of 3,

"""
missPiece(s1, s2) =
    ((((s2 & 0xc) - (s1 & 0xc)) == 4) ? (((s1 & 0xc) == 4) ? 0xc : 4) : 8) |
    (s1 & 0xF3)

"""
    c_equal(a,b): a,b are the same card (same color, and same kind)
"""
card_equal(a, b) = (a & 0xfc) == (b & 0xFC)

function printAllInfo()
    println("==========Hands")
    for ah in all_hands
        for a in ah
            print(ts(a), " ")
        end
        println()
    end
    println("==========Discards")
    for ah in all_discards
        for a in ah
            print(ts(a), " ")
        end
        println()
    end
    println("===========Assets")

    for ah in all_assets
        for a in ah
            print(ts(a), " ")
        end
        println()
    end
    println("gameDeck")
    println(gameDeck)
end

"""
    c_analyzer(p,s,ci)
        return [match][trash]
    not check for pairs match --- this function got call first before
        the regular pairs check
"""
function c_analyzer!(p,s,ci)
    if(ci == 0)
        if length(s)==1
            return [],s
        elseif length(s) > 1
            ci = pop!(s)
        else
            return [],[]
        end
    end
    
    if length(s) == 1
        if card_equal(ci,s[1])
            return s,[]
        else
            for epp in p
                for ep in epp
                    if card_equal(ci,ep[1])
                        return [],[]
                    end
                end
            end
            if length(p[1]) == 1
                # cV cV cD cX
                return [p[1][1][1],s[1]],[p[1][1][1]]
            elseif length(p) == 2
                # cV cV cD cD cX cT.
                return [p[1][1][1],p[1][2][1]],[]
            end
            return [],[s[1],ci]
        end
    elseif length(s) == 2
        if card_equal(ci,s[1])
            return [s[1]],[]
        elseif card_equal(ci,s[2])
            return [s[2]],[]
        else
            return [s[1],s[2]],[]
        end

    end
    println("h3")

    return[],[]
end
      
function c_scan(p,s)
    if length(s) > 2
        return []
    elseif length(s) == 2
        if length(p[2])>0
            return[]
        else
            if length(p[1])>1
                return []
            elseif length(p[1])==1
                return [p[1][1][1]]
            else 
                println("here")
                return s
            end
        end
    else 
        if length(p[2])>1
            return[]
        elseif length(p[2])==1
            return s
        else
            if length(p[1]) > 2
                return []
            else
                return s
            end
        end
    end
end

function c_match(p,s,n)
   if length(s) > 1
        for es in s
            if card_equal(es,n)
                if length(s) == 3
                    return []
                else
                    return [es]
                end
            end
        end
        return s
    elseif length(s)==1
        if card_equal(s[1],n)
            return s
        else
        # now we have 2 uniq chots
            if length(p[2])>0
                return [p[2][1][1],s[1]]
            else
                if length(p[1])>1
                    return [p[1][1][1],p[1][2][1]]
                elseif length(p[1])==1
                    return [p[1][1][1],s[1]]
                else 
                    return []
                end
            end
        end
    else 
        if length(p[2])>1
            return [p[2][1][1],p[2][2][1]]
        elseif length(p[2])==1
            return []
        else
            if length(p[1]) > 2
                return [p[1][1][1],p[1][2][1],p[1][3][1]]
            else
                return []
            end
        end
    end
end
      
"""
scanCards() scan for single and missing seq
            put cards in piles of (pairs, single1, miss1, missT, miss1bar, chot1)
            NOTE: some card can be in both group (pairs, single) for easy of matching purpose
            since it got rescan on every move, the duplication does not affecting correctness

"""
function scanCards(ahand, silence = false)
    # scan for pairs and remove them
    pairs = []
    allPairs = [[], [], []]
    prevAcard = ahand[1]
    pairOf = 0
    rhand = []
    chot1 = []
    chotP = [[],[],[]]
    all_chots =[]
    if isChot(prevAcard)
        push!(all_chots,prevAcard)
    end
    for i = 2:length(ahand)
        acard = ahand[i]
        if card_equal(acard, prevAcard)
            push!(pairs, prevAcard)
            pairOf += 1
            @assert pairOf < 4
        else
            if pairOf > 0
                if is_T(prevAcard)
                    if pairOf == 1 # Tuong pair of 2 is not really a pair
                        push!(rhand, prevAcard) # put 1 back for rescan
                    else
                        if pairOf == 2 # T pairof 3 is a pair, but put 1 back for rescan
                            push!(rhand, prevAcard)
                        end
                        push!(pairs, prevAcard)
                        push!(allPairs[pairOf], pairs)
                    end
                else
                    push!(pairs, prevAcard)
                    push!(allPairs[pairOf], pairs)
                    if isChot(pairs[1]) 
                        push!(chotP[pairOf],pairs)
                    end
                end
                pairs = []
                pairOf = 0
            else
                push!(rhand, prevAcard)
            end
        end
        prevAcard = acard
    end
    if pairOf > 0
        push!(pairs, prevAcard)
        push!(allPairs[pairOf], pairs)
        if isChot(pairs[1]) 
            push!(chotP[pairOf],pairs)
        end
    else
        push!(rhand, prevAcard)
    end
    #rhand is the non-pair cards remaining after scan for pairs
    miss1 = []
    missT = []
    miss1Card = []
    single = []
    ahand = rhand
    if length(ahand) > 0
        acard = ahand[1]
        prevAcard = acard
        prev2card = acard
        prev3card = acard
        seqCnt = 0
     
        for i = 2:length(ahand)
            acard = ahand[i]
            if inSuit(prevAcard, acard)
                prev3card = prev2card
                prev2card = prevAcard
                seqCnt += 1
            else
                if seqCnt == 1
                    ar = []
                    mc = missPiece(prev2card, prevAcard)
                    push!(miss1Card, mc)
                    push!(ar, prev2card, prevAcard)
                    if is_T(mc)
                        push!(missT, ar)
                    else
                        push!(miss1, ar)
                    end
                elseif seqCnt == 0
                    # a single
                    if !is_T(prevAcard) # Tuong
                        if isChot(prevAcard)
                            push!(chot1, prevAcard)
                        else
                            push!(single, prevAcard)
                        end
                    end
                end
                seqCnt = 0
            end
            prevAcard = acard
        end
        if seqCnt == 1
            ar = []
            mc = missPiece(prev2card, prevAcard)
            push!(miss1Card, mc)
            push!(ar, prev2card, prevAcard)
            if is_T(mc)
                push!(missT, ar)
            else
                push!(miss1, ar)
            end
        elseif seqCnt == 0
            # a single
            if !is_T(prevAcard) # Tuong
                if isChot(prevAcard)
                    push!(chot1, prevAcard)
                else
                    push!(single, prevAcard)
                end
            end
        end
    end
    if silence == false
        for c in ahand
            print(ts(c), " ")
        end
        
        print("\nallPairs=    ")
        for p = 1:3
            for ap in allPairs[p]
                print((p + 1, ts(ap[1])))
                if p == 1 
                    for m in miss1Card
                        if card_equal(m,ap[1])
                            if !inTSuit(m)
                                println("SAKI")
                                push!(ap,-1)
                            end
                        end
                    end
                end
            end
        end
        print("\nsingle=       ")
        for c in single
            print(" ", ts(c))
        end
        print(" --- Chot1=         ")
        for c in chot1
            print(" ", ts(c))
        end
        print("\nmissT=       ")
        for tc in missT
            for c in tc
                print(" ", ts(c))
            end
            print("|")
        end
        print("\nmiss1=      ")
        for tc in miss1
            for c in tc
                print(" ", ts(c))
            end
            print("|")
        end

        println()
    end
    return allPairs, single, chot1, miss1, missT, miss1Card, chotP
end
global rQ = Vector{Any}(undef,4)
global rReady = Vector{Bool}(undef,4)


"""
gsStateMachine(gameActions)

gsStateMachine: control the flow/setup of the game

states  --  0: Idle, inital state, before setting up the game
            1: Game started, setting up new deck, shuffle or not, cut or not
            2: new deck Complete, now can start dealing cards
            3: Dealing cards completed.  -- sorting cards
            4: Game start ???
            ...

actions --  0, nothing
            1, setup new deck, in ordered
            2, Manual shuffle
            3, Complete manual shuffle
            4, autoShuffle
            5, cut the deck
            6, deal cards
            7, manual re-arrange card
            20, start game
            30, setup new boxes for discards and assets
            .....
"""
function gsStateMachine(gameActions)
    global tusacState
    global gameDeck, ad, deckState

    function removeCards!(array, n, cards)
        for c in cards
            for l = 1:length(array[n])
                if c == array[n][l]
                    splice!(array[n], l)
                    break
                end
            end
                if n== 1
                    pop!(player1_hand,ts(c))
                    global human_state = setupDrawDeck(player1_hand, 7, 18, 100, false)
                elseif n == 2
                    pop!(player2_hand,ts(c))
                    setupDrawDeck(player2_hand, 20, 2, 2, FaceDown)

                elseif n == 3
                    pop!(player3_hand,ts(c))
                    setupDrawDeck(player3_hand, 7, 1, 100, FaceDown)

                elseif n == 4
                    pop!(player4_hand,ts(c))
                    setupDrawDeck(player4_hand, 1, 2, 2, FaceDown)
                end

        end
      
    end
    function addCards!(array,arrNo, n, cards)
        for c in cards
            push!(array[n], c)
            if arrNo == 0
                if n== 1
                    push!(player1_assets,ts(c))
                    global asset1 = setupDrawDeck(player1_assets, 8, 14, 30, false)
                elseif n == 2
                    push!(player2_assets,ts(c))
                    global asset2 = setupDrawDeck(player2_assets, 16, 7, 4, false)
                elseif n == 3
                    push!(player3_assets,ts(c))
                    global asset3 = setupDrawDeck(player3_assets, 8, 4, 30, false)
                elseif n == 4
                    push!(player4_assets,ts(c))
                    global asset4 = setupDrawDeck(player4_assets, 4, 7, 4, false)
                end
            else
                if n== 1
                    push!(player1_discards,ts(c))
                    global discard1 = setupDrawDeck(player1_discards, 16, 16, 8, false)
                elseif n == 2
                    push!(player2_discards,ts(c))
                    global discard2 = setupDrawDeck(player2_discards, 16, 2, 8, false)
                elseif n == 3
                    push!(player3_discards,ts(c))
                    global discard3 = setupDrawDeck(player3_discards, 3, 2, 8, false)
                elseif n == 4
                    push!(player4_discards,ts(c))
                    global discard4 = setupDrawDeck(player4_discards, 3, 16, 8, false)
                end
            end
        end
    end

    nextPlayer(p) = p == 4 ? 1 : p + 1

    function whoWinRound(card, n1, r1, n2, r2, n3, r3, n4, r4)
        function getl(card, n, r)
            l = length(r)
            if (l > 1) && !card_equal(r[1], r[2]) # not pairs
                l = 1
            end
            win = false
            if l > 0 || is_T(card)# only check winner that has matched cards
                thand = all_hands[n]

                for e in r
                    filter!(x -> x != e, thand)
                end
                ps, ss, cs, m1s, mts, mbs = scanCards(thand, true)
                if length(union(ss, cs, m1s, mts, mbs)) == 0
                    println("WINWINWINWINWINWINWINWINWINWIWN")
                    l = 4
                    win = true
                    gameOver(true)
                end
            end
            return l, win
        end
        l1, w1 = getl(card, n1, r1)
        l2, w2 = getl(card, n2, r2)
        l3, w3 = getl(card, n3, r3)
        l4, w4 = getl(card, n4, r4)

        if l1 == 4
            w = 0
        elseif l2 == 4
            w = 1
        elseif l3 == 4
            w = 2
        elseif l4 == 4
            w = 3
        else
            if l1 > 1
                w = 0
            elseif l2 > 1
                w = 1
            elseif l3 > 1
                w = 2
            elseif l4 > 1
                w = 3
            else
                w = 0
            end
        end
        r = w == 0 ? r1 : w == 1 ? r2 : w == 2 ? r3 : r4
        n = rem((n1 - 1 + w), 4) + 1
        if w1 || w2 || w3 || w4   # game over
            w = -1
        end
        println("Who win ?  n,w,r", (n, w, r), (l1, l2, l3, l4))
        return n, w, r
    end

   
    function gamePlay1Iteration()
        global glNewCard, ActiveCard 
        global glNeedaPlayCard
        global glPrevPlayer
        global glIterationCnt
        function All_hand_updateActor(card, player) 
            mmm = mapToActors[card]
            ActiveCard = mmm
            mask[mmm] = mask[mmm] & 0xFE
        end

        glIterationCnt += 1
        if(rem(glIterationCnt,2) !=0)
            println(
                "++++++++++++++++++++++++++",
                (glIterationCnt, glNeedaPlayCard, glPrevPlayer),
                "+++++++++++++++++++++++++++",
            )
            printAllInfo()

            if glNeedaPlayCard
                glNewCard = hgamePlay(
                    all_hands,
                    all_discards,
                    all_assets,
                    gameDeck,
                    [];
                    gpPlayer = glPrevPlayer,
                    gpAction = gpPlay1card,
                    rQ,
                    rReady
                )
                if rReady[glPrevPlayer]
                    glNewCard = rQ[glPrevPlayer]
                    println(glNewCard)
                end

                removeCards!(all_hands, glPrevPlayer, glNewCard)
                All_hand_updateActor(glNewCard[1],glPrevPlayer)
            else
                nc = pop!(gameDeck, 1)
                global gd = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)

                mmm = mapToActors[nc[1].value]
                ActiveCard = mmm
                mask[mmm] = mask[mmm] & 0xFE

            #  gameDeck_updateActor(glNewCard,glPrevPlayer)

                println("pick a card from Deck=", nc[1], " for player", nextPlayer(glPrevPlayer))
                glNewCard = nc[1].value
            end
        else
            t1Player = nextPlayer(glPrevPlayer)
            hgamePlay(
                all_hands,
                all_discards,
                all_assets,
                gameDeck,
                glNewCard;
                gpPlayer = t1Player,
                gpAction = gpCheckMatch1or2,
                rQ,
                rReady
            )
            t2Player = nextPlayer(t1Player)
            hgamePlay(
                all_hands,
                all_discards,
                all_assets,
                gameDeck,
                glNewCard;
                gpPlayer = t2Player,
                gpAction = gpCheckMatch1or2,
                rQ,
                rReady
            )
            t3Player = nextPlayer(t2Player)
            hgamePlay(
                all_hands,
                all_discards,
                all_assets,
                gameDeck,
                glNewCard;
                gpPlayer = t3Player,
                gpAction = gpCheckMatch1or2,
                rQ,
                rReady
            )
           
            t4Player = nextPlayer(t3Player)
            if !glNeedaPlayCard
                hgamePlay(
                    all_hands,
                    all_discards,
                    all_assets,
                    gameDeck,
                    glNewCard;
                    gpPlayer = t4Player,
                    gpAction = gpCheckMatch1or2,
                    rQ,
                    rReady
                )
              
            end
            if rReady[t1Player]
                n1c = rQ[t1Player]
                println(n1c)
            end  
            if rReady[t2Player]
                n2c = rQ[t2Player]
                println(n2c)
            end
            if rReady[t3Player]
                n3c = rQ[t3Player]
                println(n3c)
            end
            if !glNeedaPlayCard
                if rReady[t4Player]
                    n4c = rQ[t4Player]
                    println(n4c)
                end
            else
                n4c = []
            end
            nPlayer, winner, r = whoWinRound(
                glNewCard,
                t1Player,
                n1c,
                t2Player,
                n2c,
                t3Player,
                n3c,
                t4Player,
                n4c,
            )
            removeCards!(all_hands, nPlayer, r)
            if (winner == 0) && (length(r) == 0) # nobody match
                if is_T(glNewCard)
                    addCards!(all_assets,0, nPlayer, glNewCard)
                    glNeedaPlayCard = true
                    glPrevPlayer = nPlayer
                else
                    if glNeedaPlayCard
                        addCards!(all_discards, 1,glPrevPlayer, glNewCard)
                    else
                        addCards!(all_discards, 1,nPlayer, glNewCard)
                        glPrevPlayer = nPlayer
                    end
                    glNeedaPlayCard = false
                end
            elseif winner == -1
                println("GAME OVER, player", 
                nPlayer, " win")
                gameOverCnt = 1
                openAllCard = true

            else
                addCards!(all_assets, 0, nPlayer, glNewCard)
                addCards!(all_assets, 0, nPlayer, r)
                glPrevPlayer = nPlayer
                glNeedaPlayCard = true
            end
        end
    end
    #=

    ---------------------------------

    =#
    if tusacState == tsSinitial
# -------------------A

        if gameActions == gsSetupGame
            gameDeck = TuSacCards.ordered_deck()
            deckState = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
            tusacState = tsSdealCards
        end
        global gameOverCnt = 0
        global openAllCard = false

# -------------------A

    elseif tusacState == tsSdealCards
# -------------------A
        if gameActions == gsOrganize
            tusacState = tsSstartGame
            tusacDeal()
            organizeHand(player1_hand)
            organizeHand(player2_hand)
            organizeHand(player3_hand)
            organizeHand(player4_hand)

            push!(
                all_hands,
                TuSacCards.getDeckArray(player1_hand),
                TuSacCards.getDeckArray(player2_hand),
                TuSacCards.getDeckArray(player3_hand),
                TuSacCards.getDeckArray(player4_hand),
            )
            setupDrawDeck(player1_hand, 7, 18, 100, false)
        end
# -------------------A
    elseif tusacState == tsSstartGame
# -------------------A

        println("Dealing is completed")
        push!(
            all_discards,
            TuSacCards.getDeckArray(player1_discards),
            TuSacCards.getDeckArray(player2_discards),
            TuSacCards.getDeckArray(player3_discards),
            TuSacCards.getDeckArray(player4_discards),
        )

        push!(
            all_assets,
            TuSacCards.getDeckArray(player1_assets),
            TuSacCards.getDeckArray(player2_assets),
            TuSacCards.getDeckArray(player3_assets),
            TuSacCards.getDeckArray(player4_assets),
        )

        discard1 = setupDrawDeck(player1_discards, 16, 16, 8, false)
        discard2 = setupDrawDeck(player2_discards, 16, 2, 8, false)
        discard3 = setupDrawDeck(player3_discards, 3, 2, 8, false)
        discard4 = setupDrawDeck(player4_discards, 3, 16, 8, false)

        asset1 = setupDrawDeck(player1_assets, 8, 14, 30, false)
        asset2 = setupDrawDeck(player2_assets, 16, 7, 4, false)
        asset3 = setupDrawDeck(player3_assets, 8, 4, 30, false)
        asset4 = setupDrawDeck(player4_assets, 4, 7, 4, false)

        global human_state = setupDrawDeck(player1_hand, 7, 18, 100, false)
        setupDrawDeck(player4_hand, 1, 2, 2, FaceDown)
        setupDrawDeck(player3_hand, 7, 1, 100, FaceDown)
        setupDrawDeck(player2_hand, 20, 2, 2, FaceDown)
        global gd = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
        push!(
            boxes,
            discard1,
            discard2,
            discard3,
            discard4,
            asset1,
            asset2,
            asset3,
            asset4,
        )
        println("Starting game")
        tusacState = tsGameLoop
        global glNeedaPlayCard = true
        global glPrevPlayer = 1
        global glIterationCnt = 0
    elseif tusacState == tsGameLoop
        if length(gameDeck) >= gameDeckMinimum
            for i in 1:100
                if !isGameOver()
                    gamePlay1Iteration()
                end
            end
        else
            println("GAME OVER --- bai thui")
            openAllCard = true
            gameOver(true)
        end
    end
end

#=
game start here
=#


gsStateMachine(gsSetupGame)
BIGcard = 0
ActiveCard = 0
cardSelect = false
playCard = 0


function on_mouse_move(g, pos)
    global tusacState, gameDeck, ad, deckState
    """
    MouseOnBoxShuffle:

        for a given box, check to see if mouse x,y is on box. Plus,
        check to see if mouse direction is Horizontal or  Vertical. it
        is done by state machine a[6]:
            0: initial state, after draw the first time, init x0,y0, x1,y1 to -1 --> 1:
            1: check to see if within box, set x0,y0 --> 2:
            2: check if within box still. If it is, set x1,y1 --> 2:   If not,
            Now, calculate the direction, compare x1 vs x0, and y1 vs y0 -->
            x1 > x0 --> +x 3:
            x1 < x0 --> -x 4:
            similarly for 5: 6:
                abs(x1-x0) vs abs(y1-y0) determines 20+/- or 40+/- as (+x,-x,+y,-y)
                if along the x/y direction (+ or -), gradien_size is factor in
            20+/- or 40+/-: -> no change after this.  It will go back to 0: after someone check/restart
    """
    function mouseDirOnBox(x, y, boxState)
        if boxState[5] == 0
            boxState[5] = 1
        elseif boxState[5] == 1
            if (boxState[1] < x < boxState[3]) &&
               (boxState[2] < y < boxState[4])
                boxState[6], boxState[7] = x, y
                boxState[5] = 2
            end
        elseif boxState[5] == 2
            if (
                (boxState[1] < x < boxState[3]) &&
                (boxState[2] < y < boxState[4])
            ) == false
                boxState[8], boxState[9] = x, y
                deltaX = boxState[8] - boxState[6]
                deltaY = boxState[9] - boxState[7]
                calGradien(a, b, loc, gradien_size) =
                    div(gradien_size * (loc - a), b - a)
                if abs(deltaX) < abs(deltaY)
                    g = calGradien(
                        boxState[1],
                        boxState[3],
                        boxState[6],
                        cardGrid,
                    )
                    deltaX > 0 ? boxState[5] = 40 + g : boxState[5] = 40 - g
                else
                    g = calGradien(
                        boxState[2],
                        boxState[4],
                        boxState[7],
                        cardGrid,
                    )
                    deltaY > 0 ? boxState[5] = 20 + g : boxState[5] = 20 - g
                end
            end
        end
    end
    function withinBoxes(x, y, boxes)
        for (i, b) in enumerate(boxes)
            if b[1] < x < b[3] && b[2] < y < b[4]
                rx = div((x - b[1]), cardXdim) + 1
                ry = div((y - b[2]), cardYdim)
                cardId = ry * b[10] + rx
                return i, cardId
            end
        end
        return 0, 0
    end
    ####################

    x = pos[1] << 1
    y = pos[2] << 1
    if (tusacState == tsSdealCards)
        mouseDirOnBox(x, y, deckState)
    elseif tusacState > tsSstartGame
        boxId, cardIndx = withinBoxes(x, y, boxes)
        if boxId == 0
            v = 0
        elseif boxId == 1
            v = TuSacCards.getCards(player1_hand, cardIndx)
        elseif boxId == 2
            v = TuSacCards.getCards(player1_discards, cardIndx)
        elseif boxId == 3
            v = TuSacCards.getCards(player2_discards, cardIndx)
        elseif boxId == 4
            v = TuSacCards.getCards(player3_discards, cardIndx)
        elseif boxId == 5
            v = TuSacCards.getCards(player4_discards, cardIndx)
        elseif boxId == 6
            v = TuSacCards.getCards(player1_assets, cardIndx)
        elseif boxId == 7
            v = TuSacCards.getCards(player2_assets, cardIndx)
        elseif boxId == 8
            v = TuSacCards.getCards(player3_assets, cardIndx)
        else
            v = TuSacCards.getCards(player4_assets, cardIndx)
        end
        if v != 0
            m = mapToActors[v]
        else
            m = 0
        end

        global BIGcard = m

    end
end

function update(g)

    global ad, deckState, gameDeck, tusacState
    if (tusacState == tsSdealCards)
        if (deckState[5] > 10)
            TuSacCards.autoShuffle!(gameDeck, 14, deckState[5])
            deckState = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
        end
 
    end
end

function mouseDownOnBox(x, y, boxState)
    loc = 0
    remy = 0
    if (boxState[1] < x < boxState[3]) && ((boxState[2] < y < boxState[4]))
        dx = div((x - boxState[1]), cardXdim)
        dy = div((y - boxState[2]), cardYdim)
        remy = rem((y - boxState[2]), cardYdim)
        remy = div(remy, div(cardYdim, 2))
        loc = div((boxState[3] - boxState[1]), cardXdim) * dy + dx + 1
    end
    return loc, remy
end

actionStr(a) =
    a == gpPlay1card ? "gpPlay1card" :
    a == gpCheckMatch1or2 ? "gpCheckMatch1or2" :
    a == gpCheckMatch2 ? "gpCheckMatch2" : "gpPopCards"

function ts_s(rt)
    print("\nresult= ")
    for r in rt
        print(ts(r))
    end
    println()
end
const gpPlay1card = 1
const gpCheckMatch1or2 = 3
const gpCheckMatch2 = 2
const gpPopCards = 4


function strToVal(ahand, str)
    grank = "Tstcxpm"
    gcolor = "TVDX"
function find1(c, str)
    for i = 1:length(str)
        if c == str[i]
            return i
        end
    end
    return 0
end
aStrToVal(s) =
(UInt8(find1(s[1], grank)) << 2) | (UInt8(find1(s[2], gcolor) - 1) << 5)

hand = ahand
local r = []
for s in str
    v = aStrToVal(s)
    for i = 1:length(hand)
        c = hand[i]
        found = false
        for ar in r
            if ar == c
                found = true
            end
        end
        if !found && card_equal(c, v)
            push!(r, c)
            break
        end
    end
end
return r
end
function humanResponse(gpPlayer)
        local al = readline()
        if length(al) > 1
            local rl = split(al, ' ')
            local card = strToVal(all_hands[gpPlayer], rl)
        else
            card = []
        end
    return card
end
"""
    human_gamePlay(
    all_hands,
    all_discards,
    all_assets,
    gameDeck,
    pcard;
    gpPlayer = 1,
    gpAction = 0
)
similar to gamePlay -- but use stdio for input and output

"""
function human_gamePlay(
    all_hands,
    all_discards,
    all_assets,
    gameDeck,
    pcard;
    gpPlayer = 1,
    gpAction = 0,
    rQ,
    rReady
)
    
    println()
    println("=========================Player", gpPlayer, "Hand: ")
    for c in all_hands[gpPlayer]
        print(ts(c), " ")
    end

    println()
    a = 0
    for as in all_assets
        a += 1
        print("Assets", a, ":  ")
        for i = 2:length(as)
            c = as[i]
            print(ts(c), " ")
        end
        println()
    end
    println()
    a = 0
    for as in all_discards
        a += 1
        print("Trashs", a, ":  ")
        for i = 2:length(as)
            c = as[i]
            print(ts(c), " ")
        end
        println()
    end
    scanCards(all_hands[gpPlayer])
    if gpAction == gpPlay1card
        println("Enter card to play")
    elseif gpAction == gpCheckMatch1or2
        println("Enter card(s) to to match with ", ts(pcard[1]))
    else
        println("Enter PAIR of cards to to match with ", ts(pcard[1]))

    end
    al = readline()
    if length(al) > 1
        rl = split(al, ' ')
        r = strToVal(all_hands[gpPlayer], rl)
    else
        r = []
    end
    println("r=", r)
    rQ[gpPlayer] = r
    rReady[gpPlayer] = true
    return
end

"""
hgamePlay:
    actions: 0 - inital cards dealt - before any play
             1 - play a single card, player choise
             2 - check for match single/double; return matched
             3 - check for match double only; return matched
             4 - play cards -- these cards
    game-manager will control the flow of the game, calling each
    player for actions/reponse and maintaining all card-decks

"""
function hgamePlay(
    all_hands,
    all_discards,
    all_assets,
    gameDeck,
    pcard;
    gpPlayer = 1,
    gpAction = 0,
    rQ,
    rReady
)
    global rQ, rReady
    rReady[gpPlayer] = false
    print(
        "======================player",
        gpPlayer,
        " Action=",
        actionStr(gpAction))
        if gpAction != gpPlay1card
            println(" checkCard=",
            ts(pcard))
        end
    println()
    allPairs, singles, chot1s, miss1s, missTs, miss1sbar,chotPs =
        scanCards(all_hands[gpPlayer])

    """
    chk1(playCard)

TBW
"""
function chk1(playCard)
        if isChot(playCard)
                 r  = c_match(chotPs,chot1s,playCard)
          mtch,trsh = c_analyzer!(chotPs,chot1s,playCard)
          if r != mtch
            println("Chot-Pc, CHECK",((chotPs),(chot1s),playCard))
            println("CHECK:",(r,mtch))
          end
          if length(r) > 0
            return r
          end
        end
        for s in singles
            print(" s=",ts(s))
            @assert !isChot(s)
            if card_equal(s, playCard)
                return s
            end
        end
        println()

        for mt in missTs
            m = missPiece(mt[1], mt[2])
            print(" mT=", ts(m))
            if card_equal(m, playCard)
                return mt
            elseif card_equal(mt[1], playCard) && !is_T(playCard)
                return mt[1]
            elseif card_equal(mt[2], playCard) && !is_T(playCard)
                return mt[2]
            end
        end
        println()

        for m1 in miss1s
            m = missPiece(m1[1], m1[2])
            print(" m1=", ts(m))
            if card_equal(m, playCard)
                    for ap in allPairs[1]
                        if card_equal(ap[1],m)
                            println("FOUND SAKI")
                        end
                    end
                return m1
            elseif card_equal(m1[1], playCard) && !is_T(playCard)
                return m1[1]
            elseif card_equal(m1[2], playCard) && !is_T(playCard)
                return m1[2]
            end
        end
        return []
    end
    function chk2(playCard; chk2only = true)
        inSuitArr = []
        found = false
        for m1 in miss1s # CAAE XX PM ? X
            if card_equal(playCard, missPiece(m1[1], m1[2])) &&
               !is_T(m1[1]) &&
               !is_T(m1[2])
                found = true
                break
            end
        end
        for p = 1:3
            print("   pair-",p," -- ")

            for ap in allPairs[p]
                print(" ",ts(ap[1]))
                if is_T(playCard)
                    if p == 3 && card_equal(ap[1], playCard)
                        return ap
                    end
                elseif card_equal(ap[1], playCard)
                    if (p == 1) && found
                        return []
                    else
                        return ap
                    end
                elseif !chk2only && inSuit(ap[1], playCard)  # CASE X PP ? M
                    push!(inSuitArr, ap[1])
                    print("  inSuitArr =", inSuitArr)
                end
            end
        end
        if length(inSuitArr) > 0
            for s in singles
                if inSuit(s, playCard)
                    push!(inSuitArr, s)
                    print("  inSuitArr =", inSuitArr)
                    return (inSuitArr)
                end
            end
        end
        println()
        return []
    end

    function gpHandlePlay1Card()
        println()
        println("Chot,",(chotPs,chot1s))
        c1s = copy(chot1s)
        trsh1 = c_scan(chotPs, c1s)
        c1s = copy(chot1s)
        mtch,trsh = c_analyzer!(chotPs,c1s,0)
        if trsh != trsh1
            println("Chot, PlayaCard CHECK",(chotPs,chot1s))
            println("CHECK:",(trsh1,trsh))
        end
        if length(trsh1) > 1
            for e in trsh1
                push!(singles, e)
                if length(trsh1) == 1
                    push!(singles, e)
                    push!(singles, e)
                end
            end
        elseif length(missTs) > 0
            for mt in missTs
                for m in mt
                    # cheesy way to get dut-dau-tuong to play first
                    push!(singles, m)
                    push!(singles, m)
                end
                break
            end
        end
        if length(chot1s) == 1
            card = splice!(chot1s, rand(1:length(chot1s)))
        elseif length(singles) > 0
            card = splice!(singles, rand(1:length(singles)))
        else
            if length(miss1s) > 0
                for m1 in miss1s
                    for m in m1
                        if !is_T(m)
                            push!(singles,m)
                            if inTSuit(m)
                                push!(singles,m)
                                push!(singles,m)
                            end
                        end
                    end
                end
                if length(chot1s) > 0
                    for m in chot1s
                        push!(singles,m)
                    end
                end
                card = splice!(singles, rand(1:length(singles)))
            else
                card = []
            end
        end
        return card
    end
    function gpHandleMatch1Card(pcard)
        cards = chk1(pcard)
        if length(cards) == 0
            cards = chk2(pcard, chk2only = false)
        end
        return cards
    end

    if gpAction == gpPlay1card
        card = gpHandlePlay1Card()
        if playerIsHuman(gpPlayer)
            print("Hints ")
            ts_s(card)
            println("Enter card to play")
            c = humanResponse(gpPlayer)
            card = c[1]
        end
        print("Card Play=")
        ts_s(card)
        rQ[gpPlayer]=card
        rReady[gpPlayer] = true
        return 
    else
        println(ts(pcard))
        cards = gpHandleMatch1Card(pcard)
        if playerIsHuman(gpPlayer)
            println("Hints = ", (cards))
            ts_s(cards)
            println("Enter cards to match")
            cards = humanResponse(gpPlayer)
            ts_s(cards)
        end
        println("PlayCard = ", (cards))
        ts_s(cards)
        rQ[gpPlayer]=cards
        rReady[gpPlayer] = true
        return 
    end
end

"""
    on_mouse_down(g, pos)

"""
function on_mouse_down(g, pos)
    global cardsIndxArr
    global cardSelect
    global playCard = []
    """
    click_card:
still buggy!
    """
    function click_card(cardIndx, yPortion, hand)
        global prevYportion
        println("yP=", yPortion)
        if cardIndx in cardsIndxArr
            # moving these cards
            if yPortion != prevYportion
                cardsIndxArr = []
                setupDrawDeck(hand, 8, 18, 100, false)
                println("RESET")
                cardSelect = false
                return []
            elseif yPortion > 0
                sort!(cardsIndxArr)
                TuSacCards.rearrange(hand, cardsIndxArr, cardIndx)
                setupDrawDeck(hand, 8, 18, 100, false)
                cardSelect = false
                cardsIndxArr = []
            end

        else
            m = mapToActors[TuSacCards.getCards(hand, cardIndx)]
            x, y = actors[m].pos
            global deltaY = yPortion > 0 ? 50 : -50
            actors[m].pos = x, y + deltaY
            push!(cardsIndxArr, cardIndx)
            cardSelect = true
        end
        global prevYportion = yPortion
        return playCard
    end
    global tusacState
    x = pos[1] << 1
    y = pos[2] << 1
    if tusacState == tsSdealCards
        global cardsIndxArr = []
        gsStateMachine(gsOrganize)

    elseif tusacState == tsSstartGame
        cindx, remy = mouseDownOnBox(x, y, human_state)
        gsStateMachine(gsStartGame)
    elseif tusacState == tsGameLoop
        
        cindx, yPortion = mouseDownOnBox(x, y, human_state)
        if cindx != 0
            global pCard = click_card(cindx, yPortion, player1_hand)
        end
        cindx, yPortion = mouseDownOnBox(x, y, deckState)
        if cindx != 0
            println(cardsIndxArr)
            println("XONG ROI")
            global play1Response = cardsIndxArr
        end
        gsStateMachine(gsGameLoop)
    end
end


function draw(g)
    global BIGcard, ActiveCard
    global cardSelect
    fill(colorant"ivory4")

    saveI = 0
    for i = 1:112
        if ((cardSelect == false)) && (i == BIGcard)
            #       if ((cardSelect == false)||(length(cardsIndxArr)==0)) && (i == BIGcard)
            saveI = i
        elseif (openAllCard == true) || ((mask[i] & 0x1) == 0)
            draw(actors[i])
        else
            draw(fc_actors[i])
        end
    end
    if saveI != 0
        draw(big_actors[saveI])
    end
    if ActiveCard != 0
        draw(big_actors[ActiveCard])
    end
end
