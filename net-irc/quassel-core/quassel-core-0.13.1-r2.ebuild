# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake xdg-utils pax-utils systemd

MY_PN=${PN/-core}

DESCRIPTION="Qt/KDE IRC client - the \"core\" (server) component"
HOMEPAGE="https://quassel-irc.org/"
MY_P=${MY_PN}-${PV/_/-}
SRC_URI="https://quassel-irc.org/pub/${MY_P}.tar.bz2"
KEYWORDS="~amd64 ~x86"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
SLOT="0"
IUSE="crypt ldap postgres +ssl syslog"

SERVER_RDEPEND="
	acct-group/quassel
	acct-user/quassel
	dev-qt/qtscript:5
	crypt? ( app-crypt/qca:2[ssl] )
	ldap? ( net-nds/openldap )
	postgres? ( dev-qt/qtsql:5[postgres] )
	!postgres? ( dev-qt/qtsql:5[sqlite] dev-db/sqlite:3[threadsafe(+),-secure-delete] )
	syslog? ( virtual/logger )
"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtnetwork:5[ssl?]
	sys-libs/zlib
	${SERVER_RDEPEND}
"
DEPEND="
	${RDEPEND}
	!net-irc/quassel-core-bin
	kde-frameworks/extra-cmake-modules
	"

PATCHES=( "${FILESDIR}/quassel-${PV}-qt5.14.patch" )

DOCS=( AUTHORS ChangeLog README.md )

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(
		# $(cmake_use_find_package dbus dbusmenu-qt5)
		#$(cmake_use_find_package dbus Qt5DBus)
		-DWITH_KDE=OFF
		-DWITH_OXYGEN_ICONS=OFF
		-DWANT_MONO=OFF
		-DWITH_LDAP=$(usex ldap)

		-DUSE_QT4=OFF
		-DUSE_QT5=ON
		-DUSE_CCACHE=OFF
		-DCMAKE_SKIP_RPATH=ON
		-DEMBED_DATA=OFF
		-DWITH_WEBKIT=OFF
		-DWITH_BUNDLED_ICONS=OFF
		-DWANT_CORE=ON
		CMAKE_DISABLE_FIND_PACKAGE_LibsnoreQt5=ON
		-DWITH_WEBENGINE=OFF
		-DWANT_QTCLIENT=OFF
	)

	#if use server || use monolithic; then
	mycmakeargs+=(  $(cmake_use_find_package crypt QCA2-QT5) )
	#fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	rm -rf "${ED}"/usr/share/quassel/translations
	rm -rf "${ED}"/usr/share/quassel
	rm -ff "${ED}"/usr/share/pixmaps/quassel.png
	rm -ff "${ED}"/usr/share/icons/hicolor/48x48/apps/quassel.png

	# server stuff

	# needs PAX marking wrt bug#346255
	pax-mark m "${ED}/usr/bin/quasselcore"

	# init scripts & systemd unit
	newinitd "${FILESDIR}"/quasselcore.init-r1 quasselcore
	newconfd "${FILESDIR}"/quasselcore.conf-r1 quasselcore
	systemd_dounit "${FILESDIR}"/quasselcore.service

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}/quassel.logrotate" quassel
}

pkg_postinst() {
	einfo "If you want to generate SSL certificate remember to run:"
	einfo "	emerge --config =${CATEGORY}/${PF}"

	# server || monolithic
	einfo "Quassel can use net-misc/oidentd package if installed on your system."
	einfo "Consider installing it if you want to run quassel within identd daemon."
}

pkg_config() {
	if use ssl; then
		# generate the pem file only when it does not already exist
		QUASSEL_DIR=/var/lib/${PN}
		if [ ! -f "${QUASSEL_DIR}/quasselCert.pem" ]; then
			einfo "Generating QUASSEL SSL certificate to: \"${QUASSEL_DIR}/quasselCert.pem\""
			openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
				-keyout "${QUASSEL_DIR}/quasselCert.pem" \
				-out "${QUASSEL_DIR}/quasselCert.pem"
			# permissions for the key
			chown ${PN}:${PN} "${QUASSEL_DIR}/quasselCert.pem"
			chmod 400 "${QUASSEL_DIR}/quasselCert.pem"
		else
			einfo "Certificate \"${QUASSEL_DIR}/quasselCert.pem\" already exists."
			einfo "Remove it if you want to create new one."
		fi
	fi
}
