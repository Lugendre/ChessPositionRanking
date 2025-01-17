module Main (main) where

import Chess -- this and next 3 modules are from hchesslib
import Chess.FEN
import Chess.Internal.Game -- with customized updateEnPassantSquare
import Chess.Internal.Move
import Data.Either
import Data.List qualified as L
import System.Environment
import System.Random

randomMoves :: (RandomGen g) => GameState -> Int -> g -> (GameState, g)
randomMoves gs len gen =
    let
        (r, gen1) = randomR (0, len) gen
        mvs = generateAllMoves gs
        (i, gen2) = randomR (0, length mvs - 1) gen1
     in
        if r == 0 || null mvs
            then (gs, gen1)
            else randomMoves (fromRight (error "Bad move") . applyMove gs $ mvs !! i) len gen2

randomFEN :: (RandomGen g) => Int -> g -> (String, g)
randomFEN len gen = (writeFEN gs, gen1)
  where
    (gs, gen1) = randomMoves newGame len gen

rndFENs :: Int -> Int -> [String]
rndFENs len seed = L.unfoldr (Just . randomFEN len) $ mkStdGen seed

main :: IO ()
main = do
    args <- getArgs
    case args of
        (lenstr : nstr : rest) -> mapM_ putStrLn . take n . rndFENs len $ seed
          where
            n = read nstr :: Int
            len = read lenstr :: Int
            seed = case rest of
                [sdstr] -> read sdstr :: Int
                [] -> 0
        _ -> putStrLn "usage: randomFENs <avglen> <n> [<seed>]"
