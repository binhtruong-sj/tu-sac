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

tableXgrid = 20
tableYgrid = 20

cardGrid = 4

"""
table-grid, giving x,y return grid coordinate
"""
tableGridXY(gx, gy) = (gx - 1) * div(realWIDTH, tableXgrid),
(gy - 1) * div(realHEIGHT, tableYgrid)
reverseTableGridXY(x, y) = div(x, div(realWIDTH, tableXgrid)) + 1,
div(y, div(realHEIGHT, tableYgrid)) + 1

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
export Deck, shuffle!, ssort, full_deck, ordered_deck, autoShuffle!, dealCards
export getcards, rearrange, sort!, rcut
export test_deck, getDeckArray
#####
##### Types
#####

"""
    In TuSac, cards has 4 suit of color: White,Yellow,Red,Green

Encode a suit as a 2-bit value (low bits of a `UInt8`):
- 0 = T rang (White)
- 1 = V ang (Yellow)
- 2 = D o (Red)
- 3 = X anh (Greed)

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
function rcut(deck::Deck)
r = rand(30:90)
idx = union( collect(r:112),collect(1:r-1))
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
function getcards(deck::Deck, id)
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
    ordered_deck

An ordered `Deck` of cards.
"""
ordered_deck() = Deck(full_deck())
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
    l = length(deck)

    if xDim > 20
        xDim = length(deck)
        modified_cardYdim = cardYdim
    else 
        modified_cardYdim = faceDown ? (cardYdim >> 2) : (cardYdim - (cardYdim>>2))
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
    ra_state = []
    yDim = div(l, xDim)
    if xDim * yDim < l
        yDim += 1
    end
    x1 = x + cardXdim * xDim
    y1 = y + modified_cardYdim * yDim
    push!(ra_state, x, y, x1, y1, 0, 0, 0, 0, 0, xDim, length(deck))
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
    setupDrawDeck(gameDeck, 8, 8, 14, true)

    setupDrawDeck(player4_hand, 1, 6, 2, true)
    setupDrawDeck(player3_hand, 8, 1, 100, true)

    setupDrawDeck(player2_hand, 20, 6, 2, true)
    global human_state = setupDrawDeck(player1_hand, 8, 18, 100, false)

    push!(boxes, human_state)
    acard = pop!(player1_hand,1)
    push!(player1_hand,acard)
    global player1_discards = TuSacCards.Deck(acard)
    global player2_discards = TuSacCards.Deck(acard)
    global player3_discards = TuSacCards.Deck(acard)
    global player4_discards = TuSacCards.Deck(acard)
    global player1_assets = TuSacCards.Deck(acard)
    global player2_assets = TuSacCards.Deck(acard)
    global player3_assets = TuSacCards.Deck(acard)
    global player4_assets = TuSacCards.Deck(acard)
    
end


function fake_play()
    global player1_discards = TuSacCards.Deck(pop!(player1_hand, 5))
    global player2_discards = TuSacCards.Deck(pop!(player2_hand, 7))
    global player3_discards = TuSacCards.Deck(pop!(player3_hand, 8))
    global player4_discards = TuSacCards.Deck(pop!(player4_hand, 7))
    global player1_assets = TuSacCards.Deck(pop!(player1_hand, 6))
    global player2_assets = TuSacCards.Deck(pop!(player2_hand, 5))
    global player3_assets = TuSacCards.Deck(pop!(player3_hand, 6))
    global player4_assets = TuSacCards.Deck(pop!(player4_hand, 5))
   
    discard1 = setupDrawDeck(player1_discards, 16, 16, 8, false)
    discard2 = setupDrawDeck(player2_discards, 16, 2, 8, false)
    discard3 = setupDrawDeck(player3_discards, 3, 2, 8, false)
    discard4 = setupDrawDeck(player4_discards, 3, 16, 8, false)

    asset1 = setupDrawDeck(player1_assets, 8, 14, 30, false)
    asset2 = setupDrawDeck(player2_assets, 16, 7, 4, false)
    asset3 = setupDrawDeck(player3_assets, 8, 4, 30, false)
    asset4 = setupDrawDeck(player4_assets, 4, 7, 4, false)

    global human_state = setupDrawDeck(player1_hand, 8, 18, 100, false)
    setupDrawDeck(player4_hand, 1, 6, 2, true)
    setupDrawDeck(player3_hand, 8, 1, 100, true)
    setupDrawDeck(player2_hand, 20, 6, 2, true)
    global gd = setupDrawDeck(gameDeck, 8, 8, 14, true)
    push!(boxes, discard1, discard2, discard3, discard4, 
                 asset1, asset2, asset3, asset4)
    push!(all_discards, player1_discards,player2_discards,
        player3_discards,player4_discards)
   
    push!(player1_assets, player1_assets,player2_assets,
        player3_assets,player4_assets)
    
