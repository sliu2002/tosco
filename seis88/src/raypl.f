C  seis88 - Rays tracing tool
C  Copyright (C) 2009 Ivan Psencik <ip@ig.cas.cz>
C 
C  This program is free software: you can redistribute it and/or modify
C  it under the terms of the GNU General Public License as published by
C  the Free Software Foundation, either version 3 of the License, or
C  (at your option) any later version.
C 
C  This program is distributed in the hope that it will be useful,
C  but WITHOUT ANY WARRANTY; without even the implied warranty of
C  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C  GNU General Public License for more details.
C 
C  You should have received a copy of the GNU General Public License
C  along with this program.  If not, see <http://www.gnu.org/licenses/>.


C
C     ************************
C
C     THE PROGRAM RAYPLOT IS DESIGNED FOR PLOTTING OF RAY DIAGRAMS,
C     TRAVEL TIMES AND AMPLITUDES OF SEISMIC BODY WAVES FROM THE
C     FILE LU GENERATED BY PROGRAM SEIS88
C
C     ****************************************************************
C
      character*80 text
      DIMENSION A(30),B(30),C(30),D(30),X1(30),III(30),NPNT(20)
      DIMENSION X(400),T(400),XZ(400),NR(40),AX(400),AY(400),AZ(400),
     1Y(400),TAS(400),ANG(400),PHX(400),PHY(400),PHZ(400),INDI(400)
      COMMON/SOUR/ROS,VPS,VSS
C
C     ***
      mode=0
      call serv(mode,lin,lou,llu,ldum1,ldum2)
      if(mode.eq.0)lin=5
      if(mode.eq.0)lou=6
      if(mode.eq.0)CALL PLOTS(ldum1,ldum2,7)
      CALL PLOT(5.,5.,-3)
C     ***
C
      XB = 0.
      IRUN = 0
      READ(lin,106)LU,ISHIFT,IPRINT,ltape
      WRITE(lou,106)LU,ISHIFT,IPRINT,ltape
      if(mode.eq.1)lu=llu
      IF(LU.EQ.0)LU=7
C
C     ***
C     ***
C
      REWIND LU
      IF (ISHIFT.EQ.0)ISHIFT=8
      SHIFT=FLOAT(ISHIFT)
  200 continue
      if(ltape.eq.0)READ(LU,101)ICONT,itpr
      if(ltape.eq.1)READ(LU)ICONT,itpr
      WRITE(lou,101)ICONT
C
C     ***
C     ***
C
      IF(ICONT.EQ.0)WRITE(lou,107)LU
      IF(ICONT.EQ.0)GO TO 99
      READ(lin,100)TEXT
      WRITE(lou,100)TEXT
      READ(lin,106)NTICX,NTICY,NTICT,NTICA,INDO,INDT,NRAY,IBOUND,
     1IRED,IRS,NDX,NDY
      WRITE(lou,106)NTICX,NTICY,NTICT,NTICA,INDO,INDT,NRAY,IBOUND,
     1IRED,IRS,NDX,NDY
C
C     ***
C     ***
C
      IF(NTICX.EQ.0)GO TO 99
      if(itpr.eq.22)ired=0
      IF(INDT.EQ.1.OR.INDT.EQ.2)IRED=0
      IF(INDT.EQ.0)INDT=3
      XB = 0.
      IF(IBOUND.EQ.0) IBOUND =100
      READ(lin,102)XMIN,XMAX,XLEN,DTICX,SC
      WRITE(lou,102)XMIN,XMAX,XLEN,DTICX,SC
      IF(ABS(SC).LT..00001)SC=1.
      IF(ABS(XMAX-XMIN).LT..00001)GO TO 32
      XMER = XLEN/(XMAX-XMIN)
      GLH = 1.5
      IF(NTICY.EQ.0)GO TO 32
      READ(lin,102)YMIN,YMAX,YLEN,DTICY
      WRITE(lou,102)YMIN,YMAX,YLEN,DTICY
      YMER = YLEN/(YMAX-YMIN)
