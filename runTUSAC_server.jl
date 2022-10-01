using GameZero
wf = open("tempSGUI.jl","w")
rf = open("tsGUI.jl","r")
while !eof(rf)
    aline = readline(rf)
    println(wf,aline)
end
close(rf)
close(wf)
rungame("tempSGUI.jl")

