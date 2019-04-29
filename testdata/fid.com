#!/bin/csh

bruk2pipe -in ./ser \
 -bad 0.0 -ext -aswap -AMX -decim 1680 -dspfvs 21 -grpdly 76 \
 -xN 	2048 -yN 	96 \
 -xT 	1024 -yT 	48 \
 -xMODE 	DQD -yMODE 	Echo-AntiEcho \
 -xSW 	11904.7619047619 -ySW 	3445.89937973811 \
 -xOBS 	850.253996175 -yOBS 	86.165164426 \
 -xCAR 	4.713 -yCAR 	117.033  \
 -xLAB 	1H -yLAB 	15N \
 -ndim 	 2 -aq2D 	 States \
 -out ./test.fid -verb -ov

sleep 5