C **********************************************************************
C       CALL COLOR(14)
C **********************************************************************
C
C     PLOTTING OF BORDER FOR RAY DIAGRAM
C
      IF(IRUN.EQ.1)CALL PLOT(XLEN+SHIFT,0.,-3)
      IRUN=1
  72  CALL BORDER(XLEN,DTICX,YLEN,DTICY,SC,TEXT,1,XMIN,XMAX,YMIN,YMAX,
     1NTICX,NTICY,NDX,NDY)
      TX=.5*(XLEN-6.3*SC)
      CALL SYMBOL(TX,-1.6*SC,.45*SC,'DISTANCE IN KM',0.,14)
      TX=.5*(YLEN-4.95*SC)
      U=-(1.6+.4*NDX)*SC
      CALL SYMBOL(U,TX,.45*SC,'DEPTH IN KM',90.,11)
C **********************************************************************
C       CALL COLOR(2)
C **********************************************************************
C
C
C     PLOTTING OF INTERFACES
   32 if(ltape.eq.0)READ(LU,101)NINT,(NPNT(I),I=1,NINT)
      if(ltape.eq.1)READ(LU)NINT,(NPNT(I),I=1,NINT)
      IF(IPRINT.EQ.3)WRITE(lou,106)NINT,(NPNT(I),I = 1,NINT)
      IB=IBOUND
      IF(IBOUND.LT.0)IB=-IBOUND
      ib=ib+n
      RD = (XMAX-XMIN)/FLOAT(IB-1)
      YM = YMAX
      DO 5 I = 1,NINT
      N = NPNT(I)-1
      if(ltape.eq.0)READ(LU,111)(A(J),B(J),C(J),D(J),X1(J),III(J),
     1J=1,N)
      if(ltape.eq.1)READ(LU)(A(J),B(J),C(J),D(J),X1(J),III(J),J = 1,N)
      IF(IPRINT.EQ.3)WRITE(lou,105)(A(J),B(J),C(J),D(J),X1(J),III(J),
     1J=1,N)
      IF(NTICY.EQ.0)GOTO 5
      MMM=1
      IF(IBOUND.LT.0)YM=YM-.06/YMER
      IF(IBOUND.LT.0)MMM=3
      DO 4 M=1,MMM
      RB=XMIN
      IF(IBOUND.LT.0)YM=YM+.03/YMER
      IPL=0
      DO 4 J = 1,IB
      IF(RB.GT.(XMAX+0.01))GOTO 4
      DO 1 K = 1,N
      IF(K.EQ.N) K1 = K
      IF(RB.GE.X1(K))GOTO 1
      K1 = K-1
      GOTO 2
  1   CONTINUE
  2   X2 = RB-X1(K1)
      X33=X1(K1+1)
      IF(K1.EQ.N)X33=XMAX
      IF(XMAX.LT.X33)X33=XMAX
      X3=X33-RB
      IF(X3.LT.RD)RB=X33
      IF(X3.LT.RD)X2=X33-X1(K1)
      HXX=YM-(((D(K1)*X2+C(K1))*X2+B(K1))*X2+A(K1)-YMIN)
      IF(HXX.LT.YMIN.OR.HXX.GT.YMAX)IPL=0
      IF(HXX.LT.YMIN.OR.HXX.GT.YMAX)GO TO 4
      IF(IPL.NE.0)GO TO 3
      IPL=1
      XSV=(RB-XMIN)*XMER
      YSV = HXX*YMER
      CALL PLOT(XSV,YSV,3)
      GOTO 4
    3 XSV = (RB-XMIN)*XMER
      YSV = HXX*YMER
      IF(III(K1).EQ.0.OR.III(K1).EQ.(-1))CALL PLOT(XSV,YSV,2)
      IF(III(K1).EQ.(-2).OR.III(K1).GT.0)CALL PLOT(XSV,YSV,3)
      RB = RB+RD
      if((k1+2).le.n.and.rb.gt.x1(k1+2))rb=x1(k1+2)
    4 continue
      IF(IBOUND.LT.0)YM=YM-0.03/YMER
    5 CONTINUE
   20 if(ltape.eq.0)READ(LU,102)X0,Y0,ROS,VPS,VSS
      if(ltape.eq.1)READ(LU)X0,Y0,ROS,VPS,VSS
      IF(IPRINT.EQ.3)WRITE(lou,102)X0,Y0,ROS,VPS,VSS
      IF(NTICY.EQ.0)GOTO 21
