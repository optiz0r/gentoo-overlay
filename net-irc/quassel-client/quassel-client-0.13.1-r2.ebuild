# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake xdg-utils

MY_PN=${PN/-client}

DESCRIPTION="Qt/KDE IRC client supporting a remote daemon for 24/7 connectivity (client only)"
HOMEPAGE="https://quassel-irc.org/"
MY_P=${MY_PN}-${PV/_/-}
SRC_URI="https://quassel-irc.org/pub/${MY_P}.tar.bz2"
KEYWORDS="~amd64 ~x86"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
SLOT="0"
IUSE="bundled-icons crypt +dbus debug kde oxygen snorenotify +ssl urlpreview"

GUI_RDEPEND="
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtwidgets:5
	!bundled-icons? (
			kde-frameworks/breeze-icons:5
			oxygen? ( kde-frameworks/oxygen-icons:5 )
	)
	dbus? (
		>=dev-libs/libdbusmenu-qt-0.9.3_pre20140619
		dev-qt/qtdbus:5
	)
	kde? (
		kde-frameworks/kconfigwidgets:5
		kde-frameworks/kcoreaddons:5
		kde-frameworks/knotifications:5
		kde-frameworks/knotifyconfig:5
		kde-frameworks/ktextwidgets:5
		kde-frameworks/kwidgetsaddons:5
		kde-frameworks/kxmlgui:5
		kde-frameworks/sonnet:5
	)
	snorenotify? ( >=x11-libs/snorenotify-0.7.0 )
	urlpreview? ( dev-qt/qtwebengine:5[widgets] )
"

RDEPEND="
	!net-irc/quassel-common
	sys-libs/zlib
	dev-qt/qtcore:5
	dev-qt/qtnetwork:5[ssl?]
	${GUI_RDEPEND}
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
	kde-frameworks/extra-cmake-modules
"

REQUIRED_USE="
	kde? ( dbus )
"
PATCHES=( "${FILESDIR}/quassel-${PV}-qt5.14.patch" )

src_configure() {
	local mycmakeargs=(
		-DUSE_QT4=OFF
		-DWITH_BUNDLED_ICONS=$(usex bundled-icons)
		$(cmake_use_find_package dbus dbusmenu-qt5)
		$(cmake_use_find_package dbus Qt5DBus)
		-DWITH_KDE=$(usex kde)
		-DWITH_LDAP=OFF
		-DWANT_MONO=OFF
		-DUSE_QT5=ON
		-DUSE_CCACHE=OFF
		-DCMAKE_SKIP_RPATH=ON
		-DEMBED_DATA=OFF
		-DWITH_WEBKIT=OFF
		-DWITH_OXYGEN_ICONS=$(usex oxygen)
		-DWANT_CORE=OFF
		$(cmake_use_find_package snorenotify LibsnoreQt5)
		-DWITH_WEBENGINE=$(usex urlpreview)
		-DWANT_QTCLIENT=ON
	)

	#if use server || use monolithic; then
	#	mycmakeargs+=(  $(cmake_use_find_package crypt QCA2-QT5) )
	#fi

	cmake_src_configure po
}

src_install() {
	cmake_src_install

	rm -rf "${ED}"/usr/lib/debug/usr/bin/quasselclient.debug

	dodoc ChangeLog AUTHORS

	insinto /usr/share/quassel
	doins data/networks.ini

	insinto /usr/share/applications
	doins data/quasselclient.desktop

	# /usr/share/quassel/stylesheets
	for mypath in data/stylesheets/*.qss; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/quassel/stylesheets
			doins "${mypath}"
		fi
	done

	# /usr/share/quassel/scripts
	for mypath in data/scripts/*; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/quassel/scripts
			doins "${mypath}"
		fi
	done

	# /usr/share/quassel/translations
	#for mypath in "${CMAKE_BUILD_DIR}"/po/*.qm; do
	#	insinto /usr/share/quassel/translations
	#	doins "${mypath}"
	#done

	use kde && doins data/quassel.notifyrc
}

pkg_postinst() {
	elog "To make use of quasselclient, install server, too."
	elog "It is provided by net-irc/quassel-core and net-irc/quassel-core-bin."
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
