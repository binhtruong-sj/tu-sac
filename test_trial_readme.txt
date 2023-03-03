trial: use the runTUSAC_trial.cfg
it only contains the test-filename, not specifying the particular test.  
In the file, the first comment contains the trial-test.  (on tesg only, the first comment is ignored)

(61, false, 1, 0x6b, 0, "")
TT tT tT tT mT TV TV sV xV pV TD TD tD pD mD TX sX tX xX cT 
TT xT pT TV tV xV pV TD sD xD sX tX cT cT cV cV cV cD cX 
sT sT mT tV mV tD xD pD mD TX sX xX xX pX mX mX cV cD cX cX 
TT TT xT pT TV sV tV xV pV pV mV TD sD xD pD mD TX sX pX cT 

pX pX 






mT tT sT xV mV tD xX mV xT mX mD tV pD tD cX TX xT tX sV cD mX pT sV sD tX mT cD pT sT sD xD 

first line: 61 is testname, false == no check, 1 is active player, rest of the fields 
are ignored

next 4 lines is what each player has in hand
next 4 is Assets
next 4 is Discards piles
last line is the what remain in the game-deck


==============================================================================

test:  almost the same as trial, the exception is all comments line are the test list (except the first line)
Format of the setup is the same as "trial".  Addition text lines:
("M", xX, 2, 6, 0)
("M", xX, 2, 6, 0)
("M", xX, 0, 6, 0)

those lines allows self-test, showing the 'correct' cards moving from one pile to the other
at the end of play.  For example, xX is moving from 2 -> 6 (2 is player 3, 6 is asset for player 3)

all tests will be run and generate ASSERT failure if the "movements" not happen correctly

==============================================================================

histfile: game can be saved in history files (1 file per game, sequentially increase names)
format of the histfile is exactly the same as that of "test" or "trial". This would allow
using histfile data as testcase.

==============================================================================

implement runTUSAC.jl to allow automatic update from server.  It would check if 
server is responding, and check for version.  If newer version exist, client would download
new file from server (high-risk).  Client is not allowing to update server. 