C
C
C     PLOTTING OF RAYS
C
C **********************************************************************
       CALL COLOR(4)
C **********************************************************************
  26  IF(NRAY.NE.0) READ(lin,101)(NR(I),I = 1,NRAY)
      IF(NRAY.NE.0) WRITE(lou,104)(NR(I),I = 1,NRAY)
      I = 1
      K = 1
  21  if(ltape.eq.0)READ(LU,112)N,IND
      if(ltape.eq.1)READ(LU)N,IND
      IPL = 0
      WRITE(lou,106)N,IND
      IF(N.EQ.0)GOTO 24
      if(ltape.eq.0)READ(LU,113)(X(J),Y(J),J = 1,N)
      if(ltape.eq.1)READ(LU)(X(J),Y(J),J = 1,N)
      IF(IPRINT.EQ.3)WRITE(lou,102)(X(J),Y(J),J = 1,N)
      IF(INDO.NE.0.AND.IND.NE.INDO)GO TO 21
      IF(NTICY.EQ.0)GO TO 21
      IF(NRAY.EQ.0)GOTO 25
      IF(NR(K).EQ.I)GOTO 22
  25  DO 10 J = 1,N
      XX = X(J)
      YY = Y(J)
      IF(XX.LT.XMIN.OR.XX.GT.XMAX)GOTO 8
      IF(YY.LT.YMIN.OR.YY.GT.YMAX)GOTO 9
      IF(IPL.EQ.1)GOTO 6
      IF(J.LE.IRS)GO TO 10
      IPL = 1
      INDEX = 3
      GO TO 7
  6   INDEX = 2
  7   XNEW = (XX-XMIN)*XMER
      YNEW = (YMAX-(YY-YMIN))*YMER
      CALL PLOT(XNEW,YNEW,INDEX)
      GOTO 10
  8   IF (IPL.EQ.0) GOTO 10
      IF(XX.LT.XMIN) XXX = XMIN
      IF(XX.GT.XMAX) XXX = XMAX
      TG=(YY-Y(J-1))/(XX-X(J-1))
      YY = TG*(XXX-XX)+YY
      XX = XXX
      IPL=0
      GOTO 6
  9   IF (IPL.EQ.0) GOTO 10
      IF(YY.LT.YMIN) YYY=YMIN
      IF(YY.GT.YMAX) YYY=YMAX
      TG=(XX-X(J-1))/(YY-Y(J-1))
      XX = TG*(YYY-YY)+XX
      YY = YYY
      IPL=0
      GOTO 6
  10  CONTINUE
      GOTO 23
  22  IF(K.GE.NRAY)GOTO 23
      K = K+1
  23  I = I+1
      GOTO 21
  24  CONTINUE
      IF(NTICY.EQ.0)GO TO 11
C **********************************************************************
       CALL COLOR(3)
C **********************************************************************
      XNEW = X0-XMIN
      XNEW = XNEW*XMER
      YNEW = YMAX-(Y0-YMIN)
      YNEW = YNEW*YMER
      IF(XNEW.LT.0..OR.XNEW.GT.XLEN.OR.YNEW.LT.0..OR.YNEW.GT.
     1YLEN) GO TO 33
      RD=.3*SC
      CALL PLOT(XNEW+RD,YNEW+RD,3)
      CALL PLOT(XNEW,YNEW,2)
      CALL PLOT(XNEW+RD,YNEW-RD,2)
      CALL PLOT(XNEW-RD,YNEW-RD,3)
      CALL PLOT(XNEW,YNEW,2)
      CALL PLOT(XNEW-RD,YNEW+RD,2)
      CALL PLOT(XNEW,YNEW,3)
   33 CONTINUE
