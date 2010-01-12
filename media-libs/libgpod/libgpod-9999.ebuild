# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils cvs

DESCRIPTION="Shared library to access the contents of an iPod"
HOMEPAGE="http://www.gtkpod.org/libgpod.html"
LICENSE="LGPL-2"
SRC_URI=""
ECVS_SERVER="gtkpod.cvs.sourceforge.net:/cvsroot/gtkpod"
ECVS_MODULE="libgpod"
S="${WORKDIR}/${ECVS_MODULE}"

KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="gtk python debug"
SLOT="0"

# make sure binaries are not stripped
# for debugging purposes
if use debug; then
	if ! has nostrip ${FEATURES}; then
		FEATURES="${FEATURES} nostrip"
	fi
fi

RDEPEND="!media-libs/libgpod
		>=dev-libs/glib-2.4
                gtk? ( >=x11-libs/gtk+-2 )
                python? ( >=dev-lang/python-2.3
                                >=dev-python/eyeD3-0.6.6 )"
DEPEND="${RDEPEND}
                sys-devel/autoconf
                sys-devel/libtool
                >=dev-util/intltool-0.2.9"

src_compile() {
	local myconf=""

        myconf="${myconf}
                $(use_enable gtk gdk-pixbuf)
		$(use_with python)"

 	./autogen.sh ${myconf} || die "autogen.sh failure"

	emake
}

src_install() {
	make DESTDIR=${D} install || die "install failed"
}
