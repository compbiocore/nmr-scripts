#!/bin/csh

bruk2pipe -in ./ser \
  -bad 0.0 -ext -aswap -AMX -decim 2080 -dspfvs 20 -grpdly 68  \
  -xN              1024  -yN               512  \
  -xT               512  -yT               256  \
  -xMODE            DQD  -yMODE  Echo-AntiEcho  \
  -xSW         9615.385  -ySW         2433.090  \
  -xOBS         600.133  -yOBS          60.818  \
  -xCAR           4.773  -yCAR         120.078  \
  -xLAB              HN  -yLAB             15N  \
  -ndim               2  -aq2D         Complex  \
  -out ./test.fid -verb -ov

sleep 5
