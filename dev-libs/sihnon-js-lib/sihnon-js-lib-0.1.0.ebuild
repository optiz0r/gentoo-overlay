# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="Sihnon JS Framework"
HOMEPAGE="https://benroberts.net/projects/sihnon-framework/"
SRC_URI="https://github.com/optiz0r/sihnon-js-lib/tarball/release-${PV} -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"

LICENSE="CCPL-Attribution-ShareAlike-NonCommercial-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
USE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	cd "${WORKDIR}"/optiz0r-sihnon-js-lib-*
	S=$(pwd)
}

src_install() {

	insinto "/usr/lib/${PN}"

	doins -r public

}

