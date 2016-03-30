# dataflash
Flashcard/quiz program for memorizing/estimating powers of 2 and data rates (Gbps, MBps, etc.)

### Notes
- By design, this uses only the Ruby stdlib, with no dependencies.
- `ruby lib/dataflash.rb --help` gives you all the options.
- `Control-C` will end the program.

### Usage

Some idiosyncrasies of the `-p / --twos` option, which prints the below table for study purposes:
- You can't change the range of the exponent right now. Sorry. _[29 Mar 2016_
- Where the table starts giving wrong answers, that is where I decided it was okay to stop memorizing the actual number, and it's more helpful to know the first 2 digits and the order of magnitude.
  - When using the quiz function (`--type powers`), answers are accepted within a reasonable range. The program will give you the precise answer, and tell you how far off you were.
  - It's equally helpful to know the signed range for a given byte width, for example the signed range ([usually](https://en.wikipedia.org/wiki/Two's_complement)) for 16 bits is -32768 – +32767. As a result, for 2<sup>n</sup>, when _n_ is a power of two, 2<sup>n-1</sup> has been judged also worth memorizing.

```
remdoherty01 :: ~/repos/dataflash ‹master **› » ruby lib/dataflash.rb -p
--------------------------------
|  4 | 16         | 16         |
|  5 | 32         | 32         |
|  6 | 64         | 64         |
--------------------------------
|  7 | 128        | 128        |
|  8 | 256        | 256        |
|  9 | 512        | 512        |
--------------------------------
| 10 | 1,024      | 1,024      |
| 11 | 2,048      | 2,048      |
| 12 | 4,096      | 4,096      |
--------------------------------
| 13 | 8,192      | 8,100      |
| 14 | 16,384     | 16,000     |
| 15 | 32,768     | 32,768     |
--------------------------------
| 16 | 65,536     | 65,536     |
| 17 | 131,072    | 130,000    |
| 18 | 262,144    | 260,000    |
--------------------------------
| 19 | 524,288    | 520,000    |
| 20 | 1,048,576  | 1,000,000  |
| 21 | 2,097,152  | 2,000,000  |
--------------------------------
| 22 | 4,194,304  | 4,100,000  |
| 23 | 8,388,608  | 8,300,000  |
| 24 | 16,777,216 | 16,000,000 |
--------------------------------
```