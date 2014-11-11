# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ipaddress/ipaddress-0.8.0.ebuild,v 1.2 2012/08/13 22:01:07 flameeyes Exp $

EAPI=4
USE_RUBY="ruby18 ruby19 ree18 jruby"

inherit ruby-fakegem

DESCRIPTION="ORM that maps REST resources to Rubyobjects"
HOMEPAGE="https://github.com/remiprev/her"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

ruby_add_rdepend "dev-ruby/activemodel
 				  dev-ruby/activesupport
				  dev-ruby/faraday
				  dev-ruby/multi_json"
