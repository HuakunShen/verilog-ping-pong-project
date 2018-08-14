PONG Game
Author: 
    Xu Wang
    Huakun Shen

KEYS:
    SW[0] = resetn         # active low
    KEY[1] = go signal     # when game ends (or see GO! on screen) press KEY[1] to start playing the game       (also act as direction control key during the game) 
    Difficulties:
        SW[9] = speed (faster)
        SW[8] = hide ball (disappears 1 second every 5 seconds)
        SW[7] = double ball
        SW[6] = shorter paddle
        SW[5] = single player mode (play against computer)   # bottom player is human, top player is computer

    contorls:
        KEY[3] = move left (bottom player / player2)
        KEY[2] = move right (bottom player / player2)
        KEY[1] = move left (top player / player1)
        KEY[0] = move right (top player / player1)


Procedure to play:
    1. copy all .v files into Quartus project folder
    2. copy all VGA supplementary files into Quartus project folder
    3. import DE1_SOC board pin assignment
    4. compile the program
    5. start the game in Programmer (SW[0] set to 0)
    6. turn on monitor and turn SW[0] on
    7. press KEY[1] to start playing
    8. game stops after one of the two players scores 7 points (scores displayed on HEX0 and HEX3 displays)
    9. when game ends, press KEY[1] to restart
    10. difficulty keys can be set before start games (do not change difficulty keys during game)


Note:
    1. make sure all Switches are switched off (at 0 position) to reset everything when starting the game
    2. SW[9:5] are switches for setting difficulties (functions are listed below)
    3. difficulty swtiches must be set before starting the game in case of malfunctions of the game (do not turn on or off switches during game)
    4. five switches can be turned on or off (not during the game) in any combinations




