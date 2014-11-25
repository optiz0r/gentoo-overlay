# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/g-pypi/g-pypi-0.3.ebuild,v 1.4 2013/01/06 19:58:49 mgorny Exp $

EAPI="4"
PYTHON_DEPEND="2:2.7 3:3.3"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.5 3.0 3.1 3.2"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils eutils

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

PYTHON_MODNAME="pypuppetdb"

src_prepare() {
	distutils_src_prepare
}

src_compile() {
	distutils_src_compile
	use doc && emake -C docs html
}

src_install() {
	distutils_src_install
	use doc && dohtml -r docs/build/html/*
}
