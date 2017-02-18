# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/g-pypi/g-pypi-0.3.ebuild,v 1.4 2013/01/06 19:58:49 mgorny Exp $

EAPI="6"
PYTHON_COMPAT=( python{2_6,2_7,3_3} )

inherit distutils-r1 eutils

DESCRIPTION="Python library for working with the PuppetDB API"
HOMEPAGE="https://github.com/puppet-community/pypuppetdb"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="doc test"

DEPEND="
	dev-python/setuptools
	doc? (
		dev-python/sphinx
	)
	test? (
		dev-python/coverage
		dev-python/mock
		dev-python/pytest
		dev-python/coverage
	)
"
RDEPEND="
    dev-python/requests
	virtual/python-unittest2
"

src_prepare() {
	distutils-r1_src_prepare
}

src_compile() {
	distutils-r1_src_compile
	use doc && emake -C docs html
}

src_install() {
	distutils-r1_src_install
	use doc && dohtml -r docs/build/html/*
}
