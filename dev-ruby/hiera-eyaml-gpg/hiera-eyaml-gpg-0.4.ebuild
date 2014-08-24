#Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ipaddress/ipaddress-0.8.0.ebuild,v 1.2 2012/08/13 22:01:07 flameeyes Exp $

EAPI=4
USE_RUBY="ruby18 ruby19 ree18 jruby"

inherit ruby-fakegem

DESCRIPTION="A GPG backend for hiera-eyaml"
HOMEPAGE="https://github.com/sihil/hiera-eyaml-gpg"

DEPEND=">=dev-ruby/hiera-eyaml-1.3.8
        >=dev-ruby/gpgme-2.0.0"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
