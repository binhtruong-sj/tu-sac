using GameZero
using Sockets
macOS = false
myPlayer = 1

const plHuman = 0
const plBot1 = 1
const plBot2 = 2
const plBot3 = 3
const plSocket = 5
const m_client = 0
const m_server = 1
const m_standalone = 2
cardScale = 90

noGUI_list = [true,true,true,true]
PlayerList =[plBot1,plBot1,plBot1,plBot1]
GUIname = Vector{Any}(undef,4)
numberOfSocketPlayer = 0
playerName = ["Binh-bot1","Binh-bot2","Binh-bot3","Binh-bot4"]

playerMaptoGUI(m) = rem(m-1+4-myPlayer+1,4)+1
GUIMaptoPlayer(m) = rem(m-1+myPlayer-1,4)+1
noGUI() = noGUI_list[myPlayer]

coldStart = true
isServer() = mode == m_server
println(PROGRAM_FILE)
n = PROGRAM_FILE
n = chop(n,tail=3)
fn = string(n,".cfg")
println((fn,isfile(fn)))
mode_human = false
mode = m_standalone
serverURL = "baobinh.tpdlinkdns.com"
serverPort = 11029
serverIP = ip"192.168.0.35"
GAMEW =900
GENERIC = 3
hints = 0
GUI = true
NAME= "PLayer?"
fontSize = 50
println((PlayerList, mode,mode_human,serverURL,serverIP,serverPort, GAMEW,macOS,numberOfSocketPlayer,myPlayer))
function config(fn)
    if !isfile(fn)
        println(fn," does not exist, please configure one. Similar to this\n
        name Binh
        mode standalone
        GUI true
        human true
        server baobinh.tplinkdns.com 11029
        client 192.168.0.53
        GAMEW 900
        macOS true")
    else
        cfg_str = readlines(fn)
        for line in cfg_str
            global PlayerList,noGUI_list, mode,NAME,playerName,GUI,fontSize,
            mode_human,serverURL,serverIP,serverPort, hints,
            GAMEW,macOS,numberOfSocketPlayer,myPlayer,GENERIC
            rl = split(line,' ')
            println((rl))
            if rl[1] == "name"
                NAME = rl[2]
                playerName[myPlayer] =NAME
            elseif rl[1] == "mode"
                mode = rl[2] == "client" ? m_client : rl[2] == "server" ? m_server : m_standalone
            elseif rl[1] == "human"
                mode_human = rl[2] == "true"
            elseif rl[1] == "server"
                serverURL = string(rl[2])
                serverPort = parse(Int,rl[3])
            elseif rl[1] == "myIP"
                serverIP = getaddrinfo(string(rl[2]))
                println(serverIP)
            elseif rl[1] == "GAMEW"
                GAMEW = parse(Int,rl[2])
            elseif rl[1] == "GENERIC"
                GENERIC = parse(Int,rl[2])
            elseif rl[1] == "hints"
                hints = parse(Int,rl[2])
                println("hints = ",hints)
            elseif rl[1] == "fontSize"
                fontSize = parse(Int,rl[2])
            elseif rl[1] == "numberOfSocketPlayer"
                numberOfSocketPlayer = parse(Int,rl[2])
            elseif rl[1] == "cardScale"
                cardScale = parse(Int,rl[2])
            elseif rl[1] == "myPlayer"
                myPlayer = parse(Int,rl[2])
                println(rl[2]," = ",myPlayer)
            elseif rl[1] == "macOS"
                macOS = rl[2] == "true"
            elseif rl[1] == "GUI"
                    global GUI = rl[2] == "true"
            end
        end
    end
    if GUI
        noGUI_list[myPlayer] = false
    end
    if mode == m_standalone && mode_human
        PlayerList[myPlayer] = plHuman
    end
    return (PlayerList, mode,mode_human,serverURL,serverIP,serverPort, GAMEW,macOS,numberOfSocketPlayer,myPlayer)
end
prevWinner = 1

(PlayerList, mode,mode_human,serverURL,serverIP,
serverPort, GAMEW,macOS,
numberOfSocketPlayer,myPlayer) = config(fn)
println((PlayerList, mode,mode_human,serverURL,
serverIP,serverPort, GAMEW,macOS,
numberOfSocketPlayer,myPlayer))
if coldStart
    eRrestart = false
end
if macOS
    println("macOS")
const macOSconst = 1
    gameW = 900
    HEIGHT = gameW
    WIDTH = div(gameW * 16, 9)
    realHEIGHT = HEIGHT * 2
    realWIDTH = WIDTH * 2
    cardXdim = 64
    cardYdim = 210
    zoomCardYdim = 400
    GENERIC = 0
else
    if GENERIC == 1    
        gameW = 820
        cardXdim = 24
        cardYdim = 80
        zoomCardYdim = 110
    elseif GENERIC == 2
        gameW = 820
        cardXdim = 34
        cardYdim = 110
        zoomCardYdim = 210
    elseif GENERIC == 3
        gameW = 820
        cardXdim = 64
        cardYdim = 210
        zoomCardYdim = 295
    else
        gameW = 820
        cardXdim = 90
        cardYdim = 295
        zoomCardYdim = 400
    end
    println("NO macOS")
    const macOSconst = 0
    HEIGHT = gameW
    WIDTH = div(gameW * 16, 9)
    realHEIGHT = div(HEIGHT, 1)
    realWIDTH = div(WIDTH, 1)
    
end
boDoi = 0
zoomCardXdim = div(zoomCardYdim*cardXdim,cardYdim)
const tableXgrid = 20
const tableYgrid = 20
FaceDown = true
const cardGrid = 4
const gameDeckMinimum = 9
eRrestart = 1
const eRcheck = 2
gameEnd = 1
function gameOver(n) 
    global eRrestart
    global gameEnd = n
    global FaceDown = false
    if 0 < n < 5
        updateWinnerPic(n)
    end
    replayHistory(0)
   
        println()
end
isGameOver() = gameEnd > 0


function playerIsHuman(p) 
    return (p == myPlayer && mode_human)
end
humanIsGUI() = mode_human & !noGUI()

function RESET1()
        
    if coldStart
        global currentPlayer = 1
    else
        global currentPlayer = gameEnd
    end
    global gotClick = false
    global GUI_array=[]
    global GUI_ready=false
    FaceDown = true
    global HISTORY = []
    global waitForHuman = false
    global handPic
    global pBseat = []

    global drawCnt = 1
    global gsHcnt = 1


global all_hands = []
global all_discards = []
global all_assets = []
global gameDeckArray =[]

end
const gpPlay1card = 1
const gpCheckMatch1or2 = 3
const gpCheckMatch2 = 2
const gpPopCards = 4

const gsHarrayNamehands = 1
const gsHarrayNamediscards = 2
const gsHarrayNameassets = 3
const gsHarrayNamegameDeck = 4

"""
table-grid, giving x,y return grid coordinate
"""
tableGridXY(gx, gy) = (gx - 1) * div(realWIDTH, tableXgrid),
(gy - 1) * div(realHEIGHT, tableYgrid)
reverseTableGridXY(x, y) = div(x, div(realWIDTH, tableXgrid)) + 1,
div(y, div(realHEIGHT, tableYgrid)) + 1

module nwAPI
using Sockets
export nw_sendToMaster,nw_sendTextToMaster,nw_receiveFromMaster,nw_receiveFromPlayer,nw_receiveTextFromPlayer, nw_sentToPlayer, nw_getR, serverSetup, clientSetup

function serverSetup(serverIP,port)
   # return(listen(ip"192.168.0.53",11029))
    return(listen(serverIP,port))
end

function acceptClient(s)
    return(accept(s))
end
function clientSetup(serverURL,port)
    return(connect(serverURL,port))
end

function nw_sendToMaster(id,connection,arr)
    
   l = length(arr)
    println(id,"  NNNNSend to Master DATA=",(arr,l))
    
    if l != 112
        s_arr = Vector{UInt8}(undef,8)

        s_arr[1] = l
        for (i,a) in enumerate(arr)
            s_arr[i+1] = a
        end
        println("Data = ",s_arr)        
    else
        s_arr = Vector{UInt8}(undef,l)

        for (i,a) in enumerate(arr)
            s_arr[i] = a
        end
    end
    write(connection,s_arr)
end

function nw_sendTextToMaster(id,connection,txt)
    println(connection,txt)
end

function nw_receiveTextFromMaster(connection)
    println("waiting to receive Text from Master")
    return readline(connection)
end


function nw_receiveFromMaster(connection,bytecnt)
    println(" NNNN receive from Master")
    arr = []
   while true
        arr = read(connection,bytecnt)
        if length(arr) != bytecnt
            println(length(arr),"!=",bytecnt)

            sleep(1)
        else
            break
        end
    end
    println("NNNNreceived ",arr," from master ")
    return(arr)
end

function nw_receiveFromPlayer(id,connection,bytecnt)
    arr = []
    println(" NNNN received from Player ", id )
    while true
        arr = read(connection,bytecnt)
        if length(arr) != bytecnt
            println(length(arr),"!=",bytecnt)
            sleep(1)
        else
            break
        end
    end
    println("NNNNmaster received ",arr)
return(arr)
end

function nw_receiveTextFromPlayer(id,connection)
    return readline(connection)  
end

function nw_sendTextToPlayer(id, connection, txt)
    println("Sendint text=",txt," to ",id)
    println(connection,txt)
end

function nw_sendToPlayer(id, connection, arr)
    l = length(arr)
    println("NNNNSend to Player ",id,"  DATA=",(arr,l))
   
     
    if l != 112
        s_arr = Vector{UInt8}(undef,8)
        s_arr[1] = l
        for (i,a) in enumerate(arr)
            s_arr[i+1] = a
        end
        println("Data = ",s_arr)        
    else
       
        s_arr = Vector{UInt8}(undef,l)
        for (i,a) in enumerate(arr)
            s_arr[i] = a
        end
    end
    
    write(connection,s_arr)
end
function nw_getR(nw)
    n = []
     for i in 1:nw[1]
        push!(n,nw[i+1])
     end
     return n
end


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
export Deck, shuffle!, ssort, full_deck, ordered_deck, ordered_deck_chot, humanShuffle!, dealCards, full_deck_chot
export getCards, rearrange, sort!, rcut, moveCards!
export test_deck, getDeckArray, newDeckUsingArray
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
    println("\nRCUT")
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
    println("\nSHUFFLE -- random")
    deck.cards .= deck.cards[randperm(length(deck.cards))]
    deck
end

lowhi(r1, r2) = r1 > r2 ? (r2, r1) : (r1, r2)
nextWrap(n::Int, d::Int, max::Int) = ((n + d) > max) ? 1 : (n + d)

"""
"""
function getDeckArray(deck::Deck)
    l = length(deck)
    a = Vector{UInt8}(undef,l)
    i = 1
    for card in deck
        a[i] = card.value
        i += 1
    end
    return a
end
"""
"""
function getDeckArray(deck::Vector{Card})
    l = length(deck)
    a = Vector{UInt8}(undef,l)
    i = 1
    for card in deck
        a[i] = card.value
        i += 1
    end
    return a
end

newDeckUsingArray(arr) = Card[Card(a) for a in arr ]
#=
function newDeckUsingArray(arr)
    newDeck = []
    for a in arr
        push!(newDeck,Card(a))
d    end
end
=#

"""
autoShuffle:
    gradienDir - (20 or 40) +/- 4

    - is up/left
    + is down/right
"""
function humanShuffle!(deck::Deck, ySize, gradienDir)
    println("\nHUMAN-shuffle")
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
    if r < 10
        deck = rcut(deck)
    end
    deck
end

end # module
######################################################################
RESET1()


"""
setupActorgameDeck:
    Set up the Full Deck of Actor to use for the whole game, linked to TuSacCards.Card by
    Card.value
"""
function setupActorgameDeck()
    if noGUI()
        return
    end
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
                    if GENERIC == 1
                        local m = r < 4 ? r : (r == 4 ? 7 : r - 1)
                        mapr = m == 5 ? 6 : m == 6 ? 5 : m
                        st = string(s, mapr, "xs.png")
                        big_st = string(s, mapr, "s.png")
                        afc = Actor("fcxs.png")
                    elseif GENERIC == 2
                        local m = r < 4 ? r : (r == 4 ? 7 : r - 1)
                        mapr = m == 5 ? 6 : m == 6 ? 5 : m
                        st = string(s, mapr, "s.png")
                        big_st = string(s, m, ".png")
                        afc = Actor("fcs.png")
                    elseif GENERIC == 3
                        local m = r < 4 ? r : (r == 4 ? 7 : r - 1)
                        mapr = m == 5 ? 6 : m == 6 ? 5 : m
                        st = string(s, m, ".png")
                        big_st = string(s, "-m", m, ".png")
                        afc = Actor("fc.png")
                    else
                        local m = r < 4 ? r : (r == 4 ? 7 : r - 1)
                        mapr = m == 5 ? 6 : m == 6 ? 5 : m
                        st = string(s, "-m", m, ".png")
                        big_st = string(s, "-", m, ".png")
                        afc = Actor("fc.png")
                    end
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
function RESET3()
    global actors, fc_actors, big_actors, mapToActors , mask,
    all_hands,all_discards,all_assets,gameDeckArray,ActiveCard,BIGcard 
    ActiveCard,BIGcard = 0,0
    all_hands = []
    all_discards = []
    all_assets = []
    gameDeckArray =[]
    actors = []
    fc_actors = []
    big_actors = []
    mapToActors =[]
    
    mask = zeros(UInt8, 112)
    if noGUI() == false
        actors, fc_actors, big_actors, mapToActors = setupActorgameDeck()
        println("lengths=",(length(actors),length(fc_actors), length(big_actors),
        length(mapToActors)))
    end

end
RESET3()
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
function setupDrawDeck(deck::TuSacCards.Deck, gx, gy, xDim, faceDown = false,gui = true)
    global modified_cardXdim, modified_cardYdim
    if noGUI()
        return
    end
    i = 0
    x, y = tableGridXY(gx, gy)

    if length(deck) == 0
        l = 20
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
        modified_cardXdim = div(cardXdim * cardScale,100)
        x1 = x + modified_cardXdim * xDim
        y1 = y + modified_cardYdim * yDim
    else
        l = length(deck)
        if xDim > 20
            xDim = l
            modified_cardXdim = div(cardXdim * cardScale,100)
            modified_cardYdim = div(cardYdim * cardScale,100)
        else
            t = (cardYdim >> 4)
            modified_cardYdim =
                faceDown ? (cardYdim - 8*t) : (cardYdim - 5*t)
            modified_cardXdim = div(cardXdim * cardScale,100)
            modified_cardYdim = div(modified_cardYdim * cardScale,100)

        end
        for card in deck
            m = mapToActors[card.value]
            px = x + (modified_cardXdim * rem(i, xDim))
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
        x1 = x + modified_cardXdim * xDim
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
function tusacDeal(winner)
    global playerA_hand,playerB_hand,playerC_hand,playerD_hand
    global playerA_discards,playerB_discards,playerC_discards,playerD_discards
    global playerA_assets,playerB_assets,playerC_assets,playerD_assets

    println()
    println(gameDeck)
    P0_hand = TuSacCards.Deck(pop!(gameDeck, 6))
    println(P0_hand)
    P1_hand = TuSacCards.Deck(pop!(gameDeck, 5))
    P2_hand = TuSacCards.Deck(pop!(gameDeck, 5))
    P3_hand = TuSacCards.Deck(pop!(gameDeck, 5))
    for i = 2:4
        push!(P0_hand, pop!(gameDeck, 5))
        push!(P1_hand, pop!(gameDeck, 5))
        push!(P2_hand, pop!(gameDeck, 5))
        push!(P3_hand, pop!(gameDeck, 5))
    end
    rPlayer = myPlayer - winner + 5
    playerSel = rPlayer > 4 ? rPlayer - 4 : rPlayer
    println("prev-winner,nex", (winner,playerSel))
    if playerSel == 1
        playerA_hand = P0_hand
        playerB_hand = P1_hand
        playerC_hand = P2_hand
        playerD_hand = P3_hand
    elseif playerSel == 2
        playerA_hand = P1_hand
        playerB_hand = P2_hand
        playerC_hand = P3_hand
        playerD_hand = P0_hand
    elseif playerSel == 3
        playerA_hand = P2_hand
        playerB_hand = P3_hand
        playerC_hand = P0_hand
        playerD_hand = P1_hand
    else
        playerA_hand = P3_hand
        playerB_hand = P0_hand
        playerC_hand = P1_hand
        playerD_hand = P2_hand
    end


    println(playerA_hand)
    println(playerB_hand)
    println(playerC_hand)
    println(playerD_hand)
    FaceDown = true

    setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)

    setupDrawDeck(playerD_hand, 1, 2, 2, FaceDown)
    setupDrawDeck(playerC_hand, 7, 2, 100, FaceDown)

    global pBseat = setupDrawDeck(playerB_hand, 20, 2, 2, FaceDown)
    global human_state = setupDrawDeck(playerA_hand, 7, 18, 100, false)

    global playerA_discards = TuSacCards.Deck(pop!(gameDeck, 1))
    global playerB_discards = TuSacCards.Deck(pop!(gameDeck, 1))
    global playerC_discards = TuSacCards.Deck(pop!(gameDeck, 1))
    global playerD_discards = TuSacCards.Deck(pop!(gameDeck, 1))
 
    global playerA_assets = TuSacCards.Deck(pop!(gameDeck, 1))
    global playerB_assets = TuSacCards.Deck(pop!(gameDeck, 1))
    global playerC_assets = TuSacCards.Deck(pop!(gameDeck, 1))
    global playerD_assets = TuSacCards.Deck(pop!(gameDeck, 1))

    push!(gameDeck,pop!(playerD_assets,1))
    push!(gameDeck,pop!(playerC_assets,1))
    push!(gameDeck,pop!(playerB_assets,1))
    push!(gameDeck,pop!(playerA_assets,1))

    push!(gameDeck,pop!(playerD_discards,1))
    push!(gameDeck,pop!(playerC_discards,1))
    push!(gameDeck,pop!(playerB_discards,1))
    push!(gameDeck,pop!(playerA_discards,1))

    replayHistory(0)

