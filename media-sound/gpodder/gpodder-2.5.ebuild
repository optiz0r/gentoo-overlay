# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND="2"

inherit distutils

if [[ ${PV} == "9999" ]] ; then
	inherit git
	KEYWORDS="~x86 ~amd64 ~amd64-linux ~x86-linux"
	EGIT_REPO_URI="git://repo.or.cz/gpodder.git"
else
	KEYWORDS="x86 amd64 amd64-linux x86-linux"
	SRC_URI="mirror://berlios/${PN}/${P}.tar.gz"
fi

DESCRIPTION="gPodder is a Podcast receiver/catcher written in Python, using GTK."
HOMEPAGE="http://www.gpodder.org"

LICENSE="GPL-3"
SLOT="0"
IUSE="bluetooth dbus examples gtkhtml ipod libnotify mad mtp nls ogg rockbox"

RDEPEND="dev-python/feedparser
  dev-lang/python[sqlite]
  dev-python/pygtk
  dev-python/mygpoclient
  bluetooth? ( net-wireless/gnome-bluetooth )
  dbus? ( dev-python/dbus-python )
  ipod? ( media-libs/libgpod[python]
          || ( mad? ( dev-python/pymad )
		              dev-python/eyeD3 ) )
  mtp? ( dev-python/pymtp )
  ogg? ( media-sound/vorbis-tools )
  libnotify? ( dev-python/notify-python )
  rockbox? ( dev-python/imaging )
  webkit? ( dev-python/pywebkitgtk )"

DEPEND="${RDEPEND}
  dev-util/intltool
  sys-apps/help2man
  dev-python/setuptools"

RESTRICT="test nomirror"
RESTRICT_PYTHON_ABIS="3.*"

src_prepare() {
	if use nls ; then
		# Update translations only when using live ebuild
		if [[ ${PV} == "9999" ]] ; then
			emake messages
		else 
			emake -C data/po
		fi
	fi

	emake data/org.gpodder.service
}

src_install() {
	distutils_src_install

	if use examples ; then
		insinto /usr/share/doc/${PF}/scripts
		doins doc/dev/convert/*
		doins doc/dev/examples/*
		elog "Example scripts to use with gPodder can be found in:"
		elog "  /usr/share/doc/${PF}/scripts"
	fi
}
