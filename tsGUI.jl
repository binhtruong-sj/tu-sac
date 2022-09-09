macOS = true

if macOS
const macOSconst = 1
    gameW = 900
    HEIGHT = gameW
    WIDTH = div(gameW * 16, 9)
    realHEIGHT = HEIGHT * 2
    realWIDTH = WIDTH * 2
    cardXdim = 64
    cardYdim = 210
    zoomCardYdim = 400
else
    const macOSconst = 0

    gameW = 820
    HEIGHT = gameW
    WIDTH = div(gameW * 16, 9)
    realHEIGHT = div(HEIGHT, 1)
    realWIDTH = div(WIDTH, 1)
    cardXdim = 24
    cardYdim = 80
    zoomCardYdim = 110
    
end
zoomCardXdim = div(zoomCardYdim*cardXdim,cardYdim)
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
const humanIsGUI = false
global humanPlayer =[false,false,false,false]
playerIsHuman(p) = humanPlayer[p]
global currentPlayer = 1
gotClick = false
GUI_array=[]
GUI_ready=false
global HISTORY = []
global waitForHuman = false
global handPic
global A_hand = (7,18)
global pBseat = []
global gsHArray = []
global gsHHistArray = []

const gpPlay1card = 1
const gpCheckMatch1or2 = 3
const gpCheckMatch2 = 2
const gpPopCards = 4

const gsHarrayNamehands = 1
const gsHarrayNamediscards = 2
const gsHarrayNameassets = 3
const gsHarrayNamegameDeck = 4

drawCnt = 1
gsHcnt = 1
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
is_c(v) = ((v & 0x1C) == 0x10)

function ssort(deck::Deck)
    ar = []
    for c in deck
        push!(ar, c.value)
    end
    sort!(ar)
    cr = []
    for (i,a) in enumerate(ar)
        if is_c(a)
            push!(cr,a)
        end
    end
    filter!(!is_c,ar)
    for ce in cr
        push!(ar,ce)
    end
    
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
cr = []

for (i,a) in enumerate(ar)
    if is_c(a)
        push!(cr,a)
    end
end
filter!(!is_c,ar)
for ce in cr
    push!(ar,ce)
end
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
            print(io, " ")
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
gameDeckArray =[]


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
                mapr = r < 4 ? r : (r == 4 ? 7 : r - 1)
                if macOS
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

    global pBseat = setupDrawDeck(player2_hand, 20, 2, 2, FaceDown)
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
const tsHistory = 4

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
is_c(v) = ((v & 0x1C) == 0x10)
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
missPiece(s1, s2) = (s2 > s1) ? (((((s2 & 0xc) - (s1 & 0xc)) == 4 ) ?
                                ( ((s1 & 0xc) == 4) ? 0xc : 4 ) : 8) |
                                (s1 & 0xF3)) :  
                                (((((s1 & 0xc) - (s2 & 0xc)) == 4 ) ? 
                                ( ((s2 & 0xc) == 4) ? 0xc : 4 ) : 8) |
                                    (s2 & 0xF3))

function all_chots(cards,pc) 
    for c in cards
        if card_equal(pc,c)
            return false
        end
    end
    if length(cards) == 1
        return false
    else
        if card_equal(cards[1],cards[2])
            return false
        end
        if length(cards)==3
            return !card_equal(cards[3],cards[2])
        end
    end
    return true
end
"""
    c_equal(a,b): a,b are the same card (same color, and same kind)
"""
card_equal(a, b) = ((a & 0xFC) == (b & 0xFC))
global currenAction

function ccompare(ar,br) 
    compare = length(ar) == length(br)
    if !compare
        return false
    end

    for i in 1:length(ar)
        if ar[i] != br[i]
            compare = false
            break
        end
    end
    if !compare
        for i in 1:length(ar)
            print((ar[i],br[i]))
        end
    end
    return true
end

function printAllInfo()
    println("==========Hands")
    println(player1_hand)
    println(player2_hand)
    println(player3_hand)
    println(player4_hand)
    println("==========Hands")
    for ah in all_hands
        ts_s(ah)
    end
    println("==========Discards")
    for ah in all_discards
        ts_s(ah)
    end
    println("===========Assets")
    for ah in all_assets
        ts_s(ah)
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
    return[],[]