end

#ar = TuSacCards.getDeckArray(dd)
#println(ar)
const gsOrganize = 1
const gsSetupGame = 2
const gsStartGame = 3
const gsGameLoop = 4
const gsRestart = 5

const tsSinitial = 0
const tsSdealCards = 1
const tsSstartGame = 2
const tsGameLoop = 3
const tsRestart = 6
const tsTest = 4
const tsHistory = 5

tusacState = tsSinitial

function ts(a)
    if length(a) == 1
        TuSacCards.Card(a)
    else
        ts_s(a)
    end
end

function ts_s(rt)
    for r in rt
        print(ts(r), " ")
    end
    println()
    return
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

"""
    all_chots(cards,pc)
all is Chots
"""
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

function printAllInfo()
    println("==========Hands")
    for (i,ah) in enumerate(all_hands)
        print(i,": ")
        ts_s(ah)
    end
    println("==========Discards")
        for (i,ah) in enumerate(all_discards)
            print(i,": ")
        ts_s(ah)
    end
    println("===========Assets")
        for (i,ah) in enumerate(all_assets)
            print(i,": ")
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
    if length(s) >0
         println("c-scan",(p,s))
    end
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
    if length(union(s,n)) > 1
         println("c-match ",(p,s,n))
    end
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
            if length(p[2])>0 # at least 1 3-pair
                    return [p[2][1][1],s[1]] # use 1 of the 3-pair
            else
                if length(p[1])>1 # at least 2 2-pair and 1-single
                    return [p[1][1][1],p[1][2][1]]
                elseif length(p[1])==1 && !card_equal(n,p[1][1][1])
                    return [p[1][1][1],s[1]]
                else 
                    return []
                end
            end
        end
    else 
        if length(p[2])>1  #not sure about this
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

