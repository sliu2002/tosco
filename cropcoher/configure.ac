# CropCoher - Crop Coherence
# Copyright (C) 2002-2010 Ricardo Biloti <biloti@ime.unicamp.br>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

dnl Process this file with autoconf to produce a configure script.


dnl Every other copy of the package version number gets its value from here
#AC_INIT(src/cropcoher.c)
#AM_INIT_AUTOMAKE(cropcoher,0.1.0)

AC_INIT([cropcoher],[0.1.0])
AC_CONFIG_SRCDIR([src/cropcoher.c])
AM_INIT_AUTOMAKE

AC_SUBST(VERSION)

ISODATE=`date +%Y-%m-%d`
AC_SUBST(ISODATE)

AC_CANONICAL_HOST

dnl Checks for programs.
AC_PROG_INSTALL
AC_PROG_CC

dnl Checks for header files.
AC_HEADER_STDC

AC_HEADER_MAJOR
AC_FUNC_ALLOCA
AC_FUNC_CLOSEDIR_VOID

dnl Check for SU
dnl-----------------------------------------------------------------------

if test "x${CWPROOT}" == "x"; then
  AC_MSG_ERROR([environment variable CWPROOT is not defined])
fi

LIBS="  $LIBS   -L${CWPROOT}/lib -lsu -lpar -lcwp"
CFLAGS="$CFLAGS -I${CWPROOT}/include"

dnl-----------------------------------------------------------------------

AC_OUTPUT( Makefile src/Makefile gebr/Makefile )

dnl-----------------------------------------------------------------------