end
      
function c_scan(p,s)
    println("c-scan",(p,s))
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
    println("c-match",(p,s,n))

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
function scanCards(inHand, silence = false)
    # scan for pairs and remove them
    ahand = deepcopy(inHand)
    pairs = []
    allPairs = [[], [], []]
    prevAcard = ahand[1]
    pairOf = 0
    rhand = []
    chot1 = []
    chot1Special = []
    chotP = [[],[],[]]
    all_chots =[]
    if is_c(prevAcard)
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
                    if is_c(pairs[1]) 
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
        if is_c(pairs[1]) 
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
                        if is_c(prevAcard)
                            push!(chot1Special, prevAcard)
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
                if is_c(prevAcard)
                    push!(chot1Special, prevAcard)
                else
                    push!(single, prevAcard)
                end
            end
        end
    end
    cTrsh = c_scan(chotP,chot1Special)
    ts_s(cTrsh)
    if length(cTrsh) == 0
        chot1 = []
    else
        chot1 = chot1Special
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
        print(" --- Chot1Special=         ")
        for c in chot1Special
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
    return allPairs, single, chot1, miss1, missT, miss1Card, chotP, chot1Special
end
global rQ = Vector{Any}(undef,4)
global rReady = Vector{Bool}(undef,4)

function updateHandPic(cp) 
    if cp == 1 
        gx,gy = 7, 14
    elseif cp == 2
        gx,gy = 17,14
    elseif cp == 3
        gx,gy = 14, 3
    else 
        gx,gy = 3,14
    end
    handPic.pos = tableGridXY(gx, gy)
end
function  updateErrorPic(cp)
    if cp == 0
        gx,gy = 20,20
    else
        gx,gy = 10,10
    end
    errorPic.pos = tableGridXY(gx, gy)
end

function updateWinnerPic(cp) 
    if cp == 0
        gx,gy = 20,20
    elseif cp == 1 
        gx,gy = 8, 13
    elseif cp == 2
        gx,gy = 16,11
    elseif cp == 3
        gx,gy = 12, 3
    else 
        gx,gy = 3,11
    end
    winnerPic.pos = tableGridXY(gx, gy)
