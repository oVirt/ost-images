#
# Copyright 2020 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
# Refer to the README and COPYING files for full details of the license
#

# Autoconf initialization
AC_INIT([ost-images],
        [m4_esyscmd([build-aux/pkg-version --version])],
        [devel@ovirt.org])

AC_SUBST([PACKAGE_RELEASE],
	   [m4_esyscmd([build-aux/pkg-version --release])])

AS_IF([test "x$PACKAGE_VERSION" = x],
      AC_MSG_ERROR([package version not defined]))

AS_IF([test "x$PACKAGE_RELEASE" = x],
      AC_MSG_ERROR([package release not defined]))

AM_INIT_AUTOMAKE([foreign])

AC_SUBST([imagedir], ['${datarootdir}/ost-images'])

AC_ARG_WITH(
    [distro],
    [AS_HELP_STRING(
        [--with-distro=DISTRO],
        [the distro that you want to build, @<:@default=el8stream@:>@]
    )],
    ,
    [with_distro="el8stream"]
)
AC_SUBST([DISTRO], ["${with_distro}"])

AC_CONFIG_COMMANDS(
    [report],
    [
        echo "-----"
        echo "----- Will build distro: $DISTRO"
        echo "-----"
    ],
    [DISTRO=$with_distro]
)

AC_OUTPUT([
    Makefile
])
