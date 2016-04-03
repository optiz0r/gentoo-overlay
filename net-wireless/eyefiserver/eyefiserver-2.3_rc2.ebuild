# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# All credit for this ebuild and associated files to Peter Silmano
# https://cgit.gentoo.org/user/silmano.git/
# unfortunately the overlay is no longer available in layman

EAPI="2"

inherit eutils

DESCRIPTION="An open source Eye-Fi Server written in Python."
HOMEPAGE="http://returnbooleantrue.blogspot.com/"
SRC_URI="https://github.com/nirgal/EyeFiServer/archive/${PVR}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-lang/python"

src_unpack() {
	unpack ${A}
}

src_prepare() {
	cd "${WORKDIR}/EyeFiServer-${PVR}"
	epatch "${FILESDIR}/human_readable.patch"
}

src_install() {
	cd "${WORKDIR}/EyeFiServer-${PVR}"
	insinto /etc
	doins etc/eyefiserver.conf || die
	doinitd "${FILESDIR}/eyefiserverd" || die
	exeinto /usr/bin
	doexe src/eyefiserver || die
	doman "${FILESDIR}/eyefiserver.1" || die
	doman "${FILESDIR}/eyefiserver.conf.5" || die
}

pkg_postinst() {
	elog "You will need to set up your /etc/eyefiserver.conf file before"
	elog "running EyeFi Server for the first time."
}
