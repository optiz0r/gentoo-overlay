# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI=5

USE_RUBY="ruby22 ruby23 ruby24"

RUBY_FAKEGEM_TASK_TEST="none"
RUBY_FAKEGEM_TASK_DOC=""

RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_EXTRAINSTALL="README.md"

inherit ruby-fakegem

DESCRIPTION="Provides a testing harness for puppet functions, templates and hieradata"
HOMEPAGE="https://github.com/Accuity/rspec-puppet-utils"

LICENSE="|| ( Ruby GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x64-macos ~x86-macos"
RDEPEND="app-admin/puppet-agent"
DEPEND="${RDEPEND}
dev-ruby/rspec"
