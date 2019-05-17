#!/bin/csh

bruk2pipe -in ./ser \
  -bad 0.0 -ext -aswap -AMX -decim 2080 -dspfvs 20 -grpdly 68  \
  -xN              2048  -yN                40  -zN               128  \
  -xT              1024  -yT                20  -zT                64  \
  -xMODE            DQD  -yMODE  Echo-AntiEcho  -zMODE    States-TPPI  \
  -xSW         9615.385  -ySW         2128.565  -zSW         8403.361  \
  -xOBS         600.133  -yOBS          60.818  -zOBS         600.133  \
  -xCAR           4.773  -yCAR         117.079  -zCAR           4.773  \
  -xLAB              HN  -yLAB             15N  -zLAB              1H  \
  -ndim               3  -aq2D         Complex                         \
  -out ./fid/test%03d.fid -verb -ov

sleep 5
