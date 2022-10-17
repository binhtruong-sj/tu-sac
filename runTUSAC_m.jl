using GameZero
using Sockets

function clientSetup(serverURL,port)
    println((serverURL,port))
    try
        ac = connect(serverURL,port)
        return ac
    catch
        @warn "Server is not available"
        return 0
    end
end


serverURL = "baobinh.tplinkdns.com"
port = 11031
myIP = ip"192.168.0.65"

nw = clientSetup(serverURL,port)
if nw != 0
    rf = open("tsGUI.jl","r")
    myversion = readline(rf)

    p = split(myversion,"=")
    if p[1] == "version "
        println(nw,myversion)
        rmverstion = readline(nw)
        if rmversion > myversion
            wf = open("tsGUI1.jl","w")
            while true

                aline = readline(nw)
                if aline == "#=Binh-end=#"
                    break
                end
                println(wf,aline)
            end
            close(wf)
            close(nw)
            println(" done")
        end
    end
end
rungame("tsGUI.jl")
    

