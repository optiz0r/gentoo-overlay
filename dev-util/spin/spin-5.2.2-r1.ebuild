# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

SPIN_PN="spin"
SPIN_PV="${PV}"
SPIN_CV="522"
SPIN_P="${SPIN_PN}-${SPIN_PV}"
SPIN_A="${SPIN_PN}${SPIN_CV}.tar.gz"
SPIN_S="${WORKDIR}/Spin"
SPIN_LICENSE="${FILESDIR}/SPIN-Commercial"
XSPIN_MAJOR_VER="5.2"

DESCRIPTION="On-the-fly, LTL Model Checker"
HOMEPAGE="http://spinroot.com"
SRC_URI="http://spinroot.com/${SPIN_PN}/Src/${SPIN_A}"
LICENSE="SPIN-Commercial"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="xspin dot"

# Xspin requires Tcl/Tk
DEPEND="xspin? ( >=dev-lang/tcl-8.4 >=dev-lang/tk-8.4 )
		dot? ( media-gfx/graphviz )"

S="${SPIN_S}"

src_unpack() {
	unpack ${A}
}

src_compile() {
	check_license ${SPIN_LICENSE}

	if use xspin; then
		epatch "${FILESDIR}/${P}-xspin_time.patch"
		# has to guess, because the version numbers are different from spin
		XSPIN_TCL=$(find ${SPIN_S} -name 'xspin*')
		mv ${XSPIN_TCL} ${SPIN_S}/Xspin${XSPIN_MAJOR_VER}/xspin
	fi
	cd ${SPIN_S}/Src${SPIN_PV}
	emake -j1 || die "emake failed"

}

src_install() {
	# install the executable
	into /usr
	dobin Src${SPIN_PV}/${SPIN_PN}
	
	if use xspin; then
		dobin Xspin${XSPIN_MAJOR_VER}/xspin
	fi

	# install the docs and man pages
	into /usr
	doman Man/${SPIN_PN}.*
	dodoc Doc/*

	# install the license
	insinto /usr/portage/licenses
	doins ${SPIN_LICENSE}
}
