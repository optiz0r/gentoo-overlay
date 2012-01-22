# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="Distributed ripping cluster manager using HandBrake as a backend"
HOMEPAGE="https://benroberts.net/projects/ripping-cluster/"
SRC_URI="https://github.com/optiz0r/ripping-cluster/tarball/release-${PV} -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"

LICENSE="CCPL-Attribution-ShareAlike-NonCommercial-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="webui +worker"

RDEPEND=">=dev-lang/php-5.3
         >=dev-php/smarty-3.0
         >=dev-libs/sihnon-php-lib-1.1.0
		 >=dev-libs/sihnon-js-lib-0.1.0
		 >=dev-php/PEAR-Net_Gearman-0.2.3
		 >=media-video/handbrake-0.9
"
DEPEND="${RDEPEND}"

pkg_setup() {

	enewuser media -1 /sbin/nologin -1 "users"

}

src_prepare() {
	cd "${WORKDIR}"/optiz0r-ripping-cluster-*
	S=$(pwd)
	rm public/scripts/sihnon-js-lib
}

src_install() {

	insinto "/usr/lib/${PN}"
	dodir "${S}"/source

	insinto "/usr/lib/${PN}/source"
	doins -r "${S}/source/lib"

	if use webui; then
		doins -r "${S}"/source/webui

		insinto "/usr/lib/${PN}/public"
		doins -r public/*
		dosym /usr/lib/sihnon-js-lib/public /usr/lib/${PN}/public/scripts/sihnon-js-lib
	fi

	if use worker; then
		doins -r "${S}"/source/worker
	fi

	insinto "/usr/share/${PN}"
	doins -r "${S}"/build/schema
	doins "${S}"/private/{config.php,dbconfig.conf}.dist

	keepdir /etc/ripping-cluster

	newinitd "${S}"/build/ripping-cluster-worker.init-gentoo ripping-cluster-worker
	newconfd "${S}"/build/ripping-cluster-worker.conf-gentoo ripping-cluster-worker

	keepdir /var/log/ripping-cluster
	fowners media /var/log/ripping-cluster

	keepdir /var/run/ripping-cluster
	fowners media /var/run/ripping-cluster

	dodir /var/tmp/ripping-cluster/{cache,config,templates}
	fowners media /var/tmp/ripping-cluster/{cache,config,templates}

}

pkg_postinst() {

	elog "Please now edit config.php and dbconfig.conf."
	elog ""
	elog "Database schemas to setup a new install can be found in:"
	elog "/usr/share/ripping-cluster/schema"
	elog ""
	elog "The daemon will run as the user 'media' by default"
	elog "Edit /etc/conf.d/ripping-cluster-worker to change this."
	elog ""
	elog "Start the daemon with:"
	elog "  /etc/init.d/ripping-cluster-worker start"
	elog "Make the daemon start on boot with:"
	elog "  rc-update add ripping-cluster-worker default"

}

