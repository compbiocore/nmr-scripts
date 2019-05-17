#!/bin/csh

#
# 3D States-Mode HN-Detected Processing.

xyz2pipe -in data/test%03d.fid -x -verb \
| nmrPipe  -fn SOL                                  \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 2 -c 0.5  \
| nmrPipe  -fn ZF -zf 3                             \
| nmrPipe  -fn FT                                   \
| nmrPipe  -fn PS -p0 -43.0  -p1 0.0 -di               \
| nmrPipe  -fn EXT -x1 12.0ppm -xn 5.5ppm -sw                        \
| nmrPipe  -fn TP                                   \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 1 -c 1.0  \
| nmrPipe  -fn ZF -zf 3                             \
| nmrPipe  -fn FT                                   \
| nmrPipe  -fn PS -p0 90.0 -p1 180.0 -di              \
| nmrPipe  -fn TP                                   \
| pipe2xyz -out ft/test%03d.ft2 -x

xyz2pipe -in ft/test%03d.ft2 -z -verb               \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 1 -c 0.5  \
| nmrPipe  -fn ZF -zf 3                             \
| nmrPipe  -fn FT                                   \
| nmrPipe  -fn PS -p0 0.0 -p1 0.0 -di               \
| pipe2xyz -out ft/test%03d.ft3 -z

proj3D.tcl
