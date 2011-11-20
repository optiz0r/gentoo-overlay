# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

PYTHON_DEPEND="2"
PYTHON_USE_WITH="sqlite"

inherit base eutils python systemd

if [[ ${PV} == *9999 ]]; then
	EHG_REPO_URI="http://bitbucket.org/spoob/pyload/"
	inherit mercurial
else
	SRC_URI="http://get.pyload.org/static/${PN}-src-v${PV}.zip"
	KEYWORDS="~amd64 ~x86"
fi
DESCRIPTION="A fast, lightweight and full featured download manager for many One-Click-Hosters."
HOMEPAGE="http://www.pyload.org"
LICENSE="GPL-3"
SLOT="0"
IUSE="captcha clicknload container curl qt4 rar ssl systemd"

DEPEND="app-arch/unzip"

RDEPEND="${DEPEND}
	dev-python/beautifulsoup
	dev-python/beaker
	dev-python/feedparser
	dev-python/simplejson
	captcha? (
		dev-python/imaging
		app-text/tesseract
	)
	clicknload? (
	|| (
		dev-lang/spidermonkey
		dev-java/rhino
	)
	)
	container? ( dev-python/pycrypto )
	curl? ( dev-python/pycurl )
	qt4? ( dev-python/PyQt4	)
	rar? ( app-arch/unrar )
	ssl? (
		dev-python/pycrypto
		dev-python/pyopenssl
	)"
#clicknload? ( || ( ... ossp-js pyv8 ) )

S=${WORKDIR}/${PN}

PYLOAD_WORKDIR=/var/lib/pyload # (/var/lib/ in lack of a better place)

pkg_setup() {
	python_pkg_setup

#	enewuser pyload -1 -1 ${PYLOAD_WORKDIR}
}

src_unpack() {
	if [[ ${PV} == *9999 ]]; then
		mercurial_src_unpack
	else
		default
		#base_src_unpack
	fi
}

src_prepare() {
	# fix pidfile
	sed -i -e 's:self.pidfile = "pyload.pid":self.pidfile = "/var/run/pyload.pid":' ${S}/pyLoadCore.py

	# fix workdir
	echo ${PYLOAD_WORKDIR} > ${S}/module/config/configdir

	# replace some shipped dependencies with the system libraries
	rm -r \
		${S}/module/lib/BeautifulSoup.py \
		${S}/module/lib/beaker \
		${S}/module/lib/feedparser.py \
		${S}/module/lib/simplejson

	find ${S}/module/ -name "*.py" -type f -print0 | xargs -0 \
	sed -i \
		-e 's:from module.lib.BeautifulSoup:from BeautifulSoup:' \
		-e 's:from module.lib \(import feedparser.*\):\1:' \
		-e 's:from module.lib.simplejson:from simplejson:' \
		#${S}/module/**/*.py # globbing not working -> find


	if ! use qt4; then
		rm -r ${S}/module/gui
	fi
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	insinto /opt/${PN}
	doins -r ${S}/locale
	doins -r ${S}/module
	doins -r ${S}/scripts
	doins ${S}/pyLoadCore.py
	doins ${S}/pyLoadCli.py

	make_wrapper pyloadcli /opt/${PN}/pyLoadCli.py

	if use qt4; then
		doins -r ${S}/icons
		make_wrapper pyloadgui /opt/${PN}/pyLoadGui.py
	fi

	dodir ${PYLOAD_WORKDIR}
	# install default config
	if ! test -f ${PYLOAD_WORKDIR}/pyload.conf; then
		cp ${S}/module/config/default.conf ${D}/${PYLOAD_WORKDIR}/pyload.conf
	fi

	#fix tmpdir
	ln -sf /tmp ${D}/${PYLOAD_WORKDIR}/tmp

	newinitd ${FILESDIR}/pyload pyload

	if use systemd; then
		systemd_dounit ${FILESDIR}/pyload.service
	fi
}

pkg_postinst() {
	if use ssl && ! test -f ${PYLOAD_WORKDIR}/ssl.key; then
		einfo "If you want to use pyLoad's XML-RPC via SSL have to create a key in pyloads work directory"
		echo
		einfo "cd ${PYLOAD_WORKDIR}"
		einfo "openssl genrsa 1024 > ssl.key"
		einfo "openssl req -new -key ssl.key -out ssl.csr"
		einfo "openssl req -days 36500 -x509 -key ssl.key -in ssl.csr > ssl.crt"
	fi
}