end
#ar = TuSacCards.getDeckArray(dd)
#println(ar)
const gsOrganize = 6
const gsSetupGame = 1
const gsStartGame = 8

const tsSinitial = 0
const tsSdealCards = 1
const tsSstartGame = 3
const tsSinGamePlay1 = 4
tusacState = tsSinitial
ts(a) = TuSacCards.Card(a)

T(v) = (v&0x1C) == 0x4
s(v) = (v&0x1C) == 0x8
t(v) = (v&0x1C) == 0xc
c(v) = (v&0x1C) == 0x10
x(v) = (v&0x1C) == 0x14
p(v) = (v&0x1C) == 0x18
m(v) = (v&0x1C) == 0x1c

miss(v1,v2) = ((((v2&0xc) -(v1&0xc)) == 4) ? (((v1&0xc)==4) ? 0xc : 4 ) : 8 ) | (v1 & 0xF3)

c_equal(a,b) = (a&0xfc) == (b&0xFC)

"""
scanCards() scan for single and missing seq

"""
function scanCards(shand)
    ahand = shand
    # scan for pairs and remove them
    pairs = []
    allPairs = [[],[],[]]
    prevacard = ahand[1]
    pair  = 0
    rhand = []
    chot1 = []

    for i = 2:length(ahand)
        acard = ahand[i] 
        if  c_equal(acard, prevacard)
            push!(pairs, prevacard)
            pair += 1
        else
            if pair > 0
                if T(prevacard)
                    if pair == 1
                        push!(rhand,prevacard)
                    else
                        if pair == 2
                            push!(rhand,prevacard)
                        end
                        push!(pairs, prevacard)
                        push!(allPairs[pair],pairs)
                    end
                else
                    push!(pairs, prevacard)
                    push!(allPairs[pair],pairs)
                    if c(prevacard) && (pair == 2) # to handle chot's variant
                        push!(chot1,prevacard)  # put these as extra single 
                    end
                end
                pairs = []
                pair = 0
            else 
                push!(rhand,prevacard)
            end
        end
        prevacard = acard
    end
    if pair > 0
        push!(pairs, prevacard)
        push!(allPairs[pair],pairs)
    else
        push!(rhand,prevacard)
    end
    ahand = rhand
    acard = ahand[1]
    prevCColor = acard  >> 5
    prevCval = (acard >> 2) & 0x7
    prevcard = (acard & 0xFC) >> 2
    prevacard = acard
    prev2card = acard
    prev3card = acard
    seqCnt = 0
    pair = 0
    miss1 = []
    missT =[]
    miss1bar = []
    single = []
    for i = 2:length(ahand)
        acard = ahand[i]
        CColor = acard >> 5
        Cval = (acard >> 2) & 0x7
        card = (acard & 0xFC) >> 2
        if (prevCval!=0x4)&&(Cval!=4) && ((Cval&0x3) != 1) &&
        ((prevcard + 1) == card || (prevcard + 2) == card )
            prev3card = prev2card
            prev2card = prevacard
            seqCnt += 1
        else
            if seqCnt == 1
                ar =[]
                mc = miss(prev2card,prevacard)
                push!(miss1bar, mc)
                push!(ar,prev2card,prevacard)
                if T(mc) 
                    push!(missT, ar)
                else
                    push!(miss1, ar)
                end
            elseif seqCnt == 0
                # a single
                if prevCval != 1 # Tuong
                    if c(prevacard)
                        push!(chot1,prevacard)
                    else
                        push!(single, prevacard)
                    end
                end
            end
            seqCnt = 0
        end
        prevcard = card
        prevCColor = CColor
        prevCval = Cval
        prevacard = acard
    end
    if seqCnt == 1
        ar = []
        mc = miss(prev2card,prevacard)
        push!(miss1bar, mc)
        push!(ar,prev2card,prevacard)
        if T(mc) 
            push!(missT, ar)
        else
            push!(miss1, ar)
        end
    elseif seqCnt == 0
        # a single
        if prevCval != 1 # Tuong
            if c(prevacard)
                push!(chot1,prevacard)
            else
                push!(single, prevacard)
            end
        end
    end

    for c in shand
        print(TuSacCards.Card(c)," ")
    end
    
    println("\nallPairs= ")
    for p = 1:3
        for ap in allPairs[p]
            println(p+1," ",TuSacCards.Card(ap[1]))
        end
    end
    println("\nsingle= ")
    for c in single
        print(" ",TuSacCards.Card(c))
    end
    println("\nChot1= ")
    for c in chot1
        print(" ",TuSacCards.Card(c))
    end
    println("\nmissT= ")
    for tc in missT
        for c in tc
            print(" ",TuSacCards.Card(c))
        end
        print("|")
    end
    println("\nmiss1= ")
    for tc in miss1
        for c in tc
            print(" ",TuSacCards.Card(c))
        end
        print("|")
    end
    println("\nmiss1Bar= ")
    for mb in miss1bar
        print(" ",TuSacCards.Card(mb))
    end
    println()
    return allPairs, single, chot1, miss1, missT, miss1bar
