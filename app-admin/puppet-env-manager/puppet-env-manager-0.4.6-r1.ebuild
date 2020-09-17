# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{6..9} )
inherit distutils-r1

DESCRIPTION="Tool for updating puppet environments on puppet masters using librarian-puppet"
HOMEPAGE="https://github.com/optiz0r/puppet-env-manager"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="
	>=dev-python/GitPython-2.1[${PYTHON_USEDEP}]
	>=dev-python/lockfile-0.12.2[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-python/mock"

RESTRICT="test"
