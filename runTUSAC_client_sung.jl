using GameZero
wf = open("tempGUI.jl","w")
rf = open("tsGUI.jl","r")
while !eof(rf)
    aline = readline(rf)
    println(wf,aline)
end
close(rf)
close(wf)
rungame("tempGUI.jl")

