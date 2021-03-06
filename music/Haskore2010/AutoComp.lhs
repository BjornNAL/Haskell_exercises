\documentclass[a4paper]{article}

\begin{document}

\section{Introduction}

This document represents the handin for assignment 2 in the course functional
programming at LTH, by Bj�rn Lennern�s and Linus Svensson.
It contains a mix of theory, describing the workings of certain
aspects of western music, and code which describes a way to utilize the
theory to automatically generate accompaniments for musical scores. Lets
start by setting op the environment.

\begin{verbatim}

> module AutoComp where
> import Haskore hiding(Major,Minor,Key) -- We want to redefine these types

\end{verbatim}

\section{The basics}
First things first, what is a musical score? A musical score is basically
music in printed form, the characteristic sheet of music is a musical score.
The rules that govern how such scores are interpreted are quite complex
and only a subset of them will be described and utilized here. For the
purpose of this document however a musical score consists of notes
and chords. The chord symbols are written above the lines wherein the notes
lie and consist of, at least in this document, one of the letters C,D,E,F,G,A.

\subsection{Notes}

Which naturally leads to the next topic, what does C,D,E... represent? To
answer that it helps to first answer a more basic question and that is: What
is the relationship between a note and an actual physical sound? It must
somehow relate to the frequency of the sound, since different frequencies are
basically different sounds (although other factors, such as volume,
instrument etc. also play a role).

The way notes works is that they belong to different frequency sections 
called octaves, where octave 1 is the lowest found on pianos. So for a
note to make sense it needs to be accompanied with its octave, e.g.
Note $\in$ (C, 4) which denotes a C in the fourth octave. The letters C - A
then represent different positions within an octave, called semitones,
and each octave is divided into twelve semitones. In this document the
distance between semitones is assumed to be equal.

Another import quality of octaves is that the frequency range they
represent double between each octave, where the first octave has an 
approximate frequency range of 30 to 60 hz. The highest octave 
represented on a piano is typically the seventh.  

To reiterate then, C,D,E,.. represent one position on an equidistant
frequency scale, with twelve positions called semitones. To use that
information to construct a sound we also need an octave, which is
basically a multiple of octaves. So, given a position and an octave we
have physical sound frequency, and to construct a sound from that all
we need is a duration, an instrument and a volume. Here the convention
is to call the combination of position in an octave and an octave a 
\emph{pitch}, the position is called a PitchClass in Haskore. The duration
is defined as ratio of whole note (<= 1), and the default value in 
Haskore is 30 whole notes per minute. Thus:

\begin{verbatim}

	>type Pitch = (PitchClass, Octave)
	>type PitchClass = C | D | E..
	>type Note = Pitch -> Dur -> [NoteAttribute] -> Music
	>:t Volume 
	Volume :: Float -> NoteAttribute
	>type Dur = Ration Int
	>:t wn 
	>wn :: Dur
	>:t (Note (G,4) wn [Volume 60])
	> (Note (G,4) wn [Volume 60]) :: Music

\end{verbatim}

\section{Keys and chords}

\subsection{Note supplies, patterns, harmonic qualities}

So how do we interpret a note sheet? An important concept is that of note 
supplies. As a rule only a subset of the pitchclasses are used in a song,
this subset is called the note supply for the piece and it is from these
pitchclasses that the Pitches in a melody are formed. To construct the 
note supple for a piece its key is needed, which is an object with two
properties - a root, which is a pitchclass, and a harmonic quality, which 
is either major or minor. Thus (C,Major) is a Key.

In this document this key is used in two ways to construct the note supply.
First its harmonic quality is used to choose a pattern, basically positions
in an octave, and its root is used to align the pattern so that the note
supply starts at this section of the octave. There are several different
patterns to choose from for both major and minor, in this assignment
only the most common for major and minor are used and they are called
ionian and aeolian respectively (see below). Furthermore the note supply
also needs an octave to represent a set of unique pitches, in this assignment
the melody is played with this octave set to four. This leads us to construct
the following types and definitions.

\begin{verbatim}

> data HarmonicQuality = Major | Minor
>	deriving (Eq)
> type Key = (PitchClass,HarmonicQuality)
> type ScalePattern = [Int]
> ionian, lydian, mixolydian, aeolian, dorian, phrygian :: ScalePattern
> ionian	= [0, 2, 4, 5, 7 ,9, 11]
> lydian	= [0, 2, 4, 6, 7, 9 ,11]
> mixolydian	= [0, 2, 4, 5, 7, 9, 10]
> aeolian	= [0, 2, 3, 5, 7, 8, 10]
> dorian	= [0, 2, 3, 5 ,7, 9, 10]
> phrygian	= [0, 1, 3, 5, 7, 8, 10]

