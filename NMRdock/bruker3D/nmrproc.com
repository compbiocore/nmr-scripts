#!/bin/csh

#
#!/bin/csh

#
# 3D Processing with Linear Prediction in Y and Z Dimensions:
#   Process the Directly-detected X-Axis.
#   Process the Indirectly-detected Z-Axis.
#   Predict and Process the Indirectly-detected Y-Axis.
#   Inverse Process, Predict, and Re-Process the Z-Axis.
 
xyz2pipe -in fid/test%03d.fid -x  -verb             \
| nmrPipe  -fn SOL                                  \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 2 -c 0.5  \
| nmrPipe  -fn ZF -auto                             \
| nmrPipe  -fn FT                                   \
| nmrPipe  -fn PS -p0 230  -p1 0.0 -di               \
| nmrPipe  -fn EXT -x1 12ppm -xn 5.5ppm -sw                        \
| pipe2xyz -out lp/test%03d.ft3 -x

xyz2pipe -in lp/test%03d.ft3 -z -verb               \
| nmrPipe  -fn SP -off 0.5 -end 0.95 -pow 1 -c 0.5  \
| nmrPipe  -fn ZF -auto                             \
| nmrPipe  -fn FT                                   \
| nmrPipe  -fn PS -p0 0.0 -p1 0.0 -di               \
| pipe2xyz -out lp/test%03d.ft3 -z -inPlace

xyz2pipe -in lp/test%03d.ft3 -y -verb               \
| nmrPipe  -fn LP -fb -ord 10                       \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 1 -c 0.5  \
| nmrPipe  -fn ZF -size 128                         \
| nmrPipe  -fn FT                                   \
| nmrPipe  -fn PS -p0 90 -p1 0.0 -di                \
| pipe2xyz -out lp/test%03d.ft3 -y -inPlace

xyz2pipe -in lp/test%03d.ft3 -z -verb               \
| nmrPipe  -fn HT  -auto                            \
| nmrPipe  -fn PS  -inv -hdr                        \
| nmrPipe  -fn FT  -inv                             \
| nmrPipe  -fn ZF  -inv                             \
| nmrPipe  -fn SP  -inv -hdr                        \
| nmrPipe  -fn LP  -fb                              \
| nmrPipe  -fn SP  -off 0.5 -end 0.98 -pow 1 -c 0.5 \
| nmrPipe  -fn ZF  -size 512                        \
| nmrPipe  -fn FT  -alt                             \
| nmrPipe  -fn PS  -hdr -di                         \
| pipe2xyz -out ft/test%03d.ft3 -z -inPlace

proj3D.tcl
