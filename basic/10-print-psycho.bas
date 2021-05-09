10 poke 53280,int(rnd(1)*16)
20 goto 40
30 poke 53281,int(rnd(1)*16)
40 for i=1 to 16
50 poke 646,int(rnd(1)*16):print chr$(205.5+rnd(1));
60 next i
70 if int(rnd(1)+0.5) then 10
80 goto 30