end

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
            println("REMOVE ",ts(c)," from ",n)
            found = false
            for l = 1:length(array[n])
                if c == array[n][l]
                    found = true
                    splice!(array[n], l)
                    break
                end
            end
            @assert found
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
                thand = deepcopy(all_hands[n])

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

    function getData_all_discard_assets()
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
    end
    function getData_all_hands()
        push!(
            all_hands,
            TuSacCards.getDeckArray(player1_hand),
            TuSacCards.getDeckArray(player2_hand),
            TuSacCards.getDeckArray(player3_hand),
            TuSacCards.getDeckArray(player4_hand),
        )
    end
   prevIter = 0
    function gamePlay1Iteration()
        global glNewCard, ActiveCard 
        global glNeedaPlayCard
        global glPrevPlayer
        global glIterationCnt
        global t1Player,t2Player,t3Player,t4Player
        global n1c,n2c,n3c,n4c
        function checkHumanResponse(player)
            global GUI_ready, GUI_array, humanIsGUI,rQ, rReady
            if playerIsHuman(player)
                if humanIsGUI
                    if GUI_ready
                        rReady[player] = true
                        rQ[player]=GUI_array
                        print("PlayCard = ", )
                        ts_s(rQ[player])
                        GUI_ready = false
                    end
                else  
                    cards = humanResponse(player)
                    ts_s(cards)
                    rQ[player]=cards
                    rReady[player] = true
                    println("PlayCard = ", (cards))
                    ts_s(cards)
                end
            end
        end
        function All_hand_updateActor(card,facedown) 
            prevActiveCard = ActiveCard
            if facedown == FaceDown
                mmm = mapToActors[card]
                ActiveCard = mmm
                mask[mmm] = mask[mmm] & 0xFE
            else
                mmm = mapToActors[card]
                ActiveCard = mmm
                mask[mmm] = mask[mmm] | 0x1
            end
        end
        if(rem(glIterationCnt,4) ==0)
         
            glIterationCnt += 1

           
            println(
                "++++++++++++++++++++++++++",
                (glIterationCnt, glNeedaPlayCard, glPrevPlayer),
                "+++++++++++++++++++++++++++",
            )
            printAllInfo()
              
            
            if glNeedaPlayCard
                waitForHuman = true
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
            end
    
        elseif(rem(glIterationCnt,4) ==1)

            glIterationCnt += 1
            if glNeedaPlayCard
                checkHumanResponse(glPrevPlayer)
                if rReady[glPrevPlayer]
                    glNewCard = rQ[glPrevPlayer]
                    if length(glNewCard) == 0
                        glNewCard = []
                    else
                        glNewCard = glNewCard[1]
                    end
                    println(glNewCard)
                    rReady[glPrevPlayer] = false
                else
                    glIterationCnt -= 1
                    return
                end
                removeCards!(all_hands, glPrevPlayer, glNewCard)
                All_hand_updateActor(glNewCard[1],!FaceDown)
            else
                nc = pop!(gameDeck, 1)
                nca = pop!(gameDeckArray)

                global gd = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
                All_hand_updateActor(nc[1].value, !FaceDown)

                println("pick a card from Deck=", nc[1], " for player", nextPlayer(glPrevPlayer))
                glNewCard = nc[1].value
                global currentPlayer = nextPlayer(glPrevPlayer)
                println("Active6 = ", currentPlayer)
            end  
        elseif(rem(glIterationCnt,4) ==2)
            t1Player = nextPlayer(glPrevPlayer)
            glIterationCnt += 1
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
                gpAction = gpCheckMatch2,
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
                gpAction = gpCheckMatch2,
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
                    gpAction = gpCheckMatch2,
                    rQ,
                    rReady
                )
              
            end
       

        else
            glIterationCnt += 1
            aplayer = t1Player
            for i in  1:4
                if !(glNeedaPlayCard && (i == 4 ))
                    checkHumanResponse(aplayer)
                end
                aplayer = nextPlayer(aplayer)
            end

            if  rReady[t1Player] &&
                rReady[t2Player] &&
                rReady[t3Player] &&
               (glNeedaPlayCard  ||
                rReady[t4Player]  )
                n1c = rQ[t1Player]
                println(n1c)
                n2c = rQ[t2Player]
                println(n2c)
                n3c = rQ[t3Player]
                println(n3c)
                if !glNeedaPlayCard
                    n4c = rQ[t4Player]
                    println(n4c)
                else
                    n4c = []
                end
                rReady[t1Player] = false
                rReady[t2Player] = false
                rReady[t3Player] = false
                rReady[t4Player] = false
            else
                glIterationCnt -= 1
                return
            end
            println("AT",(n1c,n2c,n3c,n4c,glNewCard))
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
            global currentPlayer = nPlayer
            println("Active5 = ", currentPlayer)
            if winner != -1 # leave it there for GUI
                removeCards!(all_hands, nPlayer, r)
            end
            if (winner == 0) && (length(r) == 0) # nobody match
              
                if is_T(glNewCard)
                    addCards!(all_assets,0, nPlayer, glNewCard)
                    glNeedaPlayCard = true
                    glPrevPlayer = nPlayer
                else
                    if glNeedaPlayCard
                        addCards!(all_discards, 1,glPrevPlayer, 
                        glNewCard)
                  
                    else
                        addCards!(all_discards, 1,nPlayer, glNewCard)
                        glPrevPlayer = nPlayer
                    end
                    glNeedaPlayCard = false
                end
              
            elseif winner == -1
                println("GAME OVER, player", 
                nPlayer, " win")
                updateWinnerPic(nPlayer)
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
    Code for state machine --????
    ---------------------------------

    =#
    if tusacState == tsSinitial