end

"""
gameStates(gameActions)

gameStates: control the flow/setup of the game

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
function gameStates(gameActions)
    global tusacState
    global gameDeck, ad, deckState
    if tusacState == tsSinitial
        if gameActions == gsSetupGame
            gameDeck = TuSacCards.ordered_deck()
            deckState = setupDrawDeck(gameDeck, 8, 8, 14, true)
            tusacState = tsSdealCards
        end
    elseif tusacState == tsSdealCards
        if gameActions == gsOrganize
            tusacState = tsSstartGame
            tusacDeal()
            organizeHand(player1_hand)
            organizeHand(player2_hand)
            organizeHand(player3_hand)
            organizeHand(player4_hand)

            push!(all_hands,TuSacCards.getDeckArray(player1_hand),
                            TuSacCards.getDeckArray(player2_hand),
                            TuSacCards.getDeckArray(player3_hand),
                            TuSacCards.getDeckArray(player4_hand))
            setupDrawDeck(player1_hand, 8, 18, 100, false)
            
        end
    elseif tusacState == tsSstartGame
        println("Dealing is completed")
        push!(all_discards, TuSacCards.getDeckArray(player1_discards),
                            TuSacCards.getDeckArray(player2_discards),
                            TuSacCards.getDeckArray(player3_discards),
                            TuSacCards.getDeckArray(player4_discards))
                        
        push!(all_assets,   TuSacCards.getDeckArray(player1_assets),
                            TuSacCards.getDeckArray(player2_assets),
                            TuSacCards.getDeckArray(player3_assets),
                            TuSacCards.getDeckArray(player4_assets))
                    
        discard1 = setupDrawDeck(player1_discards, 16, 16, 8, false)
        discard2 = setupDrawDeck(player2_discards, 16, 2, 8, false)
        discard3 = setupDrawDeck(player3_discards, 3, 2, 8, false)
        discard4 = setupDrawDeck(player4_discards, 3, 16, 8, false)
    
        asset1 = setupDrawDeck(player1_assets, 8, 14, 30, false)
        asset2 = setupDrawDeck(player2_assets, 16, 7, 4, false)
        asset3 = setupDrawDeck(player3_assets, 8, 4, 30, false)
        asset4 = setupDrawDeck(player4_assets, 4, 7, 4, false)
    
        global human_state = setupDrawDeck(player1_hand, 8, 18, 100, false)
        setupDrawDeck(player4_hand, 1, 6, 2, true)
        setupDrawDeck(player3_hand, 8, 1, 100, true)
        setupDrawDeck(player2_hand, 20, 6, 2, true)
        global gd = setupDrawDeck(gameDeck, 8, 8, 14, true)
        push!(boxes, discard1, discard2, discard3, discard4, 
                     asset1, asset2, asset3, asset4)

         println("Starting game")
        # fake_play()
        function removeCards!(array, n, cards)
            for c in cards
                for l = 1:length(array[n])
                    if c == array[n][l]
                        splice!(array[n],l)
                        break
                    end
                end
            end
        end

        function addCards!(array, n, cards)
            for c in cards
                push!(array[n],c)
            end
        end

    nextPlayer(p) = p == 4 ? 1 : p+1

function whoWin(n1,r1,n2,r2,n3,r3) 
    function getl(n,r) 
        l = length(r)
        if (l > 1) && !c_equal(r[1],r[2]) # not pairs
             l = 1
        end
        win=false
        if l > 0
            ps,ss,cs,m1s,mts,mbs=scanCards(all_hands[n])
            if length(union(ss,cs,m1s,mts,mbs))== 0
                l = 4
                win=true
            end
        end
        return l,win
    end
    l1,w1 = getl(n1,r1)
    l2,w2 = getl(n2,r2)
    l3,w3 = getl(n3,r3)

    if l1 == 4
        w = 0
    elseif l2 == 4
        w = 1
    elseif l3 == 4
        w = 2
    else 
        if l1 > 1
            w = 0
        elseif l2 > 1
            w = 1
        elseif l3 > 1
            w =2
        else
            w = 0
        end
    end
    r = w == 0 ? r1 : w == 1 ? r2 : r3
    n = rem((n1-1+w),4) + 1
    if w1||w2||w3
        w = -1
    end
    println("Who win ?  n,w,r",(n,w,r),(l1,l2,l3))
    return n,w,r
end

        needCard = true
        cPlayer = 1

        for iter in 1:60
            global newCard
            println("++++++++++++++++++++++++++",(iter,needCard,cPlayer),"+++++++++++++++++++++++++++")
            for ah in all_hands
                println(ah)
            end
            println("Discards")

            for ah in all_discards
                println(ah)
            end
            println("Assets")

            for ah in all_assets
                println(ah)
            end
            println("gameDeck")
            println(gameDeck)
            println("++++++++++++++++++++++++++",iter,"+++++++++++++++++++++++++++")


            if needCard 
                newCard = hgamePlay(all_hands, all_discards, all_assets, gameDeck, []; gpPlayer = cPlayer, gpAction = gpPlay1card )
            end
            t1Player = nextPlayer(cPlayer)
            n1c = hgamePlay(all_hands, all_discards, all_assets, gameDeck, newCard; gpPlayer = t1Player, gpAction = gpCheckMatch1or2 )
            t2Player = nextPlayer(t1Player)
            n2c = hgamePlay(all_hands, all_discards, all_assets, gameDeck, newCard; gpPlayer = t2Player, gpAction = gpCheckMatch2 ) 
            t3Player = nextPlayer(t2Player)
            n3c = hgamePlay(all_hands, all_discards, all_assets, gameDeck, newCard; gpPlayer = t3Player, gpAction = gpCheckMatch2 )

            nPlayer, winner, r = whoWin(t1Player,n1c,t2Player, n2c, t3Player,n3c)

            removeCards!(all_hands,cPlayer,newCard)
            removeCards!(all_hands,nPlayer,r)
            if (winner == 0) && ( length(r) == 0) # nobody winner
                    addCards!(all_discards,cPlayer,newCard)
                    nc = pop!(gameDeck,1)
                    println("pick a card from Deck=",nc[1])
                    newCard = nc[1].value
                    needCard = false
            elseif winner == -1
                println("GAME OVER, player",nPlayer, " win")
                gameOver()
            else
                addCards!(all_assets, nPlayer,newCard)
                addCards!(all_assets, nPlayer,r)
                needCard = true
            end
            cPlayer = nPlayer
        end 
        quit()
        for it in 1:2
            player = rand(1:4)
           

            pc = all_hands[player][rand(1:length(all_hands[player]))]
            for act in 2:3
                for cr in -1:1
                    print( ("Action=",act)," testCard =",TuSacCards.Card(pc))
                    pcv = (((pc >> 2) & 0x7) + cr) & 0x7
                    pcv = pcv == 0 ? 4 : pcv
                    npc = (pc & 0xe3 ) | (pcv << 2)

                    println(" -> ",(pc,TuSacCards.Card(npc)))

                    c = hgamePlay(all_hands, all_discards, all_assets, gameDeck, npc; gpPlayer = player, gpAction = act )
                    print("\nCard-matched= ")
                    for cc in c
                        print(" ",TuSacCards.Card(cc))
                        if cr == 1
                        removeCards!(all_hands,player,cc)
                        end
                    end
                    println()
                end
            end
        end
        tusacState = tsSinGamePlay1
    elseif tusacState == tsSinGamePlay1

    end
end

#=
game start here
=#


gameStates(gsSetupGame)
BIGcard = 0
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
            v = TuSacCards.getcards(player1_hand, cardIndx)
        elseif boxId == 2
            v = TuSacCards.getcards(player1_discards, cardIndx)
        elseif boxId == 3
            v = TuSacCards.getcards(player2_discards, cardIndx)
        elseif boxId == 4
            v = TuSacCards.getcards(player3_discards, cardIndx)
        elseif boxId == 5
            v = TuSacCards.getcards(player4_discards, cardIndx)
        elseif boxId == 6
            v = TuSacCards.getcards(player1_assets, cardIndx)
        elseif boxId == 7
            v = TuSacCards.getcards(player2_assets, cardIndx)
        elseif boxId == 8
            v = TuSacCards.getcards(player3_assets, cardIndx)
        else
            v = TuSacCards.getcards(player4_assets, cardIndx)
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
            deckState = setupDrawDeck(gameDeck, 8, 8, 14, true)
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
#=
"""
gamePlay:
    actions: 0 - inital cards dealt - before any play
             1 - play a single card, player choise
             2 - check for match single/double; return matched
             3 - check for match double only; return matched
             4 - play cards -- these cards
    game-manager will control the flow of the game, calling each
    player for actions/reponse and maintaining all card-decks