function updateHandPic(np)
   cp = playerMaptoGUI(np)
    if cp == 1 
        gx,gy = 7, 14
    elseif cp == 2
        gx,gy = 17,12
    elseif cp == 3
        gx,gy = 12, 6
    else 
        gx,gy = 3,12
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

function updateWinnerPic(np) 

    if noGUI()
        return
    end
    cp = playerMaptoGUI(np)
    
    if np == 0
        gx,gy = 20,20
    elseif cp == 1 
        gx,gy = 7, 14
    elseif cp == 2
        gx,gy = 17,12
    elseif cp == 3
        gx,gy = 12, 6
    else 
        gx,gy = 3,12
    end

    winnerPic.pos = tableGridXY(gx, gy)
end

function removeCards!(array, n, cards)
    for c in cards
        println("REMOVE ",ts(c)," from ",n," map-> ",playerMaptoGUI(n))
        found = false
        for l = 1:length(array[n])
            if c == array[n][l]
                found = true
                splice!(array[n], l)
                break
            end
        end
        @assert found
        m = playerMaptoGUI(n)
        FaceDown = !isGameOver()

        if m== 1
            pop!(playerA_hand,ts(c))
            println((m,playerA_hand))
            global human_state = setupDrawDeck(playerA_hand, 7, 18, 100, false)

        elseif m == 2
            pop!(playerB_hand,ts(c))
            println((m,playerB_hand))
            setupDrawDeck(playerB_hand, 20, 2, 2, FaceDown)

        elseif m == 3
            pop!(playerC_hand,ts(c))
            println((m,playerC_hand))
            setupDrawDeck(playerC_hand, 7, 2, 100, FaceDown)

        elseif m == 4
            pop!(playerD_hand,ts(c))
            println((m,playerD_hand))
            setupDrawDeck(playerD_hand, 1, 2, 2, FaceDown)

        end

    end
end
function addCards!(array,arrNo, n, cards)
    m  = playerMaptoGUI(n)
    for c in cards
        push!(array[n], c)
        if arrNo == 0
            if m== 1
                push!(playerA_assets,ts(c))
                asset1 = setupDrawDeck(playerA_assets, 9, 13, 30, false)

            elseif m == 2
                push!(playerB_assets,ts(c))
                asset2 = setupDrawDeck(playerB_assets, 16, 7, 4, false)

            elseif m == 3
                push!(playerC_assets,ts(c))
                asset3 = setupDrawDeck(playerC_assets, 8, 4, 30, false)

            elseif m == 4
                push!(playerD_assets,ts(c))
                asset4 = setupDrawDeck(playerD_assets, 4, 7, 4, false)

            end
        else
            if m== 1
                push!(playerA_discards,ts(c))
                setupDrawDeck(playerA_discards, 16, 15, 8, false)
            elseif m == 2
                push!(playerB_discards,ts(c))
                setupDrawDeck(playerB_discards, 16, 2, 8, false)

            elseif m == 3
                push!(playerC_discards,ts(c))
                setupDrawDeck(playerC_discards, 3, 2, 8, false)

            elseif m == 4
                push!(playerD_discards,ts(c))
                discard4 = setupDrawDeck(playerD_discards, 3, 16, 8, false)

            end
        end
    end
end

function replayHistory(index)
    global HISTORY,all_hands,all_assets,all_discards,gameDeckArray, glIterationCnt,glNeedaPlayCard,glPrevPlayer
    global playerA_hand, playerA_discards, playerA_assets
    global playerB_hand, playerB_discards, playerB_assets
    global playerC_hand, playerC_discards, playerC_assets
    global playerD_hand, playerD_discards, playerD_assets
    global gameDeck,boxes,coldStart
    if index != 0
        a = HISTORY[index]
        playerA_hand = deepcopy(a[1])
        playerB_hand = deepcopy(a[2])
        playerC_hand = deepcopy(a[3])
        playerD_hand = deepcopy(a[4])

        playerA_assets = deepcopy(a[5])
        playerB_assets = deepcopy(a[6])
        playerC_assets = deepcopy(a[7])
        playerD_assets = deepcopy(a[8])

        playerA_discards = deepcopy(a[9])
        playerB_discards = deepcopy(a[10])
        playerC_discards = deepcopy(a[11])
        playerD_discards = deepcopy(a[12])

        gameDeck = deepcopy(a[13])

        global glIterationCnt,glNeedaPlayCard,glPrevPlayer,ActiveCard,BIGcard = a[14]
        updateHandPic(glPrevPlayer)
    end
    d1 = setupDrawDeck(playerA_discards, 16, 15, 8, false)
    d2 = setupDrawDeck(playerB_discards, 16, 2, 8, false)
    d3 = setupDrawDeck(playerC_discards, 3, 2, 8, false)
    d4 = setupDrawDeck(playerD_discards, 3, 16, 8, false)

    d5 = setupDrawDeck(playerA_assets, 9, 13, 30, false)
    d6 = setupDrawDeck(playerB_assets, 16, 7, 4, false)
    d7 = setupDrawDeck(playerC_assets, 8, 4, 30, false)
    d8 = setupDrawDeck(playerD_assets, 4, 7, 4, false)
    FaceDown = !isGameOver()

    global human_state = setupDrawDeck(playerA_hand, 7, 18, 100, false)
    a4 = setupDrawDeck(playerD_hand, 1, 2, 2, FaceDown)
    a3 = setupDrawDeck(playerC_hand, 7, 2, 100, FaceDown)
    a2 = setupDrawDeck(playerB_hand, 20, 2, 2, FaceDown)
    a5 = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
    if tusacState < tsGameLoop
        boxes =[]
        push!(boxes,human_state,d1,d2,d3,d4, d5,d6,d7,d8, a2,a3,a4,a5)
    end
end


nextPlayer(p) = p == 4 ? 1 : p + 1

function whoWinRound(card, play4,  n1, r1, n2, r2, n3, r3, n4, r4)
    function getl(card, n, r)
        l = length(r)
        if (l > 1) && !card_equal(r[1], r[2]) # not pairs
            l = 1
        end
       
        thand = deepcopy(all_hands[n])
        moreTrash = false
        ops,oss,ocs,om1s,omts,ombs =  scanCards(thand, true)
        TrashCnt = length(ocs)

        win = false
        if l > 0 || is_T(card)# only check winner that has matched cards
           

            for e in r
                filter!(x -> x != e, thand)
            end
            ps, ss, cs, m1s, mts, mbs = scanCards(thand, false)
            if (l == 2) && card_equal(r[1],r[2]) # check for SAKI
                for m in mbs
                    if card_equal(m,r[1]) && !is_t(m) && !is_s(m)
                        println("match ",ts_s(r)," is SAKI, not accepted")
                        l = 0
                    end
                end
            end
          
            ll = length(union(ss, cs, m1s, mts, mbs)) 
            lc = length(cs)
            if false && TrashCnt < lc  # need more work
                println("Illegal match -- creating more trash ",(TrashCnt,lc))
                ts_s(ocs)
                ts_s(oc)
                l = 0
            end
            if ll == 0
                println("WINWINWINWINWINWINWINWINWINWIWN")
                l = 4
                win = true
            end 
        end
        return l, win
    end

    l1, w1 = getl(card, n1, r1)
    l2, w2 = getl(card, n2, r2)
    l3, w3 = getl(card, n3, r3)
    l4, w4 = getl(card, n4, r4)
    if !play4 && (l2 == 1)
            l2 = 0
    end

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
            if play4 && (l2 > 0) && (l1 == 0)
                w = 1
            else 
                w = 0
            end
        end
    end
    r = w == 0 ? r1 : w == 1 ? r2 : w == 2 ? r3 : r4
    n = rem((n1 - 1 + w), 4) + 1
    if w1 || w2 || w3 || w4   # game over
        w = 0xFE
    end
    println("Who win ?  n,w,r", (n, w, r), (l1, l2, l3, l4),(r1,r2,r3,r4))
    return n, w, r
end

