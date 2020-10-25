﻿{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE ViewPatterns #-}
{-# OPTIONS_GHC -O2 -funbox-strict-fields #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
{-# OPTIONS_GHC -fno-warn-unused-binds #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}

import Control.Applicative
import Control.Monad
import Data.Array
import Data.Array.IArray
import Data.Array.MArray
import Data.Array.ST
import Data.Array.Unboxed
import Data.Array.Unsafe
import Data.ByteString.Builder
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.Char
import Data.Function (on)
import Data.Graph
import Data.Int
-- import Data.IntMap.Strict (IntMap)
-- import qualified Data.IntMap.Strict as M
-- import Data.IntSet (IntSet)
-- import qualified Data.IntSet as S
import Data.Ix
import Data.List
import Data.Maybe
import Data.Monoid hiding ((<>))
-- import Data.Sequence (ViewL ((:<)), ViewR ((:>)), (<|), (><), (|>))
-- import qualified Data.Sequence as S
import Data.Tuple
-- import Data.Vector.Unboxed ((!), (!?), (++), (//))
-- import qualified Data.Vector.Unboxed as U
import Debug.Trace
import System.IO hiding (char8)

import Text.Printf

gt :: (Char, Int) -> (Char, Int) -> Bool
gt (_,x) (_,y) = x > y
lt :: (Char, Int) -> (Char, Int) -> Bool
lt (_,x) (_,y) = x < y
cmp :: (Char, Int) ->(Char, Int) -> Ordering
cmp (_,n1) (_,n2) = compare n1 n2
rd :: String -> (Char,Int)
rd (c:n) = (c,read(n)) 
sh :: (Char,Int) -> String
sh (c,n) = printf "%c%d" c n

main :: IO ()
main = do
  n <- getLine
  xs <- getLine
  let l = map rd (words xs)
      b = bubble_sort l
      s = selection_sort l
  putStrLn $ unwords $ map sh b
  putStrLn "Stable"
  putStrLn $ unwords $ map sh s
  let r = if b == s
          then "Stable"
          else "Not stable"
  putStrLn r


bubble_sort :: [(Char,Int)] -> [(Char,Int)]
bubble_sort xs' =
  let (f,xs) = bubble_iter xs'
  in
    if f
    then bubble_sort xs
    else xs

bubble_iter :: [(Char,Int)] -> (Bool,[(Char,Int)])
bubble_iter [] =(False,[])
bubble_iter (x:[]) =(False,(x:[]))
bubble_iter (x0':x1':xs') =
  let (f,xs) = if gt x0' x1'
               then bubble_iter(x0':xs')
               else bubble_iter(x1':xs')
  in
    if gt x0' x1'
    then (True, x1':xs)
    else (f, x0':xs)

selection_sort :: [(Char, Int)] -> [(Char, Int)]
selection_sort [] = []
selection_sort (x:[]) = (x:[])
selection_sort (x0:x1:[]) =
  if gt x0 x1 then (x1:x0:[])
  else (x0:x1:[])
selection_sort (x0':xs')=
  let m = minimumBy cmp xs'
      l = takeWhile (/=m) xs'
      r = tail $ dropWhile (/=m) xs'
  in
    if gt x0' m
    then
      m:(selection_sort $ l++[x0']++r)
    else
       (x0':selection_sort xs')


  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -å-

format :: Show a => Maybe a -> IO ()
format Nothing = putStrLn "NO"
format (Just a) = putStrLn "YES" >> print a

-- [1,2,3] -> 1 2 3
putIntN :: [Int] -> IO ()
putIntN = putStrLn . intercalate [' '] . map show

readInt1 :: BS.ByteString -> Int
readInt1 = fst . fromJust . BS.readInt

readInt2 :: BS.ByteString -> (Int, Int)
readInt2 = toTuple . readIntN

readInt3 :: BS.ByteString -> (Int, Int, Int)
readInt3 = toTriple . readIntN

readIntN :: BS.ByteString -> [Int]
readIntN = map readInt1 . BS.words

readInt641 :: BS.ByteString -> Int64
readInt641 = fromIntegral . fst . fromJust . BS.readInteger

readInt642 :: BS.ByteString -> (Int64, Int64)
readInt642 = toTuple . readInt64N

readInt643 :: BS.ByteString -> (Int64, Int64, Int64)
readInt643 = toTriple . readInt64N

readInt64N :: BS.ByteString -> [Int64]
readInt64N = map readInt641 . BS.words

readInteger1 :: BS.ByteString -> Integer
readInteger1 = fst . fromJust . BS.readInteger

readInteger2 :: BS.ByteString -> (Integer, Integer)
readInteger2 = toTuple . readIntegerN

readInteger3 :: BS.ByteString -> (Integer, Integer, Integer)
readInteger3 = toTriple . readIntegerN

readIntegerN :: BS.ByteString -> [Integer]
readIntegerN = map readInteger1 . BS.words

toTuple :: [a] -> (a, a)
toTuple [x, y] = (x, y)

toTriple :: [a] -> (a, a, a)
toTriple [x, y, z] = (x, y, z)

fromTuple :: (a, a) -> [a]
fromTuple (x, y) = [x, y]

fromTriple :: (a, a, a) -> [a]
fromTriple (x, y, z) = [x, y, z]

-- if not applying, use "const"

applyTuple :: (a -> a') -> (b -> b') -> (a, b) -> (a', b')
applyTuple f g (x, y) = (f x, g y)

applyTriple :: (a -> a') -> (b -> b') -> (c -> c') -> (a, b, c) -> (a', b', c')
applyTriple f g h (x, y, z) = (f x, g y, h z)
