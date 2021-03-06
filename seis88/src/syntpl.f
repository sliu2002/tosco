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


C      PROGRAM    S Y N T P L 8 8
C      **************************
C
C      PROGRAM SYNTPL88 IS DESIGNED FOR THE COMPUTATION OF RAY 
C      SYNTHETIC SEISMOGRAMS FROM THE IMPULSE SYNTHETIC SEISMOGRAMS 
C      STORED IN THE FILE LU2 GENERATED BY THE PROGRAM SEIS88.
C
C     **************************************************************
C
      DIMENSION IDIST(2000),TIME(2000),A(2000),PH(2000),
     1SEIS(3001),TAS(2000),DIST(1000),SMAX(1000),ISEL(1000),XX(1000),
     2IEP(1000),MTEXT(17),JS(20)
      COMMON/SOUR/ROS,VPS,VSS
C
C     ***
      mode=0
      call serv(mode,lin,lou,llu2,llu3,llu4)
      if(mode.eq.0)lin=5
      if(mode.eq.0)lou=6      
C     ***
C
      PI=3.14159265
      SHF=0.
      LU=0
    1 READ(lin,100)LU2,LU3,MPRINT,LU4,LTAPE
      WRITE(lou,100)LU2,LU3,MPRINT,LU4,LTAPE
      IF(LU2.EQ.0)GO TO 99
      if(mode.eq.1)lu2=llu2
      if(mode.eq.1)lu3=llu3
      if(mode.eq.1)lu4=llu4
      IF(LU4.EQ.0)LU4=10
C
C     ***
C     ***
C
      REWIND LU2
      REWIND LU4
      IF(LU3.NE.0)REWIND LU3
    2 IF(LTAPE.EQ.0)READ(LU2,101)MTEXT
      IF(LTAPE.EQ.1)READ(LU2)MTEXT
      IF(LTAPE.EQ.0)READ(LU2,100)NDST,KSH,itpr
      IF(LTAPE.EQ.1)READ(LU2)NDST,KSH,itpr
      IF(LTAPE.EQ.0)READ(LU2,102)XSOUR,ZSOUR,TSOUR,RSTEP,ROS,VPS,VSS
      IF(LTAPE.EQ.1)READ(LU2)XSOUR,ZSOUR,TSOUR,RSTEP,ROS,VPS,VSS
      IF(LTAPE.EQ.0)READ(LU2,102)(DIST(K),K=1,NDST)
      IF(LTAPE.EQ.1)READ(LU2)(DIST(K),K=1,NDST)
C
      WRITE(lou,101)MTEXT
      WRITE(lou,100)NDST,ksh,itpr
      WRITE(lou,102)XSOUR,ZSOUR,TSOUR,RSTEP,ROS,VPS,VSS
      WRITE(lou,102)(DIST(K),K=1,NDST)
      IF(LU.NE.0)GO TO 3
      READ(lin,100)MCOMP,MRED,MSELEC,MEPIC,MSHIFT,KABS,MSOUR
      WRITE(lou,100)MCOMP,MRED,MSELEC,MEPIC,MSHIFT,KABS,MSOUR
      if(itpr.eq.1)mred=0
      IF(MCOMP.EQ.2.AND.KSH.EQ.0)WRITE(lou,115)
      IF(MCOMP.EQ.2.AND.KSH.EQ.0)GO TO 99
      IF(MCOMP.NE.2.AND.KSH.EQ.1)WRITE(lou,117)
      IF(MCOMP.NE.2.AND.KSH.EQ.1)GO TO 99
      READ(lin,102)TMIN,DT,TMAX,FREQ,GAMA,PSI,VRED,SHIFT
      WRITE(lou,102)TMIN,DT,TMAX,FREQ,GAMA,PSI,VRED,SHIFT
      IF(MEPIC.EQ.0)GO TO 11
      READ(lin,100)NEPIC,(IEP(I),I=1,NEPIC)
      WRITE(lou,100)NEPIC,(IEP(I),I=1,NEPIC)
   11 IF(MSELEC.EQ.0)GO TO 12
      READ(lin,100)NSELEC,(ISEL(I),I=1,NSELEC)
      WRITE(lou,100)NSELEC,(ISEL(I),I=1,NSELEC)
   12 CONTINUE
      IF(KABS.EQ.0)GO TO 5
      READ(lin,102) FREF,QRED
      WRITE(lou,102)FREF,QRED
      IF(FREF.LT.00001)FREF=1.
      IF(QRED.LT..00001)QRED=1.
      RF=FREQ/FREF
