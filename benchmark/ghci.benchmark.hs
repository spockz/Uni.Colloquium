fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = let !l = fib (n-1)
            !r = fib (n-2)
            !res = l + r
         in res

main = do f 100
 where x   = 20
       f 1 = print $ fib x
       f n = do print $ fib x
                f (n-1)