# -------------------A

        if gameActions == gsSetupGame
            gameDeck = TuSacCards.ordered_deck()
            deckState = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
            tusacState = tsSdealCards
            global handPic = Actor("hand.jpeg")
            global winnerPic = Actor("winner.png")
            global errorPic = Actor("error.png")
            updateHandPic(1)
            updateWinnerPic(0)
            updateErrorPic(0)
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
      
            getData_all_hands()
            setupDrawDeck(player1_hand, 7, 18, 100, false)
        
        end
# -------------------A
    elseif tusacState == tsSstartGame
# -------------------A

        println("Dealing is completed")
    
        getData_all_discard_assets()

        global gameDeckArray = TuSacCards.getDeckArray(gameDeck)

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
        deckState = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
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
        if length(gameDeckArray) >= gameDeckMinimum
                if !isGameOver()
                   
                    if(rem(glIterationCnt,4) ==0)

                    currentStates =[glIterationCnt,glNeedaPlayCard,glPrevPlayer,ActiveCard,BIGcard]
                    anE= []
                    anE = deepcopy(
                        [player1_hand,
                        player2_hand,
                        player3_hand,
                        player4_hand,
                        player1_assets,
                        player2_assets,
                        player3_assets,
                        player4_assets,
                        player1_discards,
                        player2_discards,
                        player3_discards,
                        player4_discards,
                        gameDeck,currentStates])
    
                    push!(HISTORY,anE)
                    end
                    gamePlay1Iteration()

                end
        else
            #=
            bombPic = Actor("bomb.jpeg")
            bombPic.pos = tableGridXY(10,10)
            draw(bombPic)
            =#
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
prevActiveCard = 0
cardSelect = false
playCard = 0
global lsx,lsy

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
    function mouseDirOnBox(x, y, Bs)
        if Bs[5] == 0
            Bs[5] = 1
        elseif Bs[5] == 1
            if (Bs[1] < x < Bs[3]) &&
               (Bs[2] < y < Bs[4])
                Bs[6], Bs[7] = x, y
                Bs[5] = 2
            end
        elseif Bs[5] == 2
            if (
                (Bs[1] < x < Bs[3]) &&
                (Bs[2] < y < Bs[4])
            ) == false
                Bs[8], Bs[9] = x, y
                deltaX = Bs[8] - Bs[6]
                deltaY = Bs[9] - Bs[7]
                calGradien(a, b, loc, gradien_size) =
                    div(gradien_size * (loc - a), b - a)
                if abs(deltaX) < abs(deltaY)
                    g = calGradien(
                        Bs[1],
                        Bs[3],
                        Bs[6],
                        cardGrid,
                    )
                    deltaX > 0 ? Bs[5] = 40 + g : Bs[5] = 40 - g
                else
                    g = calGradien(
                        Bs[2],
                        Bs[4],
                        Bs[7],
                        cardGrid,
                    )
                    deltaY > 0 ? Bs[5] = 20 + g : Bs[5] = 20 - g
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
        x = pos[1] << macOSconst
        y = pos[2] << macOSconst
    

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



function mouseDownOnBox(x, y, boxState)
    loc = 0
    up = 0
    if (boxState[1] < x < boxState[3]) && ((boxState[2] < y < boxState[4]))
        dx = div((x - boxState[1]), cardXdim)
        dy = div((y - boxState[2]), cardYdim)
        up = rem((y - boxState[2]), cardYdim)
        up = div(up, div(cardYdim, 2))
        loc = div((boxState[3] - boxState[1]), cardXdim) * dy + dx + 1
    end
    println("l,r",(loc,up))
    return loc, up
end

actionStr(a) =
    a == gpPlay1card ? "gpPlay1card" :
    a == gpCheckMatch1or2 ? "gpCheckMatch1or2" :
    a == gpCheckMatch2 ? "gpCheckMatch2" : "gpPopCards"

function ts_s(rt)
    for r in rt
        print(ts(r), " ")
    end
    println()
    return
