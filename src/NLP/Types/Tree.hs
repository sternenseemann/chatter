{-# LANGUAGE OverloadedStrings #-}
module NLP.Types.Tree where

import Prelude hiding (print)
import Data.List (intercalate)

import qualified NLP.Corpora.Brown as B
import NLP.Types hiding (Sentence, TaggedSentence)

-- | A sentence of tokens without tags.  Generated by the tokenizer.
-- (tokenizer :: Text -> Sentence)
data Sentence = Sent [Token]
  deriving (Read, Show, Eq)

-- | A chunked sentence has POS tags and chunk tags. Generated by a
-- chunker.
--
-- (chunker :: (Chunk chunk, Tag tag) => TaggedSentence tag -> ChunkedSentence chunk tag)
data ChunkedSentence chunk tag = ChunkedSent [ChunkOr chunk tag]
  deriving (Read, Show, Eq)

-- | A tagged sentence has POS Tags.  Generated by a part-of-speech
-- tagger. (tagger :: Tag tag => Sentence -> TaggedSentence tag)
data TaggedSentence tag = TaggedSent [POS tag]
  deriving (Read, Show, Eq)


-- | This type seem redundant, it just exists to support the
-- differences in TaggedSentence and ChunkedSentence.
--
-- See the t3 example below to see how verbose this becomes.
data ChunkOr chunk tag = Chunk_CN (Chunk chunk tag)
                       | POS_CN   (POS tag)
                         deriving (Read, Show, Eq)

-- mkChunk :: (Chunk chunk, Tag tag) => tag -> ChunkOr chunk tag
mkChunk tag children = Chunk_CN (Chunk tag children)

-- mkChink :: (Chunk chunk, Tag tag) => tag -> ChunkOr chunk tag
mkChink tag token    = POS_CN   (POS tag token)


data Chunk chunk tag = Chunk chunk [ChunkOr chunk tag]
  deriving (Read, Show, Eq)

data POS tag = POS tag Token
  deriving (Read, Show, Eq)

data Token = Token String
  deriving (Read, Show, Eq)

-- (S (NP (NN I)) (VP (V saw) (NP (NN him))))
t1 :: Sentence
t1 = Sent
     [ Token "I"
     , Token "saw"
     , Token "him"
     , Token "."
     ]

t2 :: TaggedSentence B.Tag
t2 = TaggedSent
     [ POS B.NN    (Token "I")
     , POS B.VB    (Token "saw")
     , POS B.NN    (Token "him")
     , POS B.Term  (Token ".")
     ]

t3 :: ChunkedSentence B.Chunk B.Tag
t3 = ChunkedSent
     [ mkChunk B.C_NP [ POS_CN (POS B.NN (Token "I"))]
     , mkChunk B.C_VP [ POS_CN (POS B.VB (Token "saw"))
                      , POS_CN (POS B.NN (Token "him"))
                      ]
     , mkChink B.Term (Token ".")
     ]