C
C     PLOTTING OF TIME-DISTANCE CURVE
C
  11  if(ltape.eq.0)READ(LU,112)NS
      if(ltape.eq.1)READ(LU)NS
      IF(IPRINT.GE.2)WRITE(lou,106)NS
      NWTYP=NS
      IF(NS.LT.0)NS=-NS
      IF(NS.NE.0.and.ltape.eq.0)READ(LU,114)(INDI(I),X(I),T(I),TAS(I),
     1ANG(I),AX(I),AY(I),AZ(I),PHX(I),PHY(I),PHZ(I),I=1,NS)
      IF(NS.NE.0.and.ltape.eq.1)READ(LU)(INDI(I),X(I),T(I),TAS(I),
     1ANG(I),AX(I),AY(I),AZ(I),PHX(I),PHY(I),PHZ(I),I=1,NS)
      IF(NS.NE.0.AND.IPRINT.GE.2)WRITE(lou,108)(INDI(I),X(I),T(I),
     1TAS(I),ANG(I),AX(I),AY(I),AZ(I),PHX(I),PHY(I),PHZ(I),I=1,NS)
      NSS = NS
  35  CONTINUE
      IF(NTICT.EQ.0)GOTO 15
      READ(lin,102)TMIN,TMAX,TLEN,DTICT,VRED
      WRITE(lou,102)TMIN,TMAX,TLEN,DTICT,VRED
      IF(IRUN.EQ.1)CALL PLOT(0.,YLEN+SHIFT,-3)
      IRUN=1
      IF(NSS.EQ.0)GOTO 30
      IEX=0
      if(itpr.ne.22)go to 40
      XMER=XLEN/(YMAX-YMIN)
      DTICX=DTICY
      XMIN=YMIN
      XMAX=YMAX
      NTICX=NTICY
   40 CONTINUE
      YMER = TLEN/(TMAX-TMIN)
      IF(ABS(VRED).LT..00001) VRED = 6.
      NAUX=3
      IF(INDT.EQ.1.OR.INDT.EQ.2)NAUX=5
C
C **********************************************************************
      CALL COLOR(14)
C **********************************************************************
C
      CALL BORDER(XLEN,DTICX,TLEN,DTICT,SC,TEXT,0,XMIN,XMAX,TMIN,
     1TMAX,NTICX,NTICT,NDX,NDY)
      TX=.5*(XLEN-6.3*SC)
      if(itpr.ne.22)
     1CALL SYMBOL(TX,-1.6*SC,.45*SC,'DISTANCE IN KM',0.,14)
      if(itpr.eq.22)
     1CALL SYMBOL(TX,-1.6*SC,.45*SC,'DEPTH IN KM',0.,11)
      TX=.5*(YLEN-8.1*SC)
      U=-(1.6+.4*NDX)*SC
      IF(IRED.EQ.0)
     1CALL SYMBOL(U,TX,.45*SC,'TRAVEL TIME IN SEC',90.,18)
      IF(IRED.EQ.0)GO TO 27
      CALL SYMBOL(U,TX,.45*SC,'T-D/ ',90.,5)
      TX=TX+1.8*SC
      CALL NUMBER(U,TX,.45*SC,VRED,90.,2)
      TX=TX+2.7*SC
      CALL SYMBOL(U,TX,.45*SC,'(IN SEC)',90.,8)
   27 CONTINUE
C
C **********************************************************************
      CALL COLOR(4)