> noteSupply :: Pitch -> HarmonicQuality -> [AbsPitch]
> noteSupply pitch quality 
>	| quality == Major = map ((+) (absPitch pitch)) ionian
>	| quality == Minor = map ((+) (absPitch pitch)) aeolian

\end{verbatim}

So given a note supply pitches for the notes on the note sheet are constructed
from this supply by looking at their position in the sheet. The note that
starts two steps below the bottom line in the sheet is the first in the note 
supply and every subsequent step is are chosen from the pattern �ncrementally.

\subsection{Chordprogressions, chord scales}
Having found a way to construct a melody from the note sheet we now turn to
the chords. The cord symbols are, as mentioned above, the series of letters
written above the lines in the note sheet. This series of letters is called
the chord progression. We are interested in constructing two things from the 
chord progression, basslines and chord voicing. The chord voicing consists
of chords, and cords are three notes played at the same time, in this 
assignment only three are used in a chord. This series of chords is 
constructed from the chord progression. The bassline consists of a series
notes constructed from a bass style, defined below, and the chord progression.
However we need to cover some more properties of chords before we can go on.
we only play three. To do that we first need to cover some properties of chords.

The chord symbols represent chord classes which is a concept similar
to that of keys. A chord class has a root, which is the symbol itself,
a harmonic, and a pattern. These properties then map to notes that in
a musical sense belong to each other . The pattern is used to find
the chord scale, which is a set of notes from which chords and basslines
are constructed. The pattern is found by: 
1 - Find the root of the chord class as the chord symbol itself
2 - Find the position of the pitchclass represented by the root of
the chord class in the note supply of the melody.
3 - Use the position and the harmonic of the chord class and find the
corresponding pattern from a list (see below for the list itself).
The chord scale is then simply constructed by applying the pattern
to the root of the chord class. Given these rules we construct
the following:

\begin{verbatim}

> type ChordProgression = [(PitchClass,Dur)]

> chooseScalePattern :: HarmonicQuality -> Int -> ScalePattern
> chooseScalePattern quality 
>	| quality == Major = chooseScalePatternMajor
>	| quality == Minor = chooseScalePatternMinor
>	where
>		chooseScalePatternMajor pos
>			| pos == 0 = ionian
>			| pos == 1 = mixolydian
>			| pos == 3 = lydian
>			| pos == 4 = mixolydian
>			| pos == 5 = aeolian
> 		chooseScalePatternMinor pos
>			| pos == 1 = dorian
>			| pos == 2 = phrygian

> -- We're intrested in the position of a pitchclass
> -- in a list of Pitches. It's easier to convert each 
> -- pitch to an abspitch (octave*12 + pos pitchclass)
> -- and then only work the the positions of the elements
> -- in the zeroth octave (thus, use modulo 12)
> notePosition :: [AbsPitch] -> AbsPitch -> Int
> notePosition scale ab = pos (map (`mod` 12) scale) ab 0

> -- Short help function, find index of element in a list
> pos :: Eq a => [a] -> a -> Int -> Int
> pos [] _ i = i
> pos (x:xs) xr i
>	| x == xr = i
>	| x /= xr = pos xs xr (i+1)

\end{verbatim}

\section{Bassline}
The bassline is constructed by looking at the chord classes in the chord 
progression and their chord scales. These scales are then sampled using a bass 
style, in this assignement we use three different bass styles - basic, boogie 
and calypso. 

However we also need durations for the notes that we construct and they are 
found by looking at another piece of information on the note sheet. The 
horisontal lines are chopped of by vertical lines at regular intervals. Each 
such interval is called a bar and consist a whole note. Therefore the bass styles 
are given as a series of sample positions and corresponding durations, where the
durations add up to a whole note. For example the basic bass style consists of 
half note sample of position one in the chord scale, and a half note sample of 
position five. This leads us to define the following code:

\begin{verbatim}

> silence = -1 -- Used for bass styles with silent elements.
> -- Handled in a special way when the notes are constructed.

