# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils
inherit git

DESCRIPTION="Distributed ripping cluster manager using HandBrake as a backend"
HOMEPAGE="http://wiki.sihnon.net/index.php/Ripping-cluster"

EGIT_REPO_URI="https://git.sihnon.net/public/handbrake-cluster-webui.git"
EGIT_COMMIT="release-${PV}"

LICENSE="bsd"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="webui +worker"

RDEPEND=">=dev-lang/php-5.3
         >=dev-php/smarty-3.0
         >=dev-libs/sihnon-php-lib-0.2.5
		 >=dev-php/PEAR-Net_Gearman-0.2.3
		 >=media-video/handbrake-0.9
"
DEPEND="${RDEPEND}"

pkg_setup() {

	enewuser media -1 /sbin/nologin -1 "users"

}

src_unpack() {

	git_src_unpack
	git_branch

}

src_install() {

	insinto "/usr/lib/${PN}"

	doins -r source

	if use webui; then
		doins -r webui
	fi

	if use worker; then
		doins -r worker
	fi

	keepdir /etc/ripping-cluster
	insinto /etc/ripping-cluster
	doins private/{config.php,dbconfig.conf}.dist

	newinitd ${FILESDIR}/ripping-cluster-worker.initd ripping-cluster-worker
	newconfd ${FILESDIR}/ripping-cluster-worker.confd ripping-cluster-worker

	keepdir /var/log/ripping-cluster

	fowners media /var/log/ripping-cluster

}

pkg_postinst() {

	elog "Please now edit config.php and dbconfig.conf."
	elog ""
	elog "This version does not come with database init scripts yet:"
	elog "You will need to create the database manually with this version"
	elog ""
	elog "The daemon will run as the user 'media' by default"
	elog "Edit /etc/conf.d/ripping-cluster-worker to change this."
	elog ""
	elog "Start the daemon with:"
	elog "  /etc/init.d/ripping-cluster-worker start"
	elog "Make the daemon start on boot with:"
	elog "  rc-update add ripping-cluster-worker default"

}

