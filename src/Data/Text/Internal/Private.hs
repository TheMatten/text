{-# LANGUAGE BangPatterns, Rank2Types, UnboxedTuples #-}

-- |
-- Module      : Data.Text.Internal.Private
-- Copyright   : (c) 2011 Bryan O'Sullivan
--
-- License     : BSD-style
-- Maintainer  : bos@serpentine.com
-- Stability   : experimental
-- Portability : GHC

module Data.Text.Internal.Private
    (
      runText
    , span_
    , spanEnd_
    ) where

import Control.Monad.ST (ST, runST)
import Data.Text.Internal (Text(..), text)
import Data.Text.Unsafe (Iter(..), iter, reverseIter)
import qualified Data.Text.Array as A

span_ :: (Char -> Bool) -> Text -> (# Text, Text #)
span_ p t@(Text arr off len) = (# hd,tl #)
  where hd = text arr off k
        tl = text arr (off+k) (len-k)
        !k = loop 0
        loop !i | i < len && p c = loop (i+d)
                | otherwise      = i
            where Iter c d       = iter t i
{-# INLINE span_ #-}

spanEnd_ :: (Char -> Bool) -> Text -> (# Text, Text #)
spanEnd_ p t@(Text arr off len) = (# hd,tl #)
  where hd = text arr off (k+1)
        tl = text arr (off+k+1) (len-(k+1))
        !k = loop (len-1)
        loop !i | i >= 0 && p c = loop (i+d)
                | otherwise     = i
            where (c,d)         = reverseIter t i
{-# INLINE spanEnd_ #-}

runText :: (forall s. (A.MArray s -> Int -> ST s Text) -> ST s Text) -> Text
runText act = runST (act $ \ !marr !len -> do
                             arr <- A.unsafeFreeze marr
                             return $! text arr 0 len)
{-# INLINE runText #-}