end


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
    global GUI_array, GUI_ready
    if !humanIsGUI
        local al = readline()
        if length(al) > 1
            local rl = split(al, ' ')
            local card = strToVal(all_hands[gpPlayer], rl)
        else
            card = []
        end
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
        println("Hm-Enter card to play")
    elseif gpAction == gpCheckMatch1or2
        println("Hm-Enter card(s) to to match with ", ts(pcard[1]))
    else
        println("Hm-Enter PAIR of cards to to match with ", ts(pcard[1]))

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
    global currentAction = gpAction
    global currentPlayCard = pcard
    rReady[gpPlayer] = false
    rQ[gpPlayer] = []
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
    allPairs, singles, chot1s, miss1s, missTs, miss1sbar,chotPs,chot1Specials =
        scanCards(all_hands[gpPlayer])

    """
    chk1(playCard)

TBW
"""
function chk1(playCard)
        if is_c(playCard)
                 r  = c_match(chotPs,chot1Specials,playCard)
                 ts_s(r)
          if length(r) > 0
            return r
          end
        end
        for s in singles
            print(" s=",ts(s))
            @assert !is_c(s)
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
        println("Chot,",(chotPs,chot1s,chot1Specials))
        trsh1 = c_scan(chotPs, chot1Specials)
        ts_s(trsh1)
        if length(trsh1) == 1
            push!(singles, trsh1)
            push!(singles, trsh1)
        elseif length(trsh1) == 2
            chot1s = []
            chot1s = deepcopy(trsh1)
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
       if length(singles) > 0
            card = singles[rand(1:length(singles))]
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
                card = singles[rand(1:length(singles))]
            else
                card = []
            end
        end
        return card
    end
    function gpHandleMatch2Card(pcard)
        card1 = chk1(pcard)
        card2 = chk2(pcard, chk2only = true)
        if length(card1) == 0
            return card2
        elseif length(card2) == 0
            return card1
        else
            return card2
        end
    end

    function gpHandleMatch1or2Card(pcard)
        cards = chk1(pcard)
        if length(cards) == 0
            cards = chk2(pcard, chk2only = false)
        end
        return cards
    end

    println("--",(playerIsHuman(gpPlayer),humanIsGUI,GUI_ready,GUI_array))
    rReady[gpPlayer] = false

    if gpAction == gpPlay1card
        cards = gpHandlePlay1Card()
        println("Enter card to play")
    elseif gpAction == gpCheckMatch1or2
        cards = gpHandleMatch1or2Card(pcard)
        println("Enter cards to match")
    else
        cards = gpHandleMatch2Card(pcard)
        println("Enter cards to match")
    end
    ts_s(cards)

    if !playerIsHuman(gpPlayer)
        rQ[gpPlayer]=cards
        rReady[gpPlayer] = true
    end
    return 

end

function restoreDeck(deck,ar)
    deck = []
    for a in ar
        push!(deck,ts(a))
    end
end

function printHistory(n)
    ar = HISTORY[n]
        for i in 1:length(ar)-1
           println(ar[i])
        end
    
end

function replayHistory(index)
    global HISTORY,all_hands,all_assets,all_discards,gameDeckArray, glIterationCnt,glNeedaPlayCard,glPrevPlayer
    global player1_hand, player1_discards, player1_assets
    global player2_hand, player2_discards, player2_assets
    global player3_hand, player3_discards, player3_assets
    global player4_hand, player4_discards, player4_assets
    global gameDeckArray
    a = HISTORY[index]
    player1_hand = deepcopy(a[1])
    player2_hand = deepcopy(a[2])
    player3_hand = deepcopy(a[3])
    player4_hand = deepcopy(a[4])

    player1_asets = deepcopy(a[5])
    player2_asets = deepcopy(a[6])
    player3_asets = deepcopy(a[7])
    player4_asets = deepcopy(a[8])

    player1_discards = deepcopy(a[9])
    player1_discards = deepcopy(a[10])
    player1_discards = deepcopy(a[11])
    player1_discards = deepcopy(a[12])

    gameDeck = deepcopy(a[13])

    global glIterationCnt,glNeedaPlayCard,glPrevPlayer,ActiveCard,BIGcard = a[14]
    updateHandPic(glPrevPlayer)

    setupDrawDeck(player1_discards, 16, 16, 8, false)
    setupDrawDeck(player2_discards, 16, 2, 8, false)
    setupDrawDeck(player3_discards, 3, 2, 8, false)
    setupDrawDeck(player4_discards, 3, 16, 8, false)

    setupDrawDeck(player1_assets, 8, 14, 30, false)
    setupDrawDeck(player2_assets, 16, 7, 4, false)
    setupDrawDeck(player3_assets, 8, 4, 30, false)
    setupDrawDeck(player4_assets, 4, 7, 4, false)

    setupDrawDeck(player1_hand, 7, 18, 100, false)
    setupDrawDeck(player4_hand, 1, 2, 2, FaceDown)
    setupDrawDeck(player3_hand, 7, 1, 100, FaceDown)
    setupDrawDeck(player2_hand, 20, 2, 2, FaceDown)
    setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
