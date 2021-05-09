100 print chr$(142);chr$(147)
200 poke 53280,int(rnd(1)*16)
300 goto 500
400 poke 53281,int(rnd(1)*16)
500 for i=1 to 16
600 poke 646,int(rnd(1)*16)
700 c=int(rnd(1)*255)
1200 if (c>94 and c<128) or c>159 then print chr$(c);
1300 next i
1400 if int(rnd(1)+0.5) then 200
1500 goto 400
