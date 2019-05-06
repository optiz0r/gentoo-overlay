# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ipaddress/ipaddress-0.8.0.ebuild,v 1.2 2012/08/13 22:01:07 flameeyes Exp $

EAPI=4
USE_RUBY="ruby22 ruby23 ruby24"

RUBY_FAKEGEM_EXTRAINSTALL="VERSION"

inherit ruby-fakegem eutils

DESCRIPTION="A framework for bundlers, used by librarian-puppet"
HOMEPAGE="https://github.com/carlossg/librarian"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RUBY_PATCHES=( "${FILESDIR}/${P}-git-silent.patch" )

ruby_add_rdepend "dev-ruby/thor"