> type BassStyle = [(Int,Dur)]
> basic, calypso, boogie :: BassStyle
> basic = [(0,hn),(4,hn)]
> calypso = [(silence,qn),(0,en),(2,en),(silence,qn),(0,en),(2,en)]
> boogie = [(0,en),(4,en),(5,en),(4,en),
>	(0,en),(4,en),(5,en),(4,en)]

\end{verbatim}

A problem with this approach though is if two chord symbols appear in the same
bar. This is simply solved by playing the first half of the bassline for the
first symbol, and the first half for the other aswell.

The major function for generating the bass line generates it only for
ont chord at the time. It produces some kind of intermidiate music
represented as a list of absolut pitched and their durations.

\begin{verbatim}

> -- Generates music for one pitch in chordprogression.
> -- the bass style is supposed to be infinit, or at least as long 
> -- as the duration of the pitch.
> genBass :: BassStyle -> HarmonicQuality -> [AbsPitch] -> (PitchClass,Dur)
>	-> [(AbsPitch,Dur)]
> genBass ((i,bdur):bs) quality noteSupp (ch,cdur)
>	| bdur == 0 = genBass bs quality noteSupp (ch,cdur)
>	| cdur == 0 = []
>	| otherwise = play i dur :
>		genBass ((i,bdur-dur):bs) quality noteSupp (ch,cdur-dur)
>	where
>		dur = min bdur cdur
>		play i dur
>			| i == -1 = (silence,dur)
>			| otherwise = ((absPitch (ch,bassOct)) + 
>				((chooseScalePattern quality pos) !! i),dur)
>				where pos = notePosition noteSupp (absPitch (ch,0))

\end{verbatim}

We have a function to combine everything together. Since the genBass function
only works with one chord at the time we need to apply it separately
for each chord in the chord progression and then combine the results togheter.

\begin{verbatim} 

> -- Given a bass style, Key and the chordpragression gives music
> autoBass :: BassStyle -> Key -> ChordProgression -> Music
> autoBass style key prog =
>	toMusic
>		(concat (map (genBass (cycle style) quality 
>			(noteSupply pitch quality)) prog))
>		bassVol
>		(:+:)
>	where
>		pitch = (fst key,bassOct)
>		quality = snd key

\end{verbatim}

To make generation easier we have two attributes for the volume and octave
for the bass line.

\begin{verbatim}

> bassVol = [Volume 60]
> bassOct = 3 -- the base octave in the bass line

> -- convert our internal representation to a Haskore Music type.
> -- the function f is used to define how the input is combined
> -- (i.e parallell or sequentialy).
> toMusic :: [(AbsPitch,Dur)] -> [NoteAttribute] -> (Music -> Music -> Music) -> Music
> toMusic pitches vol f =
>	foldr1 f (map toNote pitches)
>	where toNote (p,dur)
>		| p == silence	= Rest dur
>		| otherwise	= Note (pitch p) dur vol

\end{verbatim}

\section{Chord voicing}
To generate a chord from a chord symbol in the chord progression we start
with finding the chord scale for the corresponding chord class. Since we
want to play three notes at the same time we need to sample this scale,
the way we do it here is by using the basic triad which consist of the 
first, third and fifth note of the chord scale. However, we cannot 
simply choose these note as they are and be done with it, because it sounds
bad (we assume). What we instead do is that we say that it is okay
to shuffle the order of these notes and that it is okay to choose the notes
from different octaves, as long as they lie within a certain range.

