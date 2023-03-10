{-# LANGUAGE AllowAmbiguousTypes        #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedLists            #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TypeFamilies               #-}


module PlutusTx.Extra.Prelude where

import           Data.List                         (unzip)
import           PlutusTx.Builtins                 (subtractInteger)
import           PlutusTx.Prelude                  hiding ((<>))

------------------------------- Functions -----------------------------------

{-# INLINABLE curry4 #-}
curry4 :: ((a, b, c, d) -> e) -> (a -> b -> c -> d -> e)
curry4 f a b c d = f (a, b, c, d)

{-# INLINABLE uncurry4 #-}
uncurry4 :: (a -> b -> c -> d -> e) -> ((a, b, c, d) -> e)
uncurry4 f ~(a, b, c, d) = f a b c d

--------------------------------- Lists -------------------------------------

{-# INLINABLE init #-}
init :: [t] -> [t]
init []     = []
init [_]    = []
init (x:xs) = x : init xs

{-# INLINABLE last #-}
last :: [t] -> t
last = head . reverse

{-# INLINABLE drop #-}
drop :: Integer -> [a] -> [a]
drop n xs     | n <= 0 =  xs
drop _ []              =  []
drop n (_:xs)          =  drop (subtractInteger n 1) xs

{-# INLINABLE getEvenOdd #-}
getEvenOdd :: [t] -> ([t], [t])
getEvenOdd xs = (es, os)
    where (ys, zs) = partition (even . fst) (zip [0 :: Integer .. ] xs)
          (_,  es) = unzip ys
          (_,  os) = unzip zs

{-# INLINABLE replicate #-}
replicate :: Integer -> t -> [t]
replicate n x
            | n <= 0    = []
            | otherwise = x : replicate (n-1) x

{-# INLINABLE zipWith0 #-}
zipWith0 :: (AdditiveMonoid a, AdditiveMonoid b) => (a -> b -> c) -> [a] -> [b] -> [c]
zipWith0 _ [] []         = []
zipWith0 f [] (b:bs)     = f zero b : zipWith0 f [] bs
zipWith0 f (a:as) []     = f a zero : zipWith0 f as []
zipWith0 f (a:as) (b:bs) = f a b    : zipWith0 f as bs

--------------------------------- Batches ------------------------------------

{-# INLINABLE selectBatch #-}
selectBatch :: Integer -> Integer -> Integer -> Integer -> (Integer, Integer)
selectBatch sz n1 n2 i = (n1 + sz*i, min (n1 + sz*(i+1) - 1) n2)

{-# INLINABLE numBatches #-}
numBatches :: Integer -> Integer -> Integer -> Integer
numBatches sz n1 n2
                | n1 > n2   = 0
                | otherwise = 1 + divide (n2-n1) sz