C
    5 CALL SOURCE(lin,lou,0,0,MSOUR,0.,ANGLE,AMSOUR,PHSOUR)
C
      NCD=0
      I=0
    3 I=I+1
      IF(I.GT.2000)WRITE(lou,104)
      IF(I.GT.2000)GO TO 99
   17 IF(LTAPE.EQ.0)READ(LU2,116,END=7)
     1NC,IDIST(I),TIME(I),AX,AY,AZ,PHX,PHY,PHZ,ANGLE,TAST
      IF(LTAPE.EQ.1)READ(LU2,END=7)
     1NC,IDIST(I),TIME(I),AX,AY,AZ,PHX,PHY,PHZ,ANGLE,TAST
   18 NC1=IABS(NC)
      NC1=NC1+NCD
      IF(MSELEC.EQ.0)GO TO 14
      DO 13 J=1,NSELEC
      IF(ISEL(J).EQ.NC1)GO TO 14
   13 CONTINUE
      GO TO 3
   14 IF(MEPIC.EQ.0)GO TO 16
      DO 15 J=1,NEPIC
      IF(IEP(J).EQ.IDIST(I))GO TO 16
   15 CONTINUE
      GO TO 3
   16 MWAVE=3
      IF(NC.GT.0.AND.MCOMP.EQ.2)GO TO 17
      IF(NC.LT.0)MWAVE=1
      IF(NC.LT.0.AND.MCOMP.EQ.2)MWAVE=2
      CALL SOURCE(lin,lou,1,MWAVE,MSOUR,0.,ANGLE,AMSOUR,PHSOUR)
      IF(KSH.EQ.1)GO TO 10
      IF(MCOMP.NE.0)GO TO 8
      A(I)=AZ*AMSOUR
      PH(I)=PHZ+PHSOUR
      GO TO 9
    8 IF(MCOMP.NE.1)GO TO 10
      A(I)=AX*AMSOUR
      PH(I)=PHX+PHSOUR
      GO TO 9
C     Insert by Biloti 04/18/01
   10 IF(MCOMP.NE.2)GO TO 201
      A(I)=AY*AMSOUR
      PH(I)=PHY+PHSOUR
    9 IF(MPRINT.GE.1)WRITE(lou,114)
     1NC,IDIST(I),TIME(I),A(I),PH(I),ANGLE,TAST
      IF(KABS.NE.0)TAS(I)=TAST
      IF(KABS.EQ.2)PH(I)=PH(I)-2.*FREQ*TAST*ALOG(RF)
      GO TO 3
C     Amplitude in principal direction
  201 A(I)=AZ*AMSOUR*SQRT(1+(AX/AZ)*(AX/AZ))
      PH(I)=PHZ+PHSOUR
      GO TO 9
C
C
    7 READ(lin,100)LU,LTAPE
      WRITE(lou,100)LU,LTAPE
      IF(LU.EQ.0)GO TO 4
      REWIND LU2
      LU2=LU
      REWIND LU2
      NCD=NC1
      GO TO 2
C
C
    4 ISUM=I-1
      IF(VRED.LT.0.0001)VRED=8.
      IF(FREQ.LT.0.0001)FREQ=4.
      IF(GAMA.LT.0.0001)GAMA=4.0
      IF(MSHIFT.EQ.0)SHF=0.
      IF(MSHIFT.EQ.1)SHF=.241506*GAMA/FREQ
      IF(MSHIFT.EQ.2)SHF=SHIFT
      OMEGA=2.*PI*FREQ
      OMRF=2.*PI*FREF
      OG=OMEGA/GAMA
      OGG=OG*OG
      TSH=0.45*GAMA/FREQ
