# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils
inherit git

DESCRIPTION="Sihnon PHP Framework"
HOMEPAGE="http://wiki.sihnon.net/index.php/Sihnon-php-lib"

EGIT_REPO_URI="https://git.sihnon.net/public/sihnon-php-lib.git"
EGIT_COMMIT="release-${PV}"

LICENSE="bsd"
SLOT="0"
KEYWORDS="~amd64 ~x86"
USE=""

RDEPEND=">=dev-lang/php-5.3"
DEPEND="${RDEPEND}"

src_unpack() {

	git_src_unpack
	git_branch

}

src_install() {

	insinto "/usr/lib/${PN}"

	doins -r source

}

