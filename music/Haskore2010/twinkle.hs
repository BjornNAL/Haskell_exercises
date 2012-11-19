module Twinkle where
import Haskore
 
 -- note updaters for mappings
fd d n = n d v
vol  n = n   v
v      = [Volume 80]
lmap f l = line (map f l)
 
 -- repeat something n times
times  1    m = m
times n m = m :+: (times (n - 1) m)

-- Line 1 in twinkle
oct = 5
p11 = lmap (fd qn) [c oct, c oct, g oct, g oct, a oct, a oct ]
p12 = lmap (fd hn) [g oct]
p13 = lmap (fd qn) [f oct, f oct, e oct, e oct, d oct, d oct]
p14 = lmap (fd hn) [c oct]
l1 = p11 :+: p12 :+: p13 :+: p14

-- Line 2 in twinkle
p21 = lmap (fd qn) [g oct, g oct, f oct, f oct, e oct, e oct ]
p22 = lmap (fd hn) [d oct]
p23 = lmap (fd qn) [g oct, g oct, f oct, f oct, e oct, e oct]
p24 = lmap (fd hn) [d oct]
l2 = p21 :+: p22 :+: p23 :+: p24

-- Line 3 in twinkle
p31 = lmap (fd qn) [c oct, c oct, g oct, g oct, a oct, a oct ]
p32 = lmap (fd hn) [g oct]
p33 = lmap (fd qn) [f oct, f oct, e oct, e oct, d oct, d oct]
p34 = lmap (fd hn) [c oct]
l3 = p31 :+: p32 :+: p33 :+: p34

twinkle = ( Instr "sax" (Tempo 7 (l1:+:l2:+:l3)) ) :+: (Instr "piano" (Tempo 7 (l1:+:l2:+:l3)) )
