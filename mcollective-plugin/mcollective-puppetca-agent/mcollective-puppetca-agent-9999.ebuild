# Copyright 2013 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI="4"

inherit git-2

DESCRIPTION="MCollective plug-in that manages the puppet CA."
HOMEPAGE="https://github.com/puppetlabs/mcollective-puppetca-agent"
EGIT_PROJECT="mcollective-puppetca-agent"
EGIT_REPO_URI="https://github.com/optiz0r/mcollective-puppetca-agent.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""


src_install() {
	# Remove these spec/ files as they will collide with other packages.
	for d in spec/spec.opts spec/spec_helper.rb; do
		[[ -f ${d} ]] && rm ${d}
	done

	# Install any directories.
	insinto /usr/share/mcollective/plugins/mcollective
	for d in agent aggregate application data spec util validator; do
		[[ -d ${d} ]] && doins -r ${d}
	done

	# Install any files.
	for d in LICENSE LICENSE.md ChangeLog CHANGELOG CHANGELOG.md ReadMe readme README.md; do
		[[ -f ${d} ]] && dodoc ${d}
	done
}