C **********************************************************************
C
      INDEX = 9
  12  DO 13 I = 1,NS
      IF(IEX.EQ.0.AND.INDI(I).NE.INDT)GO TO 13
      XNEW = X(I)
      IF(IEX.EQ.1)XNEW=XZ(I)
      IF(XNEW.LT.XMIN.OR.XNEW.GT.XMAX)GOTO 13
      YNEW=T(I)
      IF(IRED.NE.0)YNEW=T(I)-ABS(XNEW-X0)/VRED
      XNEW = (XNEW-XMIN)*XMER
      IF(YNEW.LT.TMIN.OR.YNEW.GT.TMAX)GOTO 13
      YNEW = (YNEW-TMIN)*YMER
      CALL SYMBOL(XNEW,YNEW,.15*sc,char(INDEX),0.,-index)
  13  CONTINUE
      IF(IEX.EQ.0)GOTO 30
      NS = NSS
      GOTO 14
  30  READ(lin,101)NEXP
      WRITE(lou,104)NEXP
      IF(NEXP.EQ.0)GOTO 14
C
C **********************************************************************
      CALL COLOR(2)
C **********************************************************************
C
      NS = NEXP
      READ(lin,102)(XZ(I),T(I),I=1,NS)
      WRITE(lou,102)(XZ(I),T(I),I=1,NS)
      IF(NSS.EQ.0)GO TO 15
      IEX = 1
      INDEX = 2
      GOTO 12
   14 CONTINUE
      CALL PLOT(0.,-YLEN-SHIFT,-3)
C
C
C     PLOTTING OF AMPLITUDE-DISTANCE CURVE
C
   15 IF(NTICA.EQ.0)GO TO 200
      IRUN1=0
      ALBACK=0.
   19 READ(lin,109)AMIN,AMAX,ALEN,DTICA,FREQ,KABS,ICOMP,MSOUR
      WRITE(lou,109)AMIN,AMAX,ALEN,DTICA,FREQ,KABS,ICOMP,MSOUR
      IF(ALEN.LT..00001)CALL PLOT(0.,-ALBACK,-3)
      IF(ALEN.LT..00001)GO TO 200
      CALL SOURCE(lin,lou,0,0,MSOUR,0.,ANGLE,AMSOUR,PHSOUR)
      IF(KABS.EQ.0)GO TO 38
   38 IF(NSS.EQ.0)GO TO 36
      IF(INDT.EQ.4)GO TO 36
      IF(IRUN.EQ.1.AND.IRUN1.EQ.0)CALL PLOT(XLEN+SHIFT,0.,-3)
      IF(IRUN1.EQ.1)CALL PLOT(0.,ALEN+SHIFT,-3)
      IF(IRUN1.EQ.1)ALBACK=ALBACK+ALEN+SHIFT
      IRUN1=1
      IRUN=1
      IEX=0
      YMER=ALEN/(AMAX-AMIN)
      NAUX=2
      IF(INDT.EQ.1.OR.INDT.EQ.2)NAUX=4
C
C **********************************************************************
      CALL COLOR(14)
C **********************************************************************
C
      CALL BORDER(XLEN,DTICX,ALEN,DTICA,SC,TEXT,0,XMIN,XMAX,AMIN,
     1AMAX,NTICX,NTICA,NDX,NDY)
      TX=.5*(XLEN-6.3*SC)
      if(itpr.ne.22)
     1CALL SYMBOL(TX,-1.6*SC,.45*SC,'DISTANCE IN KM',0.,14)
      if(itpr.eq.22)
     1CALL SYMBOL(TX,-1.6*SC,.45*SC,'DEPTH IN KM',0.,11)
      TX=.5*(ALEN-7.65*SC)
      U=-(1.6+.4*NDX)*SC
      CALL SYMBOL(U,TX,.45*SC,'A M P L I T U D E',90.,17)
      IF(ICOMP.EQ.0)
     1CALL SYMBOL(.45*SC,ALEN+SC,.45*SC,'VERTICAL',0.,8)
      IF(ICOMP.EQ.1)
     1CALL SYMBOL(.45*SC,ALEN+SC,.45*SC,'RADIAL',0.,6)
      IF(ICOMP.EQ.2)
     1CALL SYMBOL(.45*SC,ALEN+SC,.45*SC,'TRANSVERSE',0.,10)