function getData_all_discard_assets()
    global all_discards,all_assets

    all_discards = []
    all_assets = []
    adjustPlayer = myPlayer

    if adjustPlayer == 1

    push!(
        all_discards,
        TuSacCards.getDeckArray(playerA_discards),
        TuSacCards.getDeckArray(playerB_discards),
        TuSacCards.getDeckArray(playerC_discards),
        TuSacCards.getDeckArray(playerD_discards),
    )
    push!(
        all_assets,
        TuSacCards.getDeckArray(playerA_assets),
        TuSacCards.getDeckArray(playerB_assets),
        TuSacCards.getDeckArray(playerC_assets),
        TuSacCards.getDeckArray(playerD_assets),
    )
    elseif adjustPlayer == 4
        push!(
            all_discards,
            TuSacCards.getDeckArray(playerB_discards),
            TuSacCards.getDeckArray(playerC_discards),
            TuSacCards.getDeckArray(playerD_discards),
            TuSacCards.getDeckArray(playerA_discards),
        )
    
        push!(
            all_assets,
            TuSacCards.getDeckArray(playerB_assets),
            TuSacCards.getDeckArray(playerC_assets),
            TuSacCards.getDeckArray(playerD_assets),
            TuSacCards.getDeckArray(playerA_assets),
        )
    elseif adjustPlayer == 3
        push!(
            all_discards,
            TuSacCards.getDeckArray(playerC_discards),
            TuSacCards.getDeckArray(playerD_discards),
            TuSacCards.getDeckArray(playerA_discards),
            TuSacCards.getDeckArray(playerB_discards),
        )
    
        push!(
            all_assets,
            TuSacCards.getDeckArray(playerC_assets),
            TuSacCards.getDeckArray(playerD_assets),
            TuSacCards.getDeckArray(playerA_assets),
            TuSacCards.getDeckArray(playerB_assets),
        )
    elseif adjustPlayer == 2
        push!(
            all_discards,
            TuSacCards.getDeckArray(playerD_discards),
            TuSacCards.getDeckArray(playerA_discards),
            TuSacCards.getDeckArray(playerB_discards),
            TuSacCards.getDeckArray(playerC_discards),
        )
    
        push!(
            all_assets,
            TuSacCards.getDeckArray(playerD_assets),
            TuSacCards.getDeckArray(playerA_assets),
            TuSacCards.getDeckArray(playerB_assets),
            TuSacCards.getDeckArray(playerC_assets),
        )

    end
end
function getData_all_hands()
    adjustPlayer = myPlayer
    if length(all_hands) > 0
        pop!(all_hands)
        pop!(all_hands)
        pop!(all_hands)
        pop!(all_hands)
    end
    if adjustPlayer == 1
        push!(
            all_hands,
            TuSacCards.getDeckArray(playerA_hand),
            TuSacCards.getDeckArray(playerB_hand),
            TuSacCards.getDeckArray(playerC_hand),
            TuSacCards.getDeckArray(playerD_hand),
        )

    elseif adjustPlayer == 4
        push!(
            all_hands,
            TuSacCards.getDeckArray(playerB_hand),
            TuSacCards.getDeckArray(playerC_hand),
            TuSacCards.getDeckArray(playerD_hand),
            TuSacCards.getDeckArray(playerA_hand),
        )
    
    elseif adjustPlayer == 3
        push!(
            all_hands,
            TuSacCards.getDeckArray(playerC_hand),
            TuSacCards.getDeckArray(playerD_hand),
            TuSacCards.getDeckArray(playerA_hand),
            TuSacCards.getDeckArray(playerB_hand),
        )
    
    elseif adjustPlayer == 2
        push!(
            all_hands,
            TuSacCards.getDeckArray(playerD_hand),
            TuSacCards.getDeckArray(playerA_hand),
            TuSacCards.getDeckArray(playerB_hand),
            TuSacCards.getDeckArray(playerC_hand),
        )
    
    end
end

function toDeck(arr,brr,crr,d) 
    r = Vector{UInt8}(undef,112+12)
    i = 1
    for mr in [arr,brr,crr]
        for m in mr
        for a in m
            r[i] = a
            i += 1
        end
    end
    end
    for a in d
        r[i] = a
        i += 1
    end

    for a in [arr,brr,crr]
        for m in a
        println((i,length(m)))
        r[i] = length(m)
        i += 1
        end
    end
    
    return r
end
function whoWin!(glIterationCnt, pcard,play3,t1Player,t2Player,t3Player,t4Player)

    if  rReady[t1Player] &&
        rReady[t2Player] &&
        rReady[t3Player] &&
       (play3  ||
        rReady[t4Player]  )
        n1c = rQ[t1Player]
        println(n1c)
        n2c = rQ[t2Player]
        println(n2c)
        n3c = rQ[t3Player]
        println(n3c)
        if !play3
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
    println("AT whoWin",(glNeedaPlayCard),(n1c,n2c,n3c,n4c,glNewCard),(t1Player,t2Player,t3Player,t4Player),
    (PlayerList[t1Player],PlayerList[t2Player],
    PlayerList[t3Player],PlayerList[t4Player])
    )
    
    if (PlayerList[myPlayer] != plSocket) && isServer()
        println("Getting ALL remote-Results back")
        if PlayerList[t1Player] == plSocket
            println("mr-t1")
            n1c = nwAPI.nw_getR(nwAPI.nw_receiveFromPlayer(t1Player, nwPlayer[t1Player],8))
        end
        if PlayerList[t2Player] == plSocket
            println("mr-t2")
            n2c = nwAPI.nw_getR(nwAPI.nw_receiveFromPlayer(t2Player, nwPlayer[t2Player],8))
        end
        if PlayerList[t3Player] == plSocket
            println("mr-t3")
            n3c = nwAPI.nw_getR(nwAPI.nw_receiveFromPlayer(t3Player, nwPlayer[t3Player],8))
        end
        if PlayerList[t4Player] == plSocket
            if !play3
                println("mr-t4")
                n4c = nwAPI.nw_getR(nwAPI.nw_receiveFromPlayer(t4Player, nwPlayer[t4Player],8))
            end
        end

        nPlayer, winner, r = whoWinRound(
            pcard,
            !play3,
            t1Player,
            n1c,
            t2Player,
            n2c,
            t3Player,
            n3c,
            t4Player,
            n4c,
        )
        function nw_makeR2(a,b,r) 
            s_ar = []
            push!(s_ar,a,b,length(r))
            for ar in r 
                push!(s_ar,ar)
            end
            return s_ar
        end
        msg = nw_makeR2(nPlayer, winner, r )
        for i in 1:4
            if(PlayerList[i] == plSocket)
                nwAPI.nw_sendToPlayer(i,nwPlayer[i],msg)
            end
        end
    elseif PlayerList[myPlayer] == plSocket
            r =[]
            if t1Player == myPlayer
                println("sm-t1")
                r = n1c
                nwAPI.nw_sendToMaster(myPlayer, nwMaster,r)
            elseif t2Player == myPlayer
                println("sm-t2")
                r = n2c
                nwAPI.nw_sendToMaster(myPlayer, nwMaster,r)
            elseif t3Player == myPlayer
                println("sm-t3")
                r = n3c
                nwAPI.nw_sendToMaster(myPlayer, nwMaster,r)
            else
                if !play3
                    println("sm-t4")
                    r = n4c
                    nwAPI.nw_sendToMaster(myPlayer, nwMaster,r)
                end
            end
            println(myPlayer," Sending result to Master",(length(r),r))

            println("Getting from master -- result of who win")
            rmsg = nwAPI.nw_receiveFromMaster(nwMaster,8)
            nPlayer, winner, l= rmsg[2],rmsg[3],rmsg[4]
            r = []
            for i in 1:l
                push!(r,rmsg[i+4])
            end
            println("received =" , (nPlayer, winner, l, r))
            if winner&0xFF == 0xFE
                println("Game Over, player ", nPlayer, " win")
                gameOver(nPlayer)
            end
    else
        nPlayer, winner, r = whoWinRound(
            pcard,
            !play3,
            t1Player,
            n1c,
            t2Player,
            n2c,
            t3Player,
            n3c,
            t4Player,
            n4c,
        )
    end
    return nPlayer, winner, r