end

function adjustCnt(cnt,max,dir)
    if dir == 0
        cnt -= 1
        cnt = cnt < 1 ? 1 : cnt
    elseif dir == 1
        cnt -= 4
        cnt = cnt < 1 ? 1 : cnt
    elseif dir == 3
        cnt += 4
        cnt = cnt > max ? max : cnt
    else
        cnt += 1
        cnt = cnt > max ? max : cnt
    end
    return cnt
end

function on_key_down(g)
    global tusacState
        if g.keyboard.RETURN
            println("Return")
        elseif g.keyboard.SPACE
            println("SPACE")
        end
    if tusacState == tsHistory
        dir = g.keyboard.LEFT ? 0 : g.keyboard.UP ? 1 : g.keyboard.RIGHT ? 2 : 3
        global HistCnt = adjustCnt(HistCnt,length(HISTORY),dir)
        println(HistCnt)
        replayHistory(HistCnt)
        printHistory(HistCnt)
        if g.keyboard.b
            println("Exiting History mode")
            resize(HISTORY,HistCnt)
            tusacState = tsGameLoop
        elseif g.keyboard.SPACE
            println("Exiting History mode")
            l = length(HISTORY)
            replayHistory(l)
            printHistory(l)
            tusacState = tsGameLoop
        end
    elseif tusacState == tsGameLoop
        if g.keyboard.RETURN
            HistCnt = length(HISTORY)
            tusacState = tsHistory
            println("Entering History mode, size=",HistCnt)
        end
    end
end