C
C     CONSTRUCTION OF SYNTHETIC SEISMOGRAMS
C
      IF(NDST.GT.1000)WRITE(lou,105)
      IF(NDST.GT.1000)GO TO 99
      NPTS=(TMAX-TMIN)/DT+1.5
      IF(NPTS.GT.3001)WRITE(lou,106)
      IF(NPTS.GT.3001)GO TO 99
C
C
      MMD=NDST
      IF(MEPIC.NE.0)MMD=NEPIC
      WRITE(LU4)NPTS,TMIN,DT,NDST,DIST(1),RSTEP
      IF(LU3.EQ.0)GO TO 6
      WRITE(LU3,101)MTEXT
      WRITE(LU3,108)MMD,MRED,MCOMP,itpr,VRED,RSTEP,XSOUR,DT
C
C     LOOP FOR RECEIVER POSITIONS
C
    6 CONTINUE
      DO 30 I=1,MMD
      JJ=I
      IF(MEPIC.NE.0)JJ=IEP(I)
      XX(I)=DIST(JJ)
      XXD=ABS(XX(I)-XSOUR)
      XXV=0.
      IF(MRED.NE.0)XXV=XXD/VRED
      AMAX=0.
      DO 20 J1=1,NPTS
   20 SEIS(J1)=0.
      DO 21 K=1,ISUM
      IF(IDIST(K).NE.JJ)GO TO 21
      TR=TIME(K)-XXV+SHF
      IF((TR+TSH).LT.TMIN)GO TO 21
      IF((TR-TSH).GT.TMAX)GO TO 21
      AMPL=A(K)
      PHASE=PH(K)
      IF(AMPL.LT.0.005*AMAX)GO TO 21
      IF(AMPL.GT.AMAX)AMAX=AMPL
      IF1=IFIX((TR-TSH-TMIN)/DT+0.1)
      IF2=IFIX((TR+TSH-TMIN)/DT+0.1)
      IFF1=1
      IF(IF1.GT.0)IFF1=IF1
      IF1=IFF1
      IFF2=NPTS
      IF(IF2.LT.NPTS)IFF2=IF2
      IF2=IFF2
      IF(KABS.EQ.0)GO TO 27
      TAST=TAS(K)*QRED
      OMAS=OMEGA*(1.-OMEGA*TAST/(GAMA*GAMA))
      IF(OMAS.LE.0.)WRITE(lou,112)
      IF(OMAS.LE.0.)GO TO 32
      AABS1=OMEGA*TAST/GAMA
      AABS1=.25*(AABS1*AABS1)
      AABS2=.5*OMAS*TAST
      IF(KABS.NE.2)GO TO 27
      AABS4=OMAS/OMRF
      AABS5=ALOG(AABS4)
      AABS3=(TAST/PI)*(1.+AABS5)
   27 DO 24 KK=IF1,IF2
      TT=TMIN+DT*FLOAT(KK-1)
      TD=TT-TR
      IF(KABS.EQ.2)TD=TD+AABS3
      AA=PSI-PHASE
      BB=-OGG*TD*TD
      IF(KABS.EQ.0)AA=AA+OMEGA*TD
      IF(KABS.NE.0)AA=AA+OMAS*TD
      IF(KABS.EQ.2)AA=AA-OMAS*TAST/PI
      IF(KABS.NE.0)BB=BB-AABS1-AABS2
      AA=AMPL*COS(AA)*EXP(BB)
   24 SEIS(KK)=SEIS(KK)+AA
   21 CONTINUE
      SMAX(I)=0.
      DO 25 KK=1,NPTS
      IF(SMAX(I).GT.ABS(SEIS(KK)))GO TO 25
      SMAX(I)=ABS(SEIS(KK))
   25 CONTINUE
C
C
      WRITE(LU4)(SEIS(J),J=1,NPTS)
   30 CONTINUE
      REWIND LU2
      REWIND LU4
C
C     END OF THE LOOP FOR RECEIVERS
C
      SMAXIM=0.
      DO 26 I=1,MMD
      IF(SMAXIM.GT.SMAX(I))GO TO 26
      SMAXIM=SMAX(I)
      XXX=XX(I)
   26 CONTINUE
      IF(LU3.NE.0)WRITE(LU3,113)XXX,SMAXIM
      WRITE(lou,113)XXX,SMAXIM
      IF(LU3.EQ.0)GO TO 1
