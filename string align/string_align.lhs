> similarityScore :: String -> String -> Int
> similarityScore string1 string2 = 1

> -- Takes a list of tuples, where the elements of the tuples are lists
> -- aswell, and inserts h1 at the start of list 1 of the tuple and vice
> -- versa for h2. 
> -- E.g. attachHeads 'H' 'k' [("as","ell")] = [("Has","kell")]
> attachHeads :: a -> a -> [([a],[a])] -> [([a],[a])] 
> attachHeads h1 h2 aList = [(h1:xs,h2:ys) | (xs,ys) <- aList]

> maximaBy :: Ord b => (a -> b) -> [a] -> [a] 
> maximaBy valueFcn xs = [x | x <- xs,(valueFcn x) == max_val]
>           where max_val = maximum $ map valueFcn xs

> type AlignmentType = (String,String)
> optAlignments :: String -> String -> [AlignmentType]
> optAlignments string1 string2 = 
>               maximaBy scoreAlignments $ genAllComb string1 string2

> genAllComb :: String -> String -> [(String,String)]
> genAllComb [] [] = [([],[])]
> genAllComb (x:xs) [] = attachHeads x '_' $ genAllComb xs []
> genAllComb [] (y:ys) = attachHeads '_' y $ genAllComb [] ys
> genAllComb (x:xs) (y:ys) = concat [c1,c2,c3]
>               where
>                   c1 = attachHeads x   y $ genAllComb xs ys
>                   c2 = attachHeads '_' y $ genAllComb (x:xs) ys
>                   c3 = attachHeads x '_' $ genAllComb xs (y:ys)

> scoreMatch = 0
> scoreMismatch = -1
> scoreSpace = -1

> scoreAlignments :: (String,String) -> Int
> scoreAlignments ([],_) = 0
> scoreAlignments (_,[]) = 0
> scoreAlignments ((x:xs),(y:ys))
>      | x == y = (0+) $ scoreAlignments (xs,ys)
>      | x == '-' || y == '-' = (-1+) $ scoreAlignments (xs,ys)
>      | x /= y = (-1+) $ scoreAlignments (xs,ys)


> outputOptAlignments :: String -> String -> [String]
> outputOptAlignments string1 string2 = [string1]   