{
module Lexer where

import System.IO
import System.IO.Unsafe
}

%wrapper "basic"

$digit = 0-9      -- digits
$alpha = [a-zA-Z] -- alphabetic characters
$assignment = \=
$parenthesis = [\(\)]
$block = [\{\}]

$op = [\#\+\-\*]       -- operacoes
$whitespace = [\ \t\b]
$blockBegin = [\(\[\{]
$blockEnd = [\)\]\}]
$comma = [\,\"\']
$stringCommas = [\'\,\.\;\:\=\>\<\\\/\|\!\$\%\@\&]

-- literal types
@types = int
       | float
       | string
       | bool
@float_number = $digit+ \. $digit+
@bool = true | false

tokens :-

  $white+                                ;
  "--".*                                 ;
  :                                      { \s -> Colon}
  ";"                                    { \s -> SemiColon}
  ","                                    { \s -> Comma}
  @types                                 { \s -> Type s}
  func                                   { \s -> Function}
  $assignment                            { \s -> Assign}
  $parenthesis                           { \s -> Parenthesis s }
  $block                                 { \s -> Block s }
  "+"                                    { \p -> Add }
  "-"                                    { \p -> Sub }
  "*"                                    { \p -> Mult }
  if                                     { \s -> If}
  else                                   { \s -> Else}
  for                                    { \s -> For}
  while                                  { \s -> While}
  -- @bool                                  { \s -> Bool s }
  \>                                     { \s -> Greater}
  \<                                     { \s -> Lower}
  \=\=                                   { \s -> EqualTo}
  $digit+                                { \s -> Int (read s) }
  @float_number                          { \s -> Float (read s)}
  $alpha [$alpha $digit \_ \']*          { \s -> Id s }
  \"+($alpha|$digit|$whitespace|$blockBegin|$blockEnd|$op|$stringCommas)+\" { \s -> String s}

{
-- Each action has type :: String -> Token

-- The token type:
data Token =
  Colon                     |
  SemiColon                 |
  Comma                     |
  Assign                    |     
  If                        |
  Else                      |
  For                       |
  While                     |
  Greater                   |
  Lower                     |
  EqualTo                   |
  Block String              |
  Parenthesis String        |
  Type String               |
  Function                  |
  Id String                 |
  Int Int                   |
  Float Double              |
  String String             |
  -- Bool Bool                 |
  Add                       |
  Sub                       |
  Mult
  deriving (Eq,Show)

getTokens fn = unsafePerformIO (getTokensAux fn)

getTokensAux fn = do {fh <- openFile fn ReadMode;
                      s <- hGetContents fh;
                      return (alexScanTokens s)}
}