C
      READ(LU4)NPTS,TMIN,DT,NDST,DIST(1),RSTEP
      DO 31 I=1,MMD
      READ(LU4)(SEIS(J),J=1,NPTS)
C
C     NORMALIZATION OF SEISMOGRAMS
C
      IF1=0
      IF2=0
      SMAXI=SMAX(I)
      IF(SMAXI.LT..000001)GO TO 35
      DO 34 J=1,NPTS
      SEIS(J)=999.1*SEIS(J)/SMAXI
      IF(ABS(SEIS(J)).LT.1.)GO TO 33
      IF2=0
      IF(IF1.EQ.0.AND.J.EQ.1)IF1=1
      IF(IF1.EQ.0)IF1=J-1
      GO TO 34
   33 IF(IF1.EQ.0)GO TO 34
      IF(IF2.EQ.0)IF2=J
   34 CONTINUE
      TM=TMIN+FLOAT(IF1-1)*DT
      IF(IF2.EQ.0)IF2=NPTS
      NPS=IF2-IF1+1
   35 IF(IF1.EQ.0)NPS=0
      IF(IF1.EQ.0)TM=TMIN
C
      WRITE(LU3,109)XX(I),SMAX(I),TM,NPS
      WRITE(lou,107)XX(I),SMAX(I),TM,NPS
      ISS=20
      IS=IF1-1
   41 IS1=IF2-IS
      IF(IS1.LT.20)ISS=IS1
      DO 40 K=1,ISS
   40 JS(K)=SEIS(IS+K)
      WRITE(LU3,111)(JS(K),K=1,ISS)
      IF(MPRINT.EQ.2.AND.NPS.NE.0)
     1WRITE(lou,110)(JS(K),K=1,ISS)
      IF(IS1.LE.20)GO TO 31
      IS=IS+20
      GO TO 41
   31 CONTINUE
      REWIND LU3
   32 CONTINUE
C
C     ***
C     ***
C
      GO TO 1
C
C
  100 FORMAT(26I3)
  101 FORMAT(17A4)
  102 FORMAT(8F10.5)
  103 FORMAT(2I3,F10.5,2E12.6,4F10.6)
  104 FORMAT(1X,'NUMBER OF READINGS FROM LU2 GREATER THAN 2000.'/,
     11X,'COMPUTATION TERMINATED'/)
  105 FORMAT(1X,'NUMBER OF RECEIVER POSITIONS GREATER THAN 1000.',/,
     11X,'COMPUTATION TERMINATED'/)
  106 FORMAT(1X,'NUMBER OF POINTS IN THE SYNTHETIC SEISMOGRAM
     1GREATER THAN 3001.'/1X,'COMPUTATION TERMINATED'/)
  107 FORMAT(1X,'EPICENTRAL DISTANCE =',F10.5,E15.9,1X,F10.5,I5)
  108 FORMAT(4I5,4F10.5)
  109 FORMAT(F10.5,E15.8,F10.5,I5)
  110 FORMAT(1X,20I4)
  111 FORMAT(20I4)
  112 FORMAT(1X,'FREQUENCY TOO HIGH OR GAMA TOO SMALL'/
     11X,'COMPUTATION TERMINATED'/)
  113 FORMAT(1X,'EPICENTRAL DISTANCE =',F10.5,1X,'SMAXIM =',E15.9)
  114 FORMAT(2I3,F10.5,E12.6,3F10.6)
  115 FORMAT(1X,'THERE ARE NO DATA IN THE FILE FOR SH SEISMOGRAMS'
     1/1X,'COMPUTATION TERMINATED - USE MCOMP.NE.2'/)
  116 FORMAT(2I3,F10.5,3E12.6,5F10.6)
  117 FORMAT(1X,'THERE ARE DATA IN THE FILE ONLY FOR SH SEISMOGRAMS'
     1/1X,'COMPUTATION TERMINATED - USE MCOMP.EQ.2'/)
C
   99 CONTINUE
C
C     ***
C     ***
C
      STOP
      END
