# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils
inherit git

DESCRIPTION="Distributed ripping cluster manager using HandBrake as a backend"
HOMEPAGE="http://wiki.sihnon.net/index.php/Ripping-cluster"

EGIT_REPO_URI="https://git.sihnon.net/public/handbrake-cluster-webui.git"
EGIT_BRANCH="release-${PV}"

LICENSE="bsd"
SLOT="0"
KEYWORDS="~amd64"
IUSE="webui worker client"

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {

	git_src_unpack
	git_branch

}

src_install() {

	insinto "/usr/lib/${PN}"
	
	doins -r source

	if use client; then
		doins -r client
	fi

	if use webui; then
		doins -r webui
	fi

	if use worker; then
		doins -r worker
	fi

	insinto /etc
	newins private ripping-cluster

	newinitd build/ripping-cluster-worker.init-gentoo ripping-cluster-worker

}

pkg_postinst() {

	elog "Please now edit config.php and dbconfig.conf."
	elog "You will need to create the database manually with this version"

}

