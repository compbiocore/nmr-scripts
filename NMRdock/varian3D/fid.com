#!/bin/csh

var2pipe -in ./fid \
 -noaswap -aqORD 1 \
  -xN              2046  -yN                80  -zN                64  \
  -xT              1023  -yT                40  -zT                32  \
  -xMODE        Complex  -yMODE    States-TPPI  -zMODE      Rance-Kay  \
  -xSW        13020.833  -ySW        14078.527  -zSW         1944.300  \
  -xOBS         799.714  -yOBS         201.095  -zOBS          81.044  \
  -xCAR           4.725  -yCAR          43.010  -zCAR         119.998  \
  -xLAB              HN  -yLAB            CACB  -zLAB             N15  \
  -ndim               3  -aq2D         Complex                         \
  -out ./data/test%03d.fid -verb -ov

sleep 5
