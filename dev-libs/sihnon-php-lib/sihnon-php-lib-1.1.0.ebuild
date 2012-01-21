# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="Sihnon PHP Framework"
HOMEPAGE="http://wiki.sihnon.net/index.php/Sihnon-php-lib"
SRC_URI="https://github.com/optiz0r/sihnon-php-lib/tarball/release-${PV} -> ${PN}-${PV}.tar.gz"

LICENSE="CCPL-Attribution-ShareAlike-NonCommercial-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
USE=""

RDEPEND=">=dev-lang/php-5.3"
DEPEND="${RDEPEND}"

src_prepare() {
	cd "${WORKDIR}"/optiz0r-sihnon-php-lib-*
	S=$(pwd)
}

src_install() {

	insinto "/usr/lib/${PN}"

	doins -r source

}

