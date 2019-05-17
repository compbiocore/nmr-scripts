#!/bin/csh

var2pipe -in ./fid \
 -noaswap  \
  -xN              4096  -yN               256  \
  -xT              2048  -yT               128  \
  -xMODE        Complex  -yMODE      Rance-Kay  \
  -xSW        12001.200  -ySW         2500.000  \
  -xOBS         599.751  -yOBS          60.779  \
  -xCAR           4.725  -yCAR         119.897  \
  -xLAB              HN  -yLAB             N15  \
  -ndim               2  -aq2D         Complex  \
  -out ./test.fid -verb -ov

sleep 5