C
C **********************************************************************
      CALL COLOR(13)
C **********************************************************************
C
  28  INDEX=9
  16  DO 17 I = 1,NS
      IF(IEX.EQ.0.AND.INDI(I).NE.INDT)GO TO 17
      XNEW = X(I)
      YNEW=AZ(I)
      IF (ICOMP.EQ.1)YNEW=AX(I)
      IF (ICOMP.EQ.2)YNEW=AY(I)
      MWAVE=1
      IF(NWTYP.LT.0)MWAVE=2
      IF(NWTYP.LT.0.AND.ICOMP.EQ.2)MWAVE=3
C
C     COMPUTATION OF SOURCE EFFECTS
C     *****************************
      ANGLE=ANG(I)
      CALL SOURCE(lin,lou,1,MWAVE,MSOUR,0.,ANGLE,AMSOUR,PHSOUR)
      YNEW=YNEW*AMSOUR
C     *****************************
C
      IF(IEX.EQ.0.OR.NEXP.EQ.0)GO TO 41
      XNEW=XZ(I)
      YNEW=T(I)
      GO TO 31
C
C     COMPUTATION OF ABSORPTION EFFECTS
C     *********************************
   41 IF(KABS.GT.0)TAST=TAS(I)
      IF(KABS.GT.0)YNEW=YNEW*EXP(-3.1415926*FREQ*TAST)
C     **************************************************
C
      IF(IPRINT.EQ.1)WRITE(lou,110)X(I),YNEW
   31 IF(XNEW.LE.XMIN.OR.XNEW.GE.XMAX)GO TO 17
      XNEW=(XNEW-XMIN)*XMER
      IF(ABS(YNEW).LT.1E-10)GO TO 17
      YNEW = ALOG10(ABS(YNEW))
      IF(YNEW.LT.AMIN.OR.YNEW.GT.AMAX)GOTO 17
      YNEW=(YNEW-AMIN)*YMER
      CALL SYMBOL(XNEW,YNEW,.15*sc,char(INDEX),0.,-index)
   17 CONTINUE
   36 IF(IEX.EQ.1)GOTO 18
      READ(lin,101)NEXP
      WRITE(lou,104)NEXP
      IF(NEXP.EQ.0)GOTO 18
C
C **********************************************************************
      CALL COLOR(2)
C **********************************************************************
C
      NS = NEXP
      READ(lin,102) (XZ(I),T(I),I=1,NS)
      WRITE(lou,102)(XZ(I),T(I),I=1,NS)
      IF(NSS.EQ.0)GO TO 18
      IF(INDT.EQ.1.OR.INDT.EQ.2.OR.INDT.EQ.4)GO TO 18
      IEX=1
      INDEX = 2
      GOTO 16
   18 IF(IEX.EQ.0)GO TO 29
      NS=NSS
   29 CONTINUE
C
C
      GO TO 19
C
C
  100 FORMAT(A)
  101 FORMAT(26I3)
  102 FORMAT(8F10.5)
  103 FORMAT(2X,I2,3(2F7.2,E10.3))
  104 FORMAT(2X,26I3)
  105 FORMAT(5E12.6,I5)
  106 FORMAT(16I5)
  107 FORMAT(2X,'END OF FILE',I3)
  108 FORMAT(I5,4F10.5,3E15.9,3F10.5)
  109 FORMAT(5F10.5,4I5)
  110 FORMAT(F10.5,E15.9)
  111 format(5e15.5,i5)
  112 format(2i5)
  113 format(2e15.5)
  114 format(i5,10e15.5)
C
   99 CONTINUE
C
C     ***
C     ***
C
      CALL PLOT(0.,0.,999)
      STOP
      END
C
C
