
module Prelude.IO where

open import Prelude.Function
open import Prelude.Functor
open import Prelude.Applicative
open import Prelude.Monad
open import Prelude.List
open import Prelude.String
open import Prelude.Char
open import Prelude.Unit
open import Prelude.Show

open import Agda.Builtin.IO public

postulate
  ioReturn : ∀ {a} {A : Set a} → A → IO A
  ioBind   : ∀ {a b} {A : Set a} {B : Set b} → IO A → (A → IO B) → IO B

{-# COMPILED ioReturn (\ _ _ -> return)    #-}
{-# COMPILED ioBind   (\ _ _ _ _ -> (>>=)) #-}

{-# COMPILED_UHC ioReturn (\ _ _ x -> UHC.Agda.Builtins.primReturn x) #-}
{-# COMPILED_UHC ioBind   (\ _ _ _ _ x y -> UHC.Agda.Builtins.primBind x y) #-}

instance
  MonadIO : ∀ {a} → Monad {a} IO
  return {{MonadIO}} = ioReturn
  _>>=_  {{MonadIO}} = ioBind

  MonadIO′ : ∀ {a b} → Monad′ {a} {b} IO
  _>>=′_ {{MonadIO′}} = ioBind

  FunctorIO : ∀ {a} → Functor {a} IO
  FunctorIO = defaultMonadFunctor

  ApplicativeIO : ∀ {a} → Applicative {a} IO
  ApplicativeIO = defaultMonadApplicative

--- Terminal IO ---

postulate
  getChar  : IO Char
  putChar  : Char → IO Unit
  putStr   : String → IO Unit
  putStrLn : String → IO Unit

{-# IMPORT Data.Text    #-}
{-# IMPORT Data.Text.IO #-}

{-# COMPILED getChar  getChar   #-}
{-# COMPILED putChar  putChar   #-}
{-# COMPILED putStr   Data.Text.IO.putStr   #-}
{-# COMPILED putStrLn Data.Text.IO.putStrLn #-}

{-# COMPILED_UHC putStr   (UHC.Agda.Builtins.primPutStr) #-}
{-# COMPILED_UHC putStrLn (UHC.Agda.Builtins.primPutStrLn) #-}

print : ∀ {a} {A : Set a} {{ShowA : Show A}} → A → IO Unit
print = putStrLn ∘ show

--- File IO ---

FilePath = String

postulate
  readFile  : FilePath → IO String
  writeFile : FilePath → String → IO Unit

{-# COMPILED readFile  Data.Text.IO.readFile  . Data.Text.unpack #-}
{-# COMPILED writeFile Data.Text.IO.writeFile . Data.Text.unpack #-}

{-# COMPILED_UHC readFile  (UHC.Agda.Builtins.primReadFile) #-}
{-# COMPILED_UHC writeFile (UHC.Agda.Builtins.primWriteFile) #-}

--- Command line arguments ---

{-# IMPORT System.Environment #-}

postulate
  getArgs : IO (List String)
  getProgName : IO String

{-# COMPILED getArgs     fmap (map Data.Text.pack) System.Environment.getArgs #-}
{-# COMPILED getProgName fmap Data.Text.pack System.Environment.getProgName   #-}