"""

function gamePlay(
    all_hands,
    all_discards,
    all_assets,
    gameDeck,
    presentedCards;
    player = 1,
    gameAct = 0
)

    """
    scanCards() scan for single and missing seq

    """
    function scanCards(shand)
        ahand = shand
        # scan for pairs and remove them
        pairs = []
        allPairs = [[],[],[]]
        prevacard = ahand[1]
        pair  = 0
        rhand = []
        for i = 2:length(ahand)
            acard = ahand[i] 
            if (((acard >> 2)& 0x7)!= 1) && (acard&0xFC == prevacard &0xFC)
                push!(pairs, prevacard)
                pair += 1
            else
                if pair > 0
                    push!(pairs, prevacard)
                    push!(allPairs[pair],pairs)
                    pairs = []
                    pair = 0
                else 
                    push!(rhand,prevacard)
                end
            end
            prevacard = acard
        end
        if pair > 0
            push!(pairs, prevacard)
            push!(allPairs[pair],pairs)
        else
            push!(rhand,prevacard)
        end
        ahand = rhand
        acard = ahand[1]
        prevCColor = acard  >> 5
        prevCval = (acard >> 2) & 0x7
        prevcard = (acard & 0xFC) >> 2
        prevacard = acard
        prev2card = acard
        prev3card = acard
        seqCnt = 0
        pair = 0
        miss1 = []
        single = []
        for i = 2:length(ahand)
            acard = ahand[i]
            CColor = acard >> 5
            Cval = (acard >> 2) & 0x7
            card = (acard & 0xFC) >> 2
            if (CColor == prevCColor) && 
            (prevCval!=0x4)&&(Cval!=4) && ((Cval&0x3) != 1) &&
            ( (prevcard + 1) == card ||
              (prevcard + 2) == card )
                prev3card = prev2card
                prev2card = prevacard
                seqCnt += 1
            else
                if seqCnt == 1
                    push!(miss1, (prev2card,prevacard))
                elseif seqCnt == 0
                    # a single
                    if prevCval != 1 # Tuong
                        push!(single, prevacard)
                    end
                end
                seqCnt = 0
            end
            prevcard = card
            prevCColor = CColor
            prevCval = Cval
            prevacard = acard
        end
        if seqCnt == 1
            push!(miss1, (prev2card,prevacard))
        elseif seqCnt == 0
            # a single
            if prevCval != 1 # Tuong
                push!(single, prevacard)
            end
        end
        println("------------")
        for c in shand
            print(TuSacCards.Card(c)," ")
        end
        
        println("\nallPairs= ")
        for p = 1:3
            for ap in allPairs[p]
                print(" ",(p+1,TuSacCards.Card(ap[1])))
            end
        end
        println("\nsingle= ")
        for c in single
            print(" ",TuSacCards.Card(c))
        end
        println("\nmiss1= ")
        for tc in miss1
            for c in tc
                print(" ",TuSacCards.Card(c))
            end
            print("|")
        end
        println()
        return allPairs, single, miss1
    end

    

    if gameAct == 0
        allPairs, singles, miss1s =scanCards(all_hands[1])
        allPairs, singles, miss1s =scanCards(all_hands[2])
        allPairs, singles, miss1s =scanCards(all_hands[3])
        allPairs, singles, miss1s =scanCards(all_hands[4])
    end
end
=#

actionStr(a) =  a == gpPlay1card ? "gpPlay1card" : a==gpCheckMatch1or2 ? "gpCheckMatch1or2" : a==gpCheckMatch2 ? "gpCheckMatch2" : "gpPopCards"

function PrintResult(rt) 
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
    gpAction = 0
)
println("======================player",gpPlayer," Action=",actionStr(gpAction), " checkCard=", pcard)
  
  inSuit(a,b) = (a&0xc != 0) && (b&0xc !=0) && (a&0xF0 == b&0xF0)
    allPairs, singles, chot1s, miss1s, missTs, miss1sbar = scanCards(all_hands[gpPlayer])

    function chkWin(playCard)
        if length(singles)+length(miss1s)+length(chot1s) > 1
            return false,playCard
        end
        all = union(singles,miss1sbar,chot1s)
        if (length(all) == 1) && c_equal(all[1],playCard)
            println("WINWINWINWINWINWINWINWINWINWIWN")
            return true,all[1]
        else
            return false,playCard
        end
    end
            
    function chk1(playCard)
        if c(playCard)
            for s in chot1s
                print(" s=",(UInt8(s), UInt8(s & 0x1C),ts(s)))
                @assert c(s)
                if c_equal(s,playCard)
                    if length(chot1s) != 3
                        return s
                    else
                        return []
                    end
                end
            end
            if length(chot1s) > 1
                return chot1s
            else
                return []
            end
        end
        for s in singles
            print(" s=",(UInt8(s),UInt8(s & 0x1C), ts(s)))
            @assert !c(s)
            if c_equal(s,playCard)
                return s
            end
        end
        println()
        for mt in missTs
            m = miss(mt[1],mt[2])
            print(" mT=",ts(m))
            if  c_equal(m, playCard)
                return mt
            elseif c_equal(mt[1],playCard)  && !T(playCard)
                return mt[1]
            elseif c_equal(mt[2],playCard)  && !T(playCard)
                return mt[2]
            end
        end
        println()

        for m1 in miss1s
            m = miss(m1[1],m1[2])
            print(" m1=",ts(m))
            if c_equal(m,playCard)
                return m1
            elseif c_equal(m1[1],playCard)  && !T(playCard)
                return m1[1]
            elseif c_equal(m1[2],playCard)  && !T(playCard)
                return m1[2]
            end
        end
        return []
    end
    function chk2(playCard; chk2only = true)  
        inSuitArr = []
        println()
        found = false
        for m1 in miss1s # CAAE XX PM ? X
            if c_equal(playCard,miss(m1[1],m1[2])) 
                found = true
                break
            end
        end
        for p = 1:3
            for ap in allPairs[p]
                print(("pair-",p, TuSacCards.Card(ap[1])))
                if c_equal(ap[1],playCard)
                    if (p == 1) && found
                        return []
                    else
                        return ap
                    end
                elseif !chk2only && inSuit(ap[1],playCard)  # CASE X PP ? M
                    push!(inSuitArr,ap[1])
                    println("inSuitArr =",inSuitArr)
                end
            end
        end
        if length(inSuitArr) > 0
            for s in singles
               if inSuit(s,playCard) 
                    push!(inSuitArr,s)
                    println("inSuitArr =",inSuitArr)
                    return(inSuitArr)
                end
            end
        end
        println()
        return []
    end
 
    
    if gpAction == gpPlay1card
        println()
        if  0 < length(chot1s) < 2
            push!(singles,chot1s[1])
            push!(singles,chot1s[1])
            push!(singles,chot1s[1])
            push!(singles,chot1s[1])
        elseif length(missTs) > 0 
            for mt in missTs
                for m in mt
                    push!(singles,m)
                    push!(singles,m)
                    push!(singles,m)
                    push!(singles,m)
                end
                break
            end
        end
        if length(singles) > 0
            card = splice!(singles,rand(1:length(singles)))
        else 
            @assert(length(miss1s)>0)
            m1 = splice!(miss1s,rand(1:length(miss1s)))
            for m in m1
                if T(m) == false
                    push!(singles,m)
                end
            end
            card = splice!(singles,rand(1:length(singles)))
        end
        println("PlayCard = ", TuSacCards.Card(card))
        return card 
    elseif gpAction == gpCheckMatch1or2
        println(ts(pcard))

        r = chk1(pcard)
        if length(r) == 0
            r = chk2(pcard, chk2only = false)
        end
        PrintResult(r)
        return r
    elseif gpAction == gpCheckMatch2
        println(ts(pcard))

        r = chk2(pcard, chk2only = true)
        PrintResult(r)
        return r
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
        println("yP=",yPortion)
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
          #=  else
                playCard = []
                for c in cardsIndxArr
                    push!(playCard, c)
                end
                println("Play-card=", playCard)
                =#
            end
            
        else
            m = mapToActors[TuSacCards.getcards(hand, cardIndx)]
            x, y = actors[m].pos
            global deltaY = yPortion > 0 ? 50 : -50
            actors[m].pos = x, y + deltaY
            push!(cardsIndxArr, cardIndx)
            cardSelect = true
        end
        #=
        if (length(cardsIndxArr)>0) && (prevYportion != yPortion)
            setupDrawDeck(hand, 8, 18, 100, false)
            cardsIndxArr = []
            println("RESET")
            return []
        else
            =#
        global prevYportion = yPortion
        return playCard
    end


    global tusacState
    x = pos[1] << 1
    y = pos[2] << 1

  
    if tusacState == tsSdealCards
        global cardsIndxArr = []
        gameStates(gsOrganize)
   
    elseif tusacState == tsSstartGame
        cindx, remy = mouseDownOnBox(x, y, human_state)
        gameStates(gsStartGame)
    elseif tusacState == tsSinGamePlay1
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
    end
end


function draw(g)
    global BIGcard
    global cardSelect
    fill(colorant"ivory4")
   
    saveI = 0
    for i = 1:112
        if ((cardSelect == false)) && (i == BIGcard)
     #       if ((cardSelect == false)||(length(cardsIndxArr)==0)) && (i == BIGcard)
                saveI = i
        elseif ((mask[i] & 0x1) == 0)
            draw(actors[i])
        else
            draw(fc_actors[i])
        end
    end
    if saveI != 0
        draw(big_actors[saveI])
    end
end
