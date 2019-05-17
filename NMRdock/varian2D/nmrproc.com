#!/bin/csh

#
# Basic 2D Phase-Sensitive Processing:
#   Cosine-Bells are used in both dimensions.
#   Use of "ZF -auto" doubles size, then rounds to power of 2.
#   Use of "FT -auto" chooses correct Transform mode.
#   Imaginaries are deleted with "-di" in each dimension.
#   Phase corrections should be inserted by hand.

nmrPipe -in test.fid \
| nmrPipe  -fn SOL                                    \
| nmrPipe  -fn SP -off 0.5 -end 1.00 -pow 1 -c 1.0    \
| nmrPipe  -fn ZF -zf 3                               \
| nmrPipe  -fn FT -auto                               \
| nmrPipe  -fn PS -p0 -79.00 -p1 -36.00 -di -verb         \
| nmrPipe  -fn EXT -x1 11ppm -xn 6.5ppm -sw                                    \
| nmrPipe  -fn TP                                     \
| nmrPipe  -fn LP -fb -ord 12                                    \
| nmrPipe  -fn SP -off 0.5 -end 1.00 -pow 1 -c 1.0    \
| nmrPipe  -fn ZF -zf 3                               \
| nmrPipe  -fn FT -neg                               \
| nmrPipe  -fn PS -p0 0.00 -p1 180.00 -di -verb         \
   -ov -out test.ft2
