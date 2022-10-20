using Sockets
using Dates
function serverSetup(serverIP,port)
    nw = 0
    try
        nw = listen(serverIP,port)
        return nw
    catch
        @warn "Port is busy"
    end
end
    

function acceptClient(s)
    return(accept(s))
end

serverURL = "baobinh.tplinkdns.com"
port = 11031
myIP = ip"192.168.0.65"
nws = serverSetup(myIP,port)
RCF = open("updateRec.txt","w")
if nws != 0
  while true
        nw = acceptClient(nws)

        rf = open("tsGUI.jl","r")
        myversion = readline(rf)

        p = split(myversion,"=")
        if p[1] == "version "
            println(nw,myversion)
            rmversion = readline(nw)
            println(Dates.format(now(), "HH:MM"), (rmversion,myversion))
            if rmversion < myversion
                global aline = myversion
                while !eof(rf)
                    println(nw,aline)
                    aline = readline(rf)
                end
                println(nw,aline)
                println(nw,"#=Binh-end=#")
                println(RCF,now())
                println(RCF,rmversion)
                close(rf)
                close(nw)
                println("Done with sending update")
            end
        end
    end
end
    

