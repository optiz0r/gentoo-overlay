# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_6 )
inherit distutils-r1

DESCRIPTION="Tool for updating puppet environments on puppet masters using librarian-puppet"
HOMEPAGE="https://github.com/optiz0r/puppet-env-manager"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="
	>=dev-python/git-python-2.1
	>=dev-python/lockfile-0.12.2
	dev-python/pyyaml
	dev-python/requests
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-python/mock"

RESTRICT="test"