end

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
            if humanIsGUI()
                if GUI_ready
                    rReady[player] = true
                    rQ[player]=GUI_array
                    print("Human-p: ", player," PlayCard = ", )
                    ts_s(rQ[player])
                    GUI_ready = false
                else
                    return false
                end
            else  
                cards = keyboardInput(player)
                ts_s(cards)
                rQ[player]=cards
                rReady[player] = true
                println("PlayCard = ", (cards))
                ts_s(cards)
            end
        end
        return true
    end
    function All_hand_updateActor(card,facedown) 
        if noGUI()
            return
        end
        global lsx,lsy
        global prevActiveCard = ActiveCard
        mmm = mapToActors[card]
        ActiveCard = mmm
        lsx, lsy = actors[mmm].pos
        FaceDown = !isGameOver()

        if facedown == FaceDown
            mask[mmm] = mask[mmm] & 0xFE
        else
            mask[mmm] = mask[mmm] | 0x1
        end
        
    end
    function checkMaster(action,gpPlayer)
        # socket is a remote player
        # for The master: if the currentPlayer (gpPlayer) is a socket, then we need its pcard. If not, our bot has the card. After getting the right card, we need to send to other computers/Players so they can update/override their bots result
       # println("in CheckMaster ",(action,gpPlayer))

        if(action == gpPlay1card)
            if rReady[gpPlayer] == true
                cards = rQ[gpPlayer]
            else
                return
            end
            println((ts(cards[1]),UInt8(cards[1])))
            isMaster = (PlayerList[myPlayer] != plSocket) 
            if isMaster  
                if PlayerList[gpPlayer] == plSocket 
                    msg = nwAPI.nw_receiveFromPlayer(gpPlayer, nwPlayer[gpPlayer], 8)
                    final_card = msg[2]
                else
                    final_card = cards 
                end
                for p in 1:4
                    if PlayerList[p] == plSocket
                        if(gpPlayer != p)
                            nwAPI.nw_sendToPlayer(p,nwPlayer[p],final_card)
                        end
                    end
                end
            else 
                if gpPlayer == myPlayer 
                    final_card = cards
                    nwAPI.nw_sendToMaster(myPlayer, nwMaster,final_card)
                else
                    msg = nwAPI.nw_receiveFromMaster(nwMaster,8)
                    final_card =msg[2]
                end
            end
            rReady[gpPlayer] = true
            rQ[gpPlayer] = final_card
            return
        end
       
    end

    if(rem(glIterationCnt,4) ==0)
     
        glIterationCnt += 1
        println(
            "^+++++++++++++++++++++++++",
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
        end


    elseif(rem(glIterationCnt,4) ==1)
        FaceDown = !isGameOver()

        glIterationCnt += 1
        if glNeedaPlayCard
            checkHumanResponse(glPrevPlayer)
            checkMaster(gpPlay1card,glPrevPlayer)

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
        if glNeedaPlayCard
            cmd = gpCheckMatch2
        else
            cmd = gpCheckMatch1or2
        end
        t2Player = nextPlayer(t1Player)
        hgamePlay(
            all_hands,
            all_discards,
            all_assets,
            gameDeck,
            glNewCard;
            gpPlayer = t2Player,
            gpAction = cmd,
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
        
        gotHumanInput = true
        for i in  1:4
            if !(glNeedaPlayCard && (i == 4 ))
                gotHumanInput = gotHumanInput && checkHumanResponse(aplayer) 
            end
            aplayer = nextPlayer(aplayer)
        end
        if gotHumanInput == false
            glIterationCnt -= 1
            return
        end
        FaceDown = !isGameOver()

        nPlayer, winner, r =  whoWin!(glIterationCnt, glNewCard,glNeedaPlayCard,t1Player,t2Player,t3Player,t4Player)
        if glNeedaPlayCard
            removeCards!(all_hands, glPrevPlayer, glNewCard)
            All_hand_updateActor(glNewCard[1],!FaceDown)
        end
        global currentPlayer = nPlayer
        println("Active5 = ", currentPlayer)
            removeCards!(all_hands, nPlayer, r)
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
        elseif winner&0xFF == 0xFE
            println("GAME OVER, player", 
            nPlayer, " win")
            addCards!(all_assets,0,nPlayer,glNewCard)
            addCards!(all_assets, 0, nPlayer, r)

            updateWinnerPic(nPlayer)
            gameOver(nPlayer)

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

global openAllCard = false
function SNAPSHOT()
    currentStates =[glIterationCnt,glNeedaPlayCard,glPrevPlayer,ActiveCard,BIGcard]
    anE= []
    anE = deepcopy(
        [playerA_hand,
        playerB_hand,
        playerC_hand,
        playerD_hand,
        playerA_assets,
        playerB_assets,
        playerC_assets,
        playerD_assets,
        playerA_discards,
        playerB_discards,
        playerC_discards,
        playerD_discards,
        gameDeck,currentStates])
    push!(HISTORY,anE)
end

function playersSyncDeck!(deck::TuSacCards.Deck)
    global myPlayer
   
    println("in SYNC DECK MY player", myPlayer)
    isMaster = (PlayerList[myPlayer] != plSocket) 
    println(PlayerList)
    if mode == m_server
            println("MASTER",(PlayerList,myPlayer))

           if shufflePlayer != myPlayer
                dArray = nwAPI.nw_receiveFromPlayer(shufflePlayer, nwPlayer[shufflePlayer],112)
                println("\nold Deck",deck)
                deck = []
                deck = TuSacCards.newDeckUsingArray(dArray)
           end
            println("\nNew Deck=",deck)
            for i in 1:4
                    if PlayerList[i] == plSocket
                        if i != shufflePlayer
                            a = nwAPI.nw_receiveFromPlayer(i, nwPlayer[i],112)
                        end
                        nwAPI.nw_sendToPlayer(i,nwPlayer[i],dArray)
                    end
            end
    elseif mode == m_client
        println("PLAYER",(PlayerList,myPlayer))

        if PlayerList[myPlayer] == plSocket
            dArray = TuSacCards.getDeckArray(deck)
            println("Sending to Master the deck")
            nwAPI.nw_sendToMaster(myPlayer, nwMaster,dArray)
            dArray =[]
            dArray = nwAPI.nw_receiveFromMaster(nwMaster,112)
            println("oldDeck",deck)
            deck = []
            deck = TuSacCards.newDeckUsingArray(dArray)
            println("D2=",deck)
        end
    end
return(deck)
end
global nwPlayer = Vector{Any}(undef,4)

function networkInit()
global GUIname
if mode == m_server
    println("SERVER")
    global myS = nwAPI.serverSetup(serverIP,serverPort)
    signedOnPlayer = 0
    while signedOnPlayer < numberOfSocketPlayer 
        global p = nwAPI.acceptClient(myS)
        for i in 2:4
            global playerName

            if PlayerList[i] != plSocket
                PlayerList[i] = plSocket
                nwPlayer[i] = p
                nwAPI.nw_sendToPlayer(i,p,i)
                msg = nwAPI.nw_receiveTextFromPlayer(i,nwPlayer[i])
                print("Accepting Player ",i, " Name=",msg)
                playerName[i] = msg
                break
            end
        end
        signedOnPlayer += 1
    end
    for s in 2:signedOnPlayer+1
        for i in 1:4
            nwAPI.nw_sendTextToPlayer(s,nwPlayer[s],playerName[i])
        end
        nwAPI.nw_sendToPlayer(s,nwPlayer[s],numberOfSocketPlayer)
    end
    println("Player List:",playerName)
    global GUIname = Vector{Any}(undef,4)
    if !noGUI()
        GUIname[1]  = TextActor(playerName[1],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[1].pos = tableGridXY(10,20)
        GUIname[2]  = TextActor(playerName[2],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[2].pos = tableGridXY(18,1)
        GUIname[3]  = TextActor(playerName[3],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[3].pos = tableGridXY(10,1)
        GUIname[4]  = TextActor(playerName[4],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[4].pos = tableGridXY(1,1)
    end
elseif mode == m_client
    println("CLIENT")
    global nwMaster = nwAPI.clientSetup(serverURL,serverPort)
    msg = nwAPI.nw_receiveFromMaster(nwMaster,8)
    println(msg)
    global myPlayer = msg[2]
    PlayerList[myPlayer] = plSocket
    if GUI 
        noGUI_list[myPlayer] = false
    end
        

    println("Accepted as Player number ",myPlayer)
    nwAPI.nw_sendTextToMaster(myPlayer,nwMaster,NAME)
    for i in 1:4
        global playerName
        name = nwAPI.nw_receiveTextFromMaster(nwMaster)
        playerName[i] = name
    end
     nameRound(n)  = n > 4 ? n - 4 : n
    if !noGUI()
        GUIname[1]  = TextActor(playerName[nameRound(myPlayer-1+1)],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[1].pos = tableGridXY(10,20)
        GUIname[2]  = TextActor(playerName[nameRound(myPlayer-1+2)],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[2].pos = tableGridXY(18,1)
        GUIname[3]  = TextActor(playerName[nameRound(myPlayer-1+3)],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[3].pos = tableGridXY(10,1)
        GUIname[4]  = TextActor(playerName[nameRound(myPlayer-1+4)],"asapvar",font_size=fontSize,color=[0,0,0,0])
        GUIname[4].pos = tableGridXY(1,1)
    end
    println("Player List:",playerName)
    println("numberOfSocketPlayer", numberOfSocketPlayer)
    msg = nwAPI.nw_receiveFromMaster(nwMaster,8)
    global numberOfSocketPlayer = msg[2]
end
end
"""
gsStateMachine(gameActions)

gsStateMachine: control the flow/setup of the game

states  --  

    Flow of the card game is as follow:

    1) build gamedeck by calling ordered_deck
    2) function to mix up the card (multiple version), it can be autoShuffle
    or human-directed-shuffle (to emulate how human does it, not too random)
    3) dealCards: pretty simple, just like how the game supposed to deal, 1st 
    player get 6-cards.  All subsequence deals, 5 cards each.
    4) now it goes to gameloop by running gamePlay1Iteration, each iteration is always 
    fall-through (no-blocking), so that mouse/graphic still works. 
    5) A round of game take 4 iterations, allowing async events (waiting for player 
    to complete move) to complete. 
        5a) The first part of the round, is after figuring who win the round and become the 
        next player (done on previous iteration). 
        On this iteration, a player is either play a card, or picking a card from the deck.
        a call is made to gamePlay() to get current play to play the card if needed "glNeedaPlayCard"

        5b) after get the playcard (glNewCard), it is send to other players on a non-blocking call to 
        gamePlay() with the gpCheckMatch2/glCheckMatch1or2 command.  In this case,
        if player1 pick a card from the deck, then the round involves 4-player(1,2,3,4). If not, it
        only involves 3 players (1,2,3). All players works ASYNC and provide the results on the array "rQ" with 
        ready bits "rReady". The code will spin on the same iteration waiting for rReady bits.  Human player control
        the GUI will select the card the "click_card" and entering his choice.  It will
        be slow and async to the bots players. 
        Once all the results come in, whoWin is call to figure out who win the
        round.  It checks for legal move and final winning here too.
        5c + 5d) not much -- must moving cards from one pile to the others base on the 
        result of the round. Here is where the cards GUI got updated,
        The purpose of breaking the round into 4 is to allow non-blocking, making call to 4
        players and getting data back asyncronously.

    6) The iteration will continue until the gameDeck become too small (9) or somebody win.
    7) Not yet written (partially).  Reset the game, merge the cards and allow new game start with
    the ordered left by the game. Shuffle is still allowed on the next round (just the cards is not a new Deck)
    8)  Should be the same as (1) 
    
    That is the flow of a standalone game against 3 bots. With network-game against 3 other humans (some can be bots). 
    The following changes/problems are needed to be addressed: 

    1) shuffle can be done by any player, so the game-master/game-master must allow for that. 
    2) More than 1 human players (which does not present a problem), results will be out-of-order, and slow, but as soon as the
    last player enter his/her move, it will be fast. 
    3) All the bots will be on the game-master (dont have plan to support 2 players on 1 player). 
    So, experimental bots will need to be updated on the master version.
    4) It will be hard to synchonize all the variables on 4 versions of the code. 


The goal is to have one code to handle all mode/variation of plays:
            a) GUI 1-human against computer bots. 
            b) all 4 bots, with GUI, against each other. 
            c) 4 bots, no GUI.
            d) any combination human/bots on Network with GUI. In this
            case, a bots can be configureed to play instead of Human on remote computer. 
            
    d) Requires change to the code to support multiple/remote (different computer) (async) players.
       However, 4 four computer must be synchonized for correctness.
       
    These are the changes need on the step number:
    I)  on Step 2) after local shuffle (or not), the deck will be send to game-master for sync up.
                - game-master get all player to send their gameDeck.
                - game-master decide who should have the turn to shuffle.  The new-deck will then 
                be sent back to all players.
                This is done before 3).  But since all players have the same card-deck, the
                card-dealing will result in match hands. 
            
    II) on Step 5a) : new function needed to sync all-player on the same deck.
            - noted, on the computer that is act as a player, the game behave as if it is a master, playing 1-human (the human is also a socket player) against 3 bots. 
            The game is sync because they all have the same deck-of-card, The bots decision/play -- wil be dropped -- substitude by
            the real-network player (if it is configured to be)
             on 5a) a request wil be send to the player computer which has the real human player. 
             the same-function call is made (but to the network version) when the data comeback without much different
             than the bots player (asynchronously)

                5b) here 3/or2 calls are made to network to get the results back.
            Noted that the computers are synchronized on the flow of the game.  Only the results of the call to "hgamePlay" that is need to be update/overrided by the master. 
            In a round, there are 2 place of synchronization of results.  First, "play1card", it is send to just 1 player to get a card as the result.  We dont need to send command+card.  The Master need the Player to send the pcard back. Then it send it out to other players as command+card.  However, it does not need to send command, just the card (for simplication). The PLAYER will automatically wait to receive Card. 

            in similar way, their results are wait till ready ()
                function whoWin() will need to be 'network' awared.  Making call to master/player 
                to get all result backs. 

    III) funtion gamePlay, will need a new version nwGamePlay, to be handling the sending data to master/player
    on each round, each of the call will need 2 things: actions and playcard. 
    on the return(or result), it will be either be a)none or b) 1,2 or 3 cards. 
    All results will go back to master.  Once all data is collected. Master will send combine results to all-players,
    as well as the result of who win.  These information will replace/supersede the local version on each computer. 
    The game will behave as if it is 1-human against 3 bots.



"""
function gsStateMachine(gameActions)
    global tusacState, all_discards, all_assets,prevWinner
    global gameDeck, ad, deckState,gameEnd,HISTORY
    global nwPlayer,nwMaster,playerName,coldStart, FaceDown
    global playerA_hand,playerB_hand,playerC_hand,playerD_hand
    global playerA_discards,playerB_discards,playerC_discards,playerD_discards
    global playerA_assets,playerB_assets,playerC_assets,playerD_assets
   prevIter = 0
   
    #=
    Code for state machine --????
    ---------------------------------
    =#
    if tusacState == tsSinitial
# -------------------A
        global mode
        if gameActions == gsSetupGame
            global numberOfSocketPlayer
            global mode
            if coldStart
                if !noGUI()
                    GUIname[1]  = TextActor(playerName[1],"asapvar",font_size=fontSize,color=[0,0,0,0])
                    GUIname[1].pos = tableGridXY(10,20)
                    GUIname[2]  = TextActor(playerName[2],"asapvar",font_size=fontSize,color=[0,0,0,0])
                    GUIname[2].pos = tableGridXY(18,1)
                    GUIname[3]  = TextActor(playerName[3],"asapvar",font_size=fontSize,color=[0,0,0,0])
                    GUIname[3].pos = tableGridXY(10,1)
                    GUIname[4]  = TextActor(playerName[4],"asapvar",font_size=fontSize,color=[0,0,0,0])
                    GUIname[4].pos = tableGridXY(1,1)
                end
                networkInit()
                println("AAAAAAAAAA")
                gameDeck = TuSacCards.ordered_deck()
            end
            if noGUI() == false
                FaceDown = true 
                deckState = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
                if coldStart
                    if (GENERIC == 1)
                        global handPic = Actor("hand4.png")
                        global winnerPic = Actor("winner2.png")
                    elseif GENERIC == 2
                        global handPic = Actor("hand3.png")
                        global winnerPic = Actor("winner2.png")
                    elseif GENERIC ==3
                        global handPic = Actor("hand2.png")
                        global winnerPic = Actor("winner2.png")
                    else
                        global handPic = Actor("hand.jpeg")
                        global winnerPic = Actor("winner2.png")
                    end
                    global errorPic = TextActor("?!?","asapvar",font_size=fontSize*4,color=[0,0,0,0])
                end
                updateHandPic(prevWinner)
                updateWinnerPic(0)
                updateErrorPic(0)
            else
                autoHumanShuffle(rand(8:15))
            end
            if mode != m_standalone && noGUI()
                println("noGUI sync")
                anewDeck = deepcopy(playersSyncDeck!(gameDeck))
                pop!(gameDeck,112)
                push!(gameDeck,anewDeck)
            end
          #  println("anew",anewDeck)
            tusacState = tsSdealCards

        end

# -------------------A

    elseif tusacState == tsSdealCards
# -------------------A
global cardsIndxArr = []
global GUI_ready = false
    #    if gameActions == gsOrganize
            println("Prev Game Winner =", gameEnd)
            prevWinner = gameEnd
            tusacDeal(prevWinner)
            gameOver(0)
            organizeHand(playerA_hand)
            organizeHand(playerB_hand)
            organizeHand(playerC_hand)
            organizeHand(playerD_hand)

            getData_all_hands()
            setupDrawDeck(playerA_hand, 7, 18, 100, false)
           

    #    end

        println("\nDealing is completed,prevWinner=",prevWinner)
        getData_all_discard_assets()

        global gameDeckArray = TuSacCards.getDeckArray(gameDeck)
        replayHistory(0)
        updateHandPic(prevWinner)
        global gameEnd = 0
        println("Starting game, e-",gameEnd)
        tusacState = tsGameLoop
        global glNeedaPlayCard = true
        if coldStart
            global glPrevPlayer = 1
        else
            global glPrevPlayer = prevWinner
        end
        global glIterationCnt = 0
    elseif tusacState == tsGameLoop
        if gameActions == gsRestart
            println("RESTART")
            RESET1()
            RESET2()
            println("NOGUI=",noGUI())
          
            RESET3()
            coldStart = false
            FaceDown = true
            ActiveCard = 0
            saveI = 0
            all_assets = []
            all_discards = []
            HISTORY = []
            tusacState = tsSinitial
            println("Restarting Game")
            if noGUI()
                gsStateMachine(gsOrganize)
            end
            restartGame()
        else
            if length(gameDeckArray) >= gameDeckMinimum
                    if  isGameOver() == false
                        if(rem(glIterationCnt,4) ==0)
                        SNAPSHOT()
                        end
                        gamePlay1Iteration()
                    end
            else
                openAllCard = true
                println("Bai thui!")
                gameOver(5)
                
            end
        end
    elseif tusacState == tsRestart
     
    end
end

#=
game start here
=#
function autoHumanShuffle(n)
    println("\nAUTO-HUMAN-SHUFFLE")
    for i in 1:n
        rl = rand(17:23)
        rh = rand(37:43)
        sh = rand(0:1) > 0 ? rl : rh
        TuSacCards.humanShuffle!(gameDeck,14,sh)
    end
end

gsStateMachine(gsSetupGame)
    
function RESET2()
    global BIGcard = 0
    global ActiveCard = 0
    global prevActiveCard = 0
    global cardSelect = false
    global playCard = 0
end
global lsx,lsy

RESET2()
if noGUI()
    gsStateMachine(gsOrganize)
end

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
      #  println("m,x=",(modified_cardXdim,cardXdim))
        for (i, b) in enumerate(boxes)
            if b[1] < x < b[3] && b[2] < y < b[4]
                rx = div((x - b[1]), modified_cardXdim) + 1
                ry = div((y - b[2]), modified_cardYdim)
                cardId = ry * b[10] + rx
                return i, cardId
            end
        end
        return 0, 0
    end
    ####################
        x = pos[1] << macOSconst
        y = pos[2] << macOSconst
   if tusacState == tsSdealCards
        if myPlayer == shufflePlayer
            mouseDirOnBox(x, y, deckState)
        end
    elseif tusacState > tsSstartGame && tusacState <= tsGameLoop
        
        boxId, cardIndx = withinBoxes(x, y, boxes)
        if boxId > 0
            if isGameOver() == false && boxId > 9
                boxId = 0
            end
        end
     
        if boxId == 0
            v = 0
        elseif boxId == 1
            v = TuSacCards.getCards(playerA_hand, cardIndx)
        elseif boxId == 2
            v = TuSacCards.getCards(playerA_discards, cardIndx)
        elseif boxId == 3
            v = TuSacCards.getCards(playerB_discards, cardIndx)
        elseif boxId == 4
            v = TuSacCards.getCards(playerC_discards, cardIndx)
        elseif boxId == 5
            v = TuSacCards.getCards(playerD_discards, cardIndx)
        elseif boxId == 6
            v = TuSacCards.getCards(playerA_assets, cardIndx)
        elseif boxId == 7
            v = TuSacCards.getCards(playerB_assets, cardIndx)
        elseif boxId == 8
            v = TuSacCards.getCards(playerC_assets, cardIndx)
        elseif boxId == 9
            v = TuSacCards.getCards(playerD_assets, cardIndx)
        elseif boxId == 10
            v = TuSacCards.getCards(playerB_hand, cardIndx)
        elseif boxId == 11
            v = TuSacCards.getCards(playerC_hand, cardIndx)
        elseif boxId == 12
            v = TuSacCards.getCards(playerD_hand, cardIndx)
        else
            v = TuSacCards.getCards(gameDeck, cardIndx)
        end
        if v != 0
            m = mapToActors[v]
        else
            m = 0
        end

        global BIGcard = m
    elseif tusacState == tsRestart

    end
end

function mouseDownOnBox(x, y, boxState)
    loc = 0
    up = 0
    if (boxState[1] < x < boxState[3]) && ((boxState[2] < y < boxState[4]))
        dx = div((x - boxState[1]), modified_cardXdim)
        dy = div((y - boxState[2]), cardYdim)
        up = rem((y - boxState[2]), cardYdim)
        up = div(up, div(cardYdim, 2))
        loc = div((boxState[3] - boxState[1]), modified_cardXdim) * dy + dx + 1
    end
    println("l,r",(loc,up))
    return loc, up
end

actionStr(a) =
    a == gpPlay1card ? "gpPlay1card" :
    a == gpCheckMatch1or2 ? "gpCheckMatch1or2" :
    a == gpCheckMatch2 ? "gpCheckMatch2" : "gpPopCards"



function strToVal(hand, str)
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

function keyboardInput(gpPlayer)
    global GUI_array, GUI_ready
    local al = readline()
    if length(al) > 1
        local rl = split(al, ' ')
        local card = strToVal(all_hands[gpPlayer], rl)
    else
        card = []
    end
    return card
end

function humanInput()
    testDeck = TuSacCards.getDeckArray(TuSacCards.ordered_deck())
    local al = readline()
    if length(al) > 1
        local rl = split(al, ' ')
        println(rl)
        local card = strToVal(testDeck, rl)
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
    println("==================Player", (gpPlayer,playerMaptoGUI(gpPlayer)), "Hand: ")
    for c in all_hands[gpPlayer]
        print(ts(c), " ")
    end
    println()
    a = 0
    for as in all_assets
        a += 1
        print("Assets", a, ":  ")
        for i in 2:length(as)
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
        for i in 2:length(as)
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
global rf1,rf2,rf3,rf4
function failCheckPoint(dArray,all_hands,all_assets,all_discards) 
    return false
end

"""
chk1(playCard)
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
        print(" s",(ts(s)))
        @assert !is_c(s)
        if card_equal(s, playCard)
            print("@")
            return s
        end
    end

    for mt in missTs
        m = missPiece(mt[1], mt[2])
        print(" mT=", ts(m))
        if card_equal(m, playCard)
            print("@")
            return mt
        elseif card_equal(mt[1], playCard) && !is_T(playCard)
            print("@")
            return mt[1]
        elseif card_equal(mt[2], playCard) && !is_T(playCard)
            print("@")
            return mt[2]
        end
    end

    for m1 in miss1s
        m = missPiece(m1[1], m1[2])
        print(" m1=", (length(miss1s),ts(playCard),ts(m)))
        if card_equal(m, playCard)
            print("@")
            return m1
        elseif card_equal(m1[1], playCard) && !is_T(playCard)
            print("@")
            return m1[1]
        elseif card_equal(m1[2], playCard) && !is_T(playCard)
            print("@")
            return m1[2]
        end
    end
    return []
end

"""
chk2(playCard) check for pairs -- also check for P XX ? M

"""
function chk2(playCard)
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
                    print("@")
                    return ap # TTTT
                end
            elseif card_equal(ap[1], playCard)
                if (p == 1) && found
                    print(" SAKI ")
                    print("@")

                    return []  # SAKI -- return nothing
                else
                    print("@")

                    return ap
                end
            elseif inSuit(ap[1], playCard)  # CASE X PP ? M
                push!(inSuitArr, ap[1]) # put in array to check
                print("  inSuitArr =", inSuitArr)
            end
        end
    end
    if length(inSuitArr) > 0
        for s in singles
            if inSuit(s, playCard)
                push!(inSuitArr, s)
                print("  inSuitArr =", inSuitArr)
                print("@")

                return inSuitArr
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
    else
        if length(singles) == 0
            if length(missTs) > 0
                mt = missTs[1]
                for m in mt
                    # cheesy way to get dut-dau-tuong to play first
                    push!(singles, m)
                end
            end
            if length(miss1s) > 0
                for m1 in miss1s
                    for m in m1
                        if !is_T(m)
                            push!(singles,m)
                            if inTSuit(m)
                                push!(singles,m)
                            end
                        end
                    end
                end
            end
            if length(chot1s) > 0
                for m in chot1s
                    push!(singles,m)
                end
            end
        end
    end
    if length(singles) > 0
        println("final singles=")
        println(singles)
        card = singles[rand(1:length(singles))]
    else
        card = []
    end
    return card
end 
function gpHandleMatch2Card(pcard)
    card1 = chk1(pcard)
    card2 = chk2(pcard)
    println("chk1-",(card1)," chk2-",(card2))
    if length(card1) == 0
        return card2
    elseif length(card2) == 0 || !card_equal(card2[1],card2[2])
            return card1
    else
        return card2
    end
end

function gpHandleMatch1or2Card(pcard)
    cards = chk1(pcard)
    if length(cards) == 0
        cards = chk2(pcard)
    end
    return cards
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
    if(gpPlayer==myPlayer)
        global currentAction = gpAction
    end
    global currentPlayCard = pcard
    FaceDown = !isGameOver()
    if gpPlayer == 1 
        global human_state = setupDrawDeck(playerA_hand, 7, 18, 100, false)
        discard1 = setupDrawDeck(playerA_discards, 16, 15, 8, false)
        asset1 = setupDrawDeck(playerA_assets, 9, 13, 30, false)

    elseif gpPlayer == 2
        setupDrawDeck(playerB_hand, 20, 2, 2, FaceDown)
        discard2 = setupDrawDeck(playerB_discards, 16, 2, 8, false)
        asset2 = setupDrawDeck(playerB_assets, 16, 7, 4, false)

    elseif gpPlayer == 3
        setupDrawDeck(playerC_hand, 7, 2, 100, FaceDown)
        discard3 = setupDrawDeck(playerC_discards, 3, 2, 8, false)
        asset3 = setupDrawDeck(playerC_assets, 8, 4, 30, false)
    else
        setupDrawDeck(playerD_hand, 1, 2, 2, FaceDown)
        discard4 = setupDrawDeck(playerD_discards, 3, 16, 8, false)
        asset4 = setupDrawDeck(playerD_assets, 4, 7, 4, false)

    end
    
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
   global allPairs, singles, chot1s, miss1s, missTs, miss1sbar,chotPs,chot1Specials =
        scanCards(all_hands[gpPlayer])

    if gpAction == gpPlay1card
        @assert length(union(singles, chot1s, miss1s, missTs)) > 0
        print("play: ")
        global boDoi = 0
        cards = gpHandlePlay1Card()
     
    println("--",(playerIsHuman(gpPlayer),humanIsGUI,GUI_ready,GUI_array))
    rReady[gpPlayer] = false

        #--------------------------------------HERE
    elseif gpAction == gpCheckMatch1or2
        cards = gpHandleMatch1or2Card(pcard)
    else
        cards = gpHandleMatch2Card(pcard)
    end
    if length(cards) == 3
        print("--------->>>>")
    end
    print(cards," --  ")
    ts_s(cards)
    
    if !playerIsHuman(gpPlayer)
        rQ[gpPlayer]=cards
        rReady[gpPlayer] = true
    else
        global currentCards = cards
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

function restartGame()
    global gameDeck,prevWinner,currentPlayer
    println("Reset Game, merge all-hands")
    global FaceDown = false
    global coldStart = false
    currentPlayer = prevWinner  
        newDeck = (union(
            playerA_hand,
            playerB_hand,
            playerC_hand,
            playerD_hand,

            playerA_assets,
            playerB_assets,
            playerC_assets,
            playerD_assets,

            playerA_discards,
            playerB_discards,
            playerC_discards,
            playerD_discards,
            gameDeck))
            gameDeck =TuSacCards.Deck(newDeck)
            pop!(playerA_assets,length(playerA_assets))
            pop!(playerB_assets,length(playerB_assets))
            pop!(playerC_assets,length(playerC_assets))
            pop!(playerD_assets,length(playerD_assets))

            pop!(playerA_discards,length(playerA_discards))
            pop!(playerB_discards,length(playerB_discards))
            pop!(playerC_discards,length(playerC_discards))
            pop!(playerD_discards,length(playerD_discards))


        prevWinner = gameEnd > 4 ? prevWinner : gameEnd
        currentPlayer = prevWinner
        tusacState = tsSinitial
        gsStateMachine(gsSetupGame)
end
function on_key_down(g)
    global tusacState, gameDeck, mode_human,
    playerA_hand,
    playerB_hand,
    playerC_hand,
    playerD_hand,
    playerA_assets,
    playerB_assets,
    playerC_assets,
    playerD_assets,
    playerA_discards,
    playerB_discards,
    playerC_discards,
    playerD_discards
        if g.keyboard.TAB
            println("TAB")
        elseif g.keyboard.SPACE
            println("SPACE")
        elseif g.keyboard.T
            println("key-T")
        end

        if tusacState == tsSdealCards
            if g.keyboard.S
                println("Auto Shuffle")
                autoHumanShuffle(10)
                setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
            elseif g.keyboard.H
                println("Human mode")
                mode_human = true
            elseif g.keyboard.R
                println("Robot mode")
                mode_human = false
            end
        elseif tusacState == tsHistory
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
        if g.keyboard.R 
            checkForRestart()
        elseif g.keyboard.TAB
            SNAPSHOT() #taking last SNAPSHOT 
            HistCnt = length(HISTORY)
            tusacState = tsHistory
            println("Entering History mode, size=",HistCnt)
        elseif g.keyboard.H
            print("switching human mode ",mode_human, "-->")
            mode_human = !mode_human
            println(mode_human)
        end
    end
end

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

function badPlay(cards,player, hand,action,botCards,matchC)
    print("Chk GUI ,matchcard ",(ts(matchC)," -- ", cards, " == ", "action=",action))
    ts_s(hand)
    ts_s(cards)
    
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
            println((c)," is not found in Player hand ",hand)
        end
        allfound = allfound && found
    end
    if !allfound
        return true
    end
 
    if action == gpPlay1card
        return (length(cards) != 1) || is_T(cards[1])
    else
        all_in_pairs = true
        all_in_suit = true
        pcard = matchC[1]
        if length(cards) > 0 
            if card_equal(pcard,cards[1])
                if length(cards) == 1 
                    return(is_T(pcard))
                end
                for c in cards
                    all_in_pairs = all_in_pairs && card_equal(pcard,c)
                end
                all_in_pairs = all_in_pairs && !(length(cards)==2 && is_T(pcard))
                if !all_in_pairs
                    println(cards," not pairs")
                    return true
                end
                if (length(cards) == 2) # check for SAKI
                    ps, ss, cs, m1s, mts, mbs = scanCards(hand, true)
                    for m in mbs
                        if card_equal(m,cards[1]) && !is_t(m) && !is_s(m)
                            println("match ",ts_s(cards)," is SAKI, not accepted")
                            return true
                        end
                    end
                end 
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
        end
        moreTrash = false
        ts_s(hand)
function foundSaki(card,miss1sbar)
    for m in miss1sbar
        if card_equal(card,m)
            return true
        end
    end
    return false
end
        if is_c(pcard) || length(cards) == 0
            allPairs, singles, chot1s, miss1s, missTs, miss1sbar,chotPs,chot1Specials =
            scanCards(hand, false)
            # check for bo doi
            if length(cards) == 0
                for ps in allPairs
                    for p in ps
                        if card_equal(p[1],pcard) && !foundSaki(pcard,miss1sbar)
                            println("BO DOI")
                            global boDoi += 1
                            if boDoi > 2
                                if !is_c(pcard)
                                    for ap in p
                                        removeCards!(all_hands,player,ap)
                                        addCards!(all_assets,0,player,ap)
                                        mmm = mapToActors[ap]
                                        global mask[mmm] = mask[mmm] & 0xFE
                                    end
                                end
                                boDoi = 0
                                return false
                            else
                                return true
                            end
                        end
                    end
                end
                println("bot-cards=",botCards)

                if hints > 0 && length(botCards) > 0
                    if (action == gpCheckMatch2 && length(botCards) > 1 && card_equal(botCards[1],botCards[2]))||
                       (action == gpCheckMatch1or2)
                        global boDoi += 1
                        if boDoi > 1
                            boDoi = 0
                            return false
                        else
                            return true
                        end
                    end
                end
            else
                println("trashCnt")
                TrashCnt = length(chot1s)
                thand = deepcopy(hand)
                for e in cards
                    filter!(x -> x != e, thand)
                end
                ps, ss, cs, m1s, mts, mbs,cp,cspec = scanCards(thand, true)
                l = length(cs)
                if TrashCnt < l
                    println("Illegal match -- creating more trash ",(TrashCnt,l))
                    ts_s(chot1s)
                    ts_s(cs)
                    moreTrash = true
                end
            end
        end  
        println("p,s,t",(all_in_pairs ,all_in_suit,moreTrash))
        return !( all_in_pairs || all_in_suit) || moreTrash
    end
end
function checkForRestart()
    if isGameOver() 
        if numberOfSocketPlayer > 0
            if isServer() 
                for p in 2:numberOfSocketPlayer+1
                    nwAPI.nw_sendTextToPlayer(p,nwPlayer[p],"restart")
                end
                gsStateMachine(gsRestart)
            else
                msg = nwAPI.nw_receiveTextFromMaster(nwMaster)
                if msg == "restart"
                    gsStateMachine(gsRestart)
                end
            end
        else
            gsStateMachine(gsRestart)

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
    global tusacState
    x = pos[1] << macOSconst
    y = pos[2] << macOSconst
    if tusacState == tsSdealCards
        println("D")
        if mode != m_standalone && !noGUI()
            println("GUI SYNC")
            anewDeck = deepcopy(playersSyncDeck!(gameDeck))
            pop!(gameDeck,112)
            push!(gameDeck,anewDeck)
        end
        println("ORGANIZE")
       gsStateMachine(gsOrganize)
       
    elseif tusacState == tsGameLoop    
        cindx, yPortion = mouseDownOnBox(x, y, human_state)
        if cindx != 0
            click_card(cindx, yPortion, playerA_hand)
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
                ac= TuSacCards.getCards(playerA_hand, ci)
                push!(GUI_array,ac)
                print("click_card, index,card=",(ci,ac))
                println(" ",ts(ac))
            end
            println("\nDanh Bai XONG ROI")
            setupDrawDeck(playerA_hand, 7, 18, 100, false)
              
            if badPlay(GUI_array,myPlayer,all_hands[myPlayer],
                currentAction,currentCards,currentPlayCard)
                updateErrorPic(1)
                cardsIndxArr = []
                GUI_ready = false
            else 
                updateErrorPic(0)
                cardsIndxArr = []
                GUI_ready = true
            end
        end
    elseif tusacState == tsRestart
        anewDeck = []
        global boxes = []


    end
end
if noGUI()
    while(true)
        gsStateMachine(gsGameLoop)
        checkForRestart()
    end
end
function update(g)
    global waitForHuman, shufflePlayer
    global ad, deckState, gameDeck, tusacState
    global tusacState
    FaceDown = !isGameOver()
    shufflePlayer = prevWinner > 3 ? 1 : prevWinner +1

    if tusacState == tsSdealCards
        if (deckState[5] > 10)
            TuSacCards.humanShuffle!(gameDeck, 14, deckState[5])
            deckState = setupDrawDeck(gameDeck, 8, 8, 14, FaceDown)
        end
        if noGUI()
        gsStateMachine(gsOrganize)
        end
    elseif tusacState == tsSstartGame
        gsStateMachine(gsStartGame)
    elseif (tusacState == tsSdealCards)
    
    elseif tusacState == tsGameLoop
        updateHandPic(currentPlayer)
        gsStateMachine(gsGameLoop)
      
    elseif tusacState == tsRestart

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
    if noGUI()
        return
    end
   fill(colorant"ivory4")

    saveI = 0
    drawCnt += 1
    if drawCnt > 40
        drawCnt = 0
    end
    if !((tusacState == tsGameLoop)||(tusacState == tsHistory))
        for i = 1:112
            global saveI
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
        if saveI != 0
            draw(big_actors[saveI])
        end
        
        if ActiveCard != 0
            global csx,csy = big_actors[ActiveCard].pos
            if drawCnt >20
                draw(big_actors[ActiveCard])
            end
        end
        draw(handPic)
        draw(winnerPic)
        draw(errorPic)

        for i in 1:4
            draw(GUIname[i])
        end
    end
    
end

