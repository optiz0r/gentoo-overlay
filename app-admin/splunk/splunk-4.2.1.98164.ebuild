# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator

MY_PVR=$(replace_version_separator 3 '-')
MY_PV=$(get_version_component_range 1-3)

DESCRIPTION="The search engine for IT data"
HOMEPAGE="http://www.splunk.com"

REL_URI="http://www.splunk.com/index.php/download_track?wget=true&name=gentoo&file=${MY_PV}/${PN}"
SRC_NAME="${PN}-${MY_PVR}-Linux"

SRC_URI="x86? ( ${REL_URI}/linux/${SRC_NAME}-i686.tgz )
    amd64? ( ${REL_URI}/linux/${SRC_NAME}-x86_64.tgz )"

LICENSE="splunk-eula"
SLOT="0"
KEYWORDS="-* ~x86 ~amd64"
IUSE=""

src_install() {
        insinto /opt/${PN}
        doins -r ${PN}/. || die "Install failed!"
        # Install init script
        doinitd "${FILESDIR}"/splunkd || die "doinitd failed"

        # Adjust permissions on executables
        find "${D}/opt/${PN}/bin" -printf "/opt/${PN}/bin/%P\000" | xargs -0 fperms 755  || die "fperms failed"

}

pkg_postinst() {
        einfo "Creating default configuration to monitor /var/log"
        # Need to start splunk to accept the license and build database
        
        #The following command can possibly block, while waiting on input
        #yes | 
        /opt/${PN}/bin/splunk start --accept-license
        /opt/${PN}/bin/splunk stop

        # I am pretty sure this is a lie
        #elog "A default configuration has been created to monitor /var/log."
        #elog ""

        elog "For more information about Splunk, please visit"
        elog "${HOMEPAGE}/doc/latest"
        elog ""
        elog "To add splunk to your startup scripts"
        elog "run 'rc-update add splunk default'"
}
