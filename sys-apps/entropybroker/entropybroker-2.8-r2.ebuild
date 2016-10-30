# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="infrastructure for distributing entropy"
HOMEPAGE="http://www.vanheusden.com/entropybroker/"
SRC_URI="http://www.vanheusden.com/entropybroker/eb-${PV}.tgz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa comscire png smartcard usb"

DEPEND="dev-libs/crypto++
		media-libs/gd[xpm,truetype]
		media-libs/libpng
		sys-libs/zlib
		alsa? ( media-libs/alsa-lib )
		comscire? ( dev-embedded/libftdi )
		smartcard? ( sys-apps/pcsc-lite )
		usb? ( virtual/libusb )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/eb-${PV}

eb_use() {
	use ${1} && echo -n ${2}
}

src_compile() {
	emake \
		$(eb_use alsa      eb_server_audio) \
		$(eb_use comscire  eb_server_ComScire_R2000KU) \
		$(eb_use png       plot) \
		$(eb_use smartcard eb_server_smartcard) \
		$(eb_use usb       eb_server_usb) \
		everything

		#$(eb_use v4l       eb_server_v4l)
}
