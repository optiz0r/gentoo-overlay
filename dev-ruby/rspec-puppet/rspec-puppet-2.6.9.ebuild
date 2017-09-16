# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI=5

USE_RUBY="ruby22 ruby23"

RUBY_FAKEGEM_TASK_TEST="none"
RUBY_FAKEGEM_TASK_DOC=""

RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_EXTRAINSTALL="README.md"

inherit ruby-fakegem

DESCRIPTION="RSpec tests for your Puppet manifests"
HOMEPAGE="https://github.com/rodjek/rspec-puppet"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x64-macos ~x86-macos"
RDEPEND="|| ( app-admin/puppet-agent app-admin/puppet )"
DEPEND="${RDEPEND}
dev-ruby/rspec"
