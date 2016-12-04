# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

DESCRIPTION="Nagios SMART disk checks for devices on SCSI busses"
HOMEPAGE="https://github.com/spjmurray/nagios-plugin-check-scsi-smart"

SRC_URI="https://github.com/spjmurray/nagios-plugin-check-scsi-smart/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3+"
SLOT="0"

KEYWORDS="~amd64 ~x86"

DEPEND="sys-devel/make
	sys-devel/gcc"
RDEPEND=""

src_install() {
	dodir /usr/$(get_libdir)/nagios/plugins
	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_scsi_smart
}
