\ To test the ANS File Access word set and extension words

\ Copyright (C) Gerry Jackson 2006, 2007

\ This program is free software; you can redistribute it and/or
\ modify it any way.

\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

\ The tests are not claimed to be comprehensive or correct 

\ ------------------------------------------------------------------------------
\ Version 0.4  22 March 2009 { and } replaced with T{ and }T
\         0.3  20 April 2007  ANS Forth words changed to upper case
\              Removed directory test from the filenames
\         0.2  30 Oct 2006 updated following GForth tests to remove
\              system dependency on file size, to allow for file
\              buffering and to allow for PAD moving around
\         0.1  Oct 2006 First version released

\ ------------------------------------------------------------------------------
\ The tests are based on John Hayes test program for the core word set
\ and requires those files to have been loaded

\ Words tested in this file are:
\     ( BIN CLOSE-FILE CREATE-FILE DELETE-FILE FILE-POSITION FILE-SIZE
\     OPEN-FILE R/O R/W READ-FILE READ-LINE REPOSITION-FILE RESIZE-FILE 
\     S" SOURCE-ID W/O WRITE-FILE WRITE-LINE 
\     FILE-STATUS FLUSH-FILE RENAME-FILE 

\ Words not tested:
\     REFILL INCLUDED INCLUDE-FILE (as these will likely have been
\     tested in the execution of the test files)
\ ------------------------------------------------------------------------------
\ Assumptions, dependencies and notes:
\     - tester.fr has been loaded prior to this file
\     - These tests create files in the current directory, if all goes
\       well these will be deleted. If something fails they may not be
\       deleted. If this is a problem ensure you set a suitable 
\       directory before running this test. There is no ANS standard
\       way of doing this. Also be aware of the file names used below
\       which are:  fatest1.txt, fatest2.txt and fatest3.txt
\ ------------------------------------------------------------------------------

Testing File Access word set

DECIMAL

0 CONSTANT <false>
0 INVERT CONSTANT <true>

\ ------------------------------------------------------------------------------

Testing CREATE-FILE CLOSE-FILE

: fn1 S" fatest1.txt" ;
VARIABLE fid1

T{ fn1 R/W CREATE-FILE SWAP fid1 ! -> 0 }T
T{ fid1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------

Testing OPEN-FILE W/O WRITE-LINE

: line1 S" Line 1" ;

T{ fn1 W/O OPEN-FILE SWAP fid1 ! -> 0 }T
T{ line1 FID1 @ WRITE-LINE -> 0 }T
T{ fid1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------

Testing R/O FILE-POSITION (simple)  READ-LINE 

200 CONSTANT bsize
CREATE buf bsize ALLOT
VARIABLE #chars

T{ fn1 R/O OPEN-FILE SWAP fid1 ! -> 0 }T
T{ fid1 @ FILE-POSITION -> 0. 0 }T
T{ buf 100 fid1 @ READ-LINE ROT DUP #chars ! -> <true> 0 line1 SWAP DROP }T
T{ buf #chars @ line1 COMPARE -> 0 }T
T{ fid1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------

Testing R/W WRITE-FILE REPOSITION-FILE READ-FILE FILE-POSITION S"

: line2 S" Line 2 blah blah blah" ;
: rl1 buf 100 fid1 @ READ-LINE ;
2VARIABLE fp

T{ fn1 R/W OPEN-FILE SWAP fid1 ! -> 0 }T
T{ fid1 @ FILE-SIZE DROP fid1 @ REPOSITION-FILE -> 0 }T
T{ fid1 @ FILE-SIZE -> fid1 @ FILE-POSITION }T
T{ line2 fid1 @ WRITE-FILE -> 0 }T
T{ 10. fid1 @ REPOSITION-FILE -> 0 }T
T{ fid1 @ FILE-POSITION -> 10. 0 }T
T{ 0. fid1 @ REPOSITION-FILE -> 0 }T
T{ rl1 -> line1 SWAP DROP <true> 0 }T
T{ rl1 ROT DUP #chars ! -> <true> 0 line2 SWAP DROP }T
T{ buf #chars @ line2 COMPARE -> 0 }T
T{ rl1 -> 0 <false> 0 }T
T{ fid1 @ FILE-POSITION ROT ROT fp 2! -> 0 }T
T{ fp 2@ fid1 @ FILE-SIZE DROP D= -> <true> }T
T{ s" " fid1 @ WRITE-LINE -> 0 }T
T{ s" " fid1 @ WRITE-LINE -> 0 }T
T{ fp 2@ fid1 @ REPOSITION-FILE -> 0 }T
T{ rl1 -> 0 <true> 0 }T
T{ rl1 -> 0 <true> 0 }T
T{ rl1 -> 0 <false> 0 }T
T{ fid1 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------

Testing BIN READ-FILE FILE-SIZE

: cbuf buf bsize 0 FILL ;
: fn2 S" fatest2.txt" ;
VARIABLE fid2
: setpad PAD 50 0 DO I OVER C! CHAR+ LOOP DROP ;

setpad   \ If anything else is defined setpad must be called again
         \ as pad may move

T{ fn2 R/W BIN CREATE-FILE SWAP fid2 ! -> 0 }T
T{ PAD 50 fid2 @ WRITE-FILE FID2 @ FLUSH-FILE -> 0 0 }T
T{ fid2 @ FILE-SIZE -> 50. 0 }T
T{ 0. fid2 @ REPOSITION-FILE -> 0 }T
T{ cbuf buf 29 fid2 @ READ-FILE -> 29 0 }T
T{ PAD 29 buf 29 COMPARE -> 0 }T
T{ PAD 30 buf 30 COMPARE -> 1 }T
T{ cbuf buf 29 fid2 @ READ-FILE -> 21 0 }T
T{ PAD 29 + 21 buf 21 COMPARE -> 0 }T
T{ fid2 @ FILE-SIZE DROP fid2 @ FILE-POSITION DROP D= -> <true> }T
T{ buf 10 fid2 @ READ-FILE -> 0 0 }T
T{ fid2 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------

Testing RESIZE-FILE

T{ fn2 R/W BIN OPEN-FILE SWAP fid2 ! -> 0 }T
T{ 37. fid2 @ RESIZE-FILE -> 0 }T
T{ fid2 @ FILE-SIZE -> 37. 0 }T
T{ 0. fid2 @ REPOSITION-FILE -> 0 }T
T{ cbuf buf 100 fid2 @ READ-FILE -> 37 0 }T
T{ PAD 37 buf 37 COMPARE -> 0 }T
T{ PAD 38 buf 38 COMPARE -> 1 }T
T{ 500. fid2 @ RESIZE-FILE -> 0 }T
T{ fid2 @ FILE-SIZE -> 500. 0 }T
T{ 0. fid2 @ REPOSITION-FILE -> 0 }T
T{ cbuf buf 100 fid2 @ READ-FILE -> 100 0 }T
T{ PAD 37 buf 37 COMPARE -> 0 }T
T{ fid2 @ CLOSE-FILE -> 0 }T

\ ------------------------------------------------------------------------------

Testing DELETE-FILE

T{ fn2 DELETE-FILE -> 0 }T
T{ fn2 R/W BIN OPEN-FILE SWAP DROP 0= -> <false> }T
T{ fn2 DELETE-FILE 0= -> <false> }T

\ ------------------------------------------------------------------------------

Testing multi-line ( comments

T{ ( 1 2 3
4 5 6
7 8 9 ) 11 22 33 -> 11 22 33 }T

\ ------------------------------------------------------------------------------

Testing SOURCE-ID (can only test it does not return 0 or -1)

T{ SOURCE-ID DUP -1 = SWAP 0= OR -> <false> }T

\ ------------------------------------------------------------------------------

Testing RENAME-FILE FILE-STATUS FLUSH-FILE

: fn3 S" fatest3.txt" ;
: >end fid1 @ FILE-SIZE DROP fid1 @ REPOSITION-FILE ;


T{ fn3 DELETE-FILE DROP -> }T
T{ fn1 fn3 RENAME-FILE 0= -> <true> }T
T{ fn1 FILE-STATUS SWAP DROP 0= -> <false> }T
T{ fn3 FILE-STATUS SWAP DROP 0= -> <true> }T  \ Return value is undefined
T{ fn3 R/W OPEN-FILE SWAP fid1 ! -> 0 }T
T{ >end -> 0 }T
T{ S" Final line" fid1 @ WRITE-LINE -> 0 }T
T{ fid1 @ FLUSH-FILE -> 0 }T		\ Can only test FLUSH-FILE doesn't fail
T{ fid1 @ CLOSE-FILE -> 0 }T

\ Tidy the test folder
T{ fn3 DELETE-FILE drop -> }T

\ ------------------------------------------------------------------------------

CR .( End of File-Access word tests) CR