Given for example the chord scale (notes given as absolute pitches without
duration)  [55,56,59,63,65,67] we sample with the basic triad and obtain
[55,59,65]. We then notice that it is easiest to go on by finding 
the corresponding pitchclasses for this sample, i.e [F\#,A\#,E].
We then find all combinations of these classes in a certain note range,
here set to (E,4), (G,5), one such combination is [(E,4),(F\#,5),(A,4)],
but [(E,4),(F\#,5),(A,5)] is note valid since (A,5) > (G,5). (This
is how we interpreted the rules, however we're not sure that it is
okay the shuffle the order in any way. We did it though.)

So, given these candidates, which one do we choose? We need to score them in
some way and two criteria we use are: 1 - Look at the internal distance, i.e.
distance in absPitch between the lowest and highest note for a candidate, 
the lower the better. 2 - Look at the previous chord played and check the
absolute distance between the first element in the previous chord and the
first element in the candidate, and vice versa for the rest, and then sum
them up. The lower such sum of distances the better (since it sounds
better, we're told).

Having done this we weigh these two values together, e.g. using their sum
or weighted sum, and pick the candidate with the minimum score. To put
this into code: 

\begin{verbatim}

> -- Send in the key and the Chord progression, obtain music!
> -- Since we dont a "previous chord" for the first symbol
> -- we send in an initial chord which represent a typical chord.
> autoChord :: Key -> ChordProgression -> Music
> autoChord key chords = genChord key chords initial
> 	where  initial = [(55,wn),(59,wn),(67,wn)] :: [(AbsPitch, Dur)]

> -- Make music of the minimal candidate for each chord symbol
> -- in the progression.
> genChord :: Key -> ChordProgression -> [(AbsPitch,Dur)] -> Music
> genChord key [] _ = Rest 0
> genChord key (ch:chs) prev = (toMusic minimal chordVol (:=:)):+:(genChord key chs minimal)
> 	where minimal = minimize key ch prev

> chordVol = [Volume 10] -- Used to set the volume of the chords, see genChord.

> -- Chooses the minimal candidate by calling a function which
> -- generates the candidates and a function that scores them.
> minimize :: Key -> (PitchClass,Dur) -> [(AbsPitch,Dur)] -> [(AbsPitch,Dur)]
> minimize key cur prev = candidates !! (pos (score candidates prev) (minimum (score candidates prev)) 0)
>	where 	candidates = genCandidates key cur 

> -- Construct the sum by looking at the internal distance and 
> -- the distance to the previous chord. Here weighted together
> -- as 3*internal + 2*external
> score :: [[(AbsPitch,Dur)]] -> [(AbsPitch,dur)] -> [Int]
> score candidates prev = zipWith (+) (map (3*) (in_d cur)) (map (2*) (ex_d cur (map (fst) prev)))
>	where 	in_d pts  = [(maximum pt) - (minimum pt) |pt <- pts ]
>		cur = map (map (fst)) candidates
>		ex_d pts pre = [sum (map abs (zipWith (-) pt pre) ) | pt<-pts ]

> -- This function relies on a function genValids which finds all
> -- the combinations (in the different octaves) given a certain
> -- pattern of pitchclasses. The patterns are generated from the
> -- chord scale of the chord. The result from genValid is also
> -- wrapped in a function combines the candidates with the chord
> -- symbols' duration.
> genCandidates :: Key -> (PitchClass,Dur) -> [[(AbsPitch,Dur)]]
> genCandidates key (pclass,dur) =  genValidsWithDur [genValids (map (`mod`12) (map (pattern !!) inv))| inv <- inversions] dur
>	where
>		pattern = map ((+) (absPitch (pclass,0) )) (chooseScalePattern (snd key) (notePosition noteSupp (absPitch (pclass,0) )))
>			where
>				noteSupp = noteSupply ((fst key),0) (snd key)

> inversions = [[0,2,4],[0,4,2],[2,0,4],[2,4,0],[4,0,2],[4,2,0]]

> -- Take a list of candidates and insert a duration next to
> -- every abspitch
> genValidsWithDur :: [[[AbsPitch]]] -> Dur -> [[(AbsPitch,Dur)]]
> genValidsWithDur pts d = [zip pt durs | pt <-(concat pts)]
> 	where durs = [d,d,d]

> -- Generate all valid combinations in the different octaves
> -- for the given pattern using list comprehension.
> genValids :: [AbsPitch] -> [[AbsPitch]]
> genValids triad = [val | val <-permut, all (<= u_bound) val, all (>= l_bound) val ]
>	where 	u_bound = absPitch (G,5)
>		l_bound = absPitch (E,4)
>		permut  = [[i,j,k] | i<-(map (+(triad !! 0)) o45),j<-(map (+(triad !! 1)) o45),k<-(map (+(triad !! 2))o45)]
>			where o45 = [48,60]

\end{verbatim}

\section{End}
And we are done. Given below is a function to combine chord
voicing and bassline generation. It sounds fairly good. 

Here we also add a disclaimer. We really don't know the first
thing about music theory and several things are probably wrong
in this presentation. We were just working on a given description.

\begin{verbatim}

> autoComp :: BassStyle -> Key -> ChordProgression -> Music
> autoComp style key chords =
>	(Instr "Acoustic Bass" bass) :=: (Instr "flute" chord_v)
>	where 	bass = autoBass style key chords
>		chord_v = autoChord key chords

\end{verbatim}

\end{document}