"""
    on_mouse_down(g, pos)

"""
function on_mouse_down(g, pos)
    global cardsIndxArr
    global cardSelect
    global playCard = []
    println("inMD- state = ",tusacState)

    function click_card(cardIndx, yPortion, hand)
        global prevYportion, cardsIndxArr
        println("yP=", yPortion)
        if cardIndx in cardsIndxArr
            # moving these cards
            if yPortion != prevYportion
                cardsIndxArr = []
                setupDrawDeck(hand, 7, 18, 100, false)
                println("RESET")
                cardSelect = false
                return []
            elseif yPortion > 0
                sort!(cardsIndxArr)
                TuSacCards.rearrange(hand, cardsIndxArr, cardIndx)
                setupDrawDeck(hand, 7, 18, 100, false)
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
    end
   
    function badResponse(cards,hand,action,pc)
        println((cards,hand,action,pc))
        allfound = true
        for c in cards
            found = false
            for h in hand
                if c == h
                    found = true
                    break
                end
            end
            if !found
                println(c," is not found in Player hand")
            end
            allfound = allfound && found
        end
        if !allfound
            return true
        end
     
        if action == gpPlay1card
            return (length(cards) != 1) || is_T(cards[1])
        elseif length(cards) == 0
            return false
        else
            all_in_pairs = true
            all_in_suit = true
            pcard = pc[1]
            if card_equal(pcard,cards[1])
                for c in cards
                    all_in_pairs = all_in_pairs && card_equal(pcard,c)
                end
                if !all_in_pairs
                    println(cards," not pairs")
                end
            else 
                if length(cards) > 1
                    if !is_c(pcard)
                        all_in_suit= card_equal(pcard, missPiece(cards[1],cards[2]))
                    else
                        all_in_suit = all_chots(cards,pcard)
                    end
                    if !all_in_suit
                        println(cards," is not in suit")
                    end
                else
                    println(cards, " not pairs or in-suit")
                    return true
                end
            end
            return !( all_in_pairs && all_in_suit)
        end
    end

    global tusacState
    x = pos[1] << macOSconst
    y = pos[2] << macOSconst
  
    if tusacState == tsSdealCards
        global cardsIndxArr = []
        gsStateMachine(gsOrganize)
        global GUI_ready = false
    elseif tusacState == tsSstartGame
        cindx, remy = mouseDownOnBox(x, y, human_state)

    elseif tusacState == tsGameLoop    
        cindx, yPortion = mouseDownOnBox(x, y, human_state)
        if cindx != 0
            click_card(cindx, yPortion, player1_hand)
        end
        if currentAction == gpPlay1card 
            cindx, yPortion = mouseDownOnBox(x, y, pBseat)
        else
            bc = ActiveCard 
            bx,by = big_actors[bc].pos
            hotseat = [bx,by,bx+zoomCardXdim,by+zoomCardYdim]
            cindx, yPortion = mouseDownOnBox(x, y, hotseat)
        end
        if cindx != 0
            global GUI_array, GUI_ready
            GUI_array = []
            for ci in cardsIndxArr
                ac= TuSacCards.getCards(player1_hand, ci)
                push!(GUI_array,ac)
                print(" ",ts(ac))
            end
            println("\nDanh Bai XONG ROI")
            setupDrawDeck(player1_hand, 7, 18, 100, false)
            if badResponse(GUI_array,all_hands[1],currentAction,currentPlayCard)
                updateErrorPic(1)
                cardsIndxArr = []
                GUI_ready = false
            else 
                updateErrorPic(0)
                cardsIndxArr = []
                GUI_ready = true
            end
        end
    end
end

function update(g)
    global waitForHuman
    global ad, deckState, gameDeck, tusacState
    global tusacState
   
    if tusacState == tsSdealCards
        if (deckState[5] > 10)
            TuSacCards.autoShuffle!(gameDeck, 14, deckState[5])
            deckState = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
        end
    elseif tusacState == tsSstartGame
            gsStateMachine(gsStartGame)
    elseif (tusacState == tsSdealCards)
    elseif (tusacState == tsSdealCards)
    
    elseif tusacState == tsGameLoop
            updateHandPic(currentPlayer)
            gsStateMachine(gsGameLoop)
    end
end

function drawAhand(hand)
    sI = 0
    for c in hand
        i = mapToActors[c]
        if ((cardSelect == false)) && (i == BIGcard)
            sI = i
        elseif (openAllCard == true) || ((mask[i] & 0x1) == 0)
            draw(actors[i])
        else
            draw(fc_actors[i])
        end
    end
    return sI
end

function draw(g)
    global BIGcard, ActiveCard
    global cardSelect
    global drawCnt,lsx,lsy
    fill(colorant"ivory4")

    saveI = 0
    drawCnt += 1
    if drawCnt > 40
        drawCnt = 0
    end
    if !((tusacState == tsGameLoop)||(tusacState == tsHistory))
        for i = 1:112
            if ((cardSelect == false)) && (i == BIGcard)
                saveI = i
            elseif (openAllCard == true) || ((mask[i] & 0x1) == 0)
                draw(actors[i])
            else
                draw(fc_actors[i])
            end
        end
    elseif (tusacState == tsGameLoop)||(tusacState == tsHistory)
        for i in 1:4
            saveI = saveI + drawAhand(all_hands[i])
            saveI = saveI + drawAhand(all_assets[i])
            saveI = saveI + drawAhand(all_discards[i])
        end
        saveI = saveI + drawAhand(TuSacCards.getDeckArray(gameDeck))
    end
  
    if saveI != 0
        draw(big_actors[saveI])
    end
    if ActiveCard != 0
        if drawCnt >20
            draw(big_actors[ActiveCard])
        end
    end
    draw(handPic)
    draw(winnerPic)
    draw(errorPic)
end
