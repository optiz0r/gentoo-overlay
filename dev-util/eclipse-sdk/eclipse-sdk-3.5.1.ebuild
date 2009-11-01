# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit java-pkg-2 check-reqs

BUILD_ID="R3_5_1"
S="${WORKDIR}/eclipse-build-R0_3_0"

DESCRIPTION="Eclipse SDK"
HOMEPAGE="http://www.eclipse.org/eclipse/"
SRC_URI="http://download.eclipse.org/technology/linuxtools/eclipse-build/eclipse-${BUILD_ID}-fetched-src.tar.bz2
	http://download.eclipse.org/technology/linuxtools/eclipse-build/eclipse-build-R0_3_0.tar.gz"

LICENSE="EPL-1.0"
SLOT="3.5"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

CDEPEND=">=dev-java/swt-${PV}:${SLOT}
	>=dev-java/ant-1.7.1
	>=dev-java/ant-core-1.7.1
	>=dev-java/asm-3.1:3
	>=dev-java/commons-codec-1.3
	>=dev-java/commons-el-1.0
	>=dev-java/commons-httpclient-3.1:3
	>=dev-java/commons-logging-1.0.4
	>=dev-java/hamcrest-core-1.1
	>=dev-java/icu4j-4.0.1:4
	>=dev-java/jsch-0.1.41
	>=dev-java/junit-3.8.2:0
	>=dev-java/junit-4.5:4
	>=dev-java/lucene-1.9.1:1.9
	>=dev-java/lucene-analyzers-1.9.1:1.9
	>=dev-java/sat4j-core-2.1:2
	>=dev-java/sat4j-pseudo-2.1:2
	dev-java/tomcat-servlet-api:2.5"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"
DEPEND="${CDEPEND}
	app-arch/unzip
	app-arch/zip
	>=virtual/jdk-1.6"

ALL_WS='carbon cocoa gtk motif photon wpf'
ALL_OS='aix hpux linux macosx qnx solaris win32'
ALL_ARCH='ia64 PA_RISC ppc s390 s390x sparc x86 x86_64'

buildDir="${S}/build/eclipse-${BUILD_ID}-fetched-src"

pkg_setup() {
	ws='gtk'
	if use x86 ; then os='linux' ; arch='x86'
	elif use amd64 ; then os='linux' ; arch='x86_64'
	fi

	java-pkg-2_pkg_setup

	if use doc ; then
		ewarn "Having the 'doc' USE flag enabled greatly increases the build time."
		ewarn "You might want to disable it for ${PN} if you don't need it."
	fi
}

src_unpack() {
	CHECKREQS_MEMORY="1536"
	CHECKREQS_DISK_BUILD="3072"
	check_reqs

	unpack eclipse-build-R0_3_0.tar.gz
	ln -s "${DISTDIR}/eclipse-${BUILD_ID}-fetched-src.tar.bz2" "${S}"/ || die

	# fix up hardcoded buildId
	sed -e 's/^\(buildId=\).*$/\1'"${BUILD_ID}"'/' -i "${S}"/{,pde}build.properties || die
	sed -e 's/I20090611-1540/'"${BUILD_ID}"'/g' -i "${S}"/pdebuild.xml || die

	( cd "${S}" && ant init ) || die
	# remove init target since we've already run it
	sed -e 's/depends="init"//' -i "${S}"/build.xml || die
}

src_prepare() {
	if use amd64 ; then
		sed -e 's/^buildArch=x86$/\0_64/' -i {,pde}build.properties || die
	fi

	# fix up hardcoded paths
	local JAVA_HOME=$(java-config --jdk-home)
	sed -e 's|/usr/lib/jvm/java/jre/lib/rt\.jar:.*$|'"$(java-config --runtime)"'|' \
			-i {,pde}build.properties || die
	sed -e 's|javaHome="[^"]*"|javaHome="'"${JAVA_HOME}"'"|' \
			-i "${buildDir}"/features/org.eclipse.equinox.executable/library/gtk/build.sh || die
	sed -e 's|~/vm/sun142|'"${JAVA_HOME}"'|' \
			-i "${buildDir}"/plugins/org.eclipse.core.filesystem/natives/unix/linux/Makefile || die

	# fix up hardcoded versions and add new ECF plugin to build paths
	sed -e 's/20090604-1131/20090831-1906/' -e 's/20090415/20090822/' \
			-e '/org\.eclipse\.ecf\.filetransfer/{p;s/\(filetransfer_3\.0\.\)0/provider.\11/}' \
			-i "${buildDir}"/plugins/*/build.xml || die

	# skip compilation of SWT native libraries (we use the system-installed copies)
	sed_xml_element 'ant\|patch' -e '/swt/d' -i build.xml || die

	ebegin 'Removing plugins of irrelevant platforms'
	local remove=" ${ALL_WS[@]} ${ALL_OS[@]} ${ALL_ARCH[@]} "
	remove=${remove/ ${ws} / } ; remove=${remove/ ${os} / } ; remove=${remove/ ${arch} / }
	remove=${remove# } ; remove=${remove% } ; remove=${remove// /'\|'}
	find \( -type d -o -name '*.xml' \) \
			! -regex '.*[./]\(net\|update\.core\.'"${os}"'\)\([./].*\|\)' \
			-regex '.*[./]\('"${remove}"'\)\([./].*\|\)' -prune -exec rm -rf {} +
	eclipse_delete-plugins '.*\.\('"${remove}"'\)\(\..*\|\)'
	eend

	if ! use doc ; then
		ebegin 'Removing documentation plugins'
		rm -rf "${buildDir}"/plugins/*.doc{,.*}
		eclipse_delete-plugins '.*\.doc\(\..*\|\)'
		eend
	fi

	if ! use source ; then
		ebegin 'Removing source plugins'
		rm -rf "${buildDir}"/plugins/*.source{,_*}
		eclipse_delete-plugins '.*\.source'
		eend
	fi
}

src_compile() {
	ANT_OPTS='-Xmx512M' ./build.sh || die
}

src_install() {
	local destDir="/usr/$(get_libdir)/eclipse-${SLOT}"

	insinto "${destDir}"
	shopt -s dotglob
	doins -r "${buildDir}"/installation/*
	shopt -u dotglob
	chmod +x "${D}${destDir}"/eclipse
	rm "${D}${destDir}"/libcairo-swt.so  # use the system-installed SWT libraries

	ebegin 'Unbundling dependencies'
	pushd "${D}${destDir}" > /dev/null || die
	eclipse_unbundle-dir plugins/org.apache.ant_* ant-core,ant-nodeps lib
	eclipse_unbundle-dir plugins/org.junit_* junit
	eclipse_unbundle-dir plugins/org.junit4_* junit:4
	eclipse_unbundle-jar plugins/com.ibm.icu_*.jar icu4j:4
	eclipse_unbundle-jar plugins/com.jcraft.jsch_*.jar jsch
	eclipse_unbundle-jar plugins/javax.servlet_*.jar tomcat-servlet-api:2.5 servlet-api
	eclipse_unbundle-jar plugins/javax.servlet.jsp_*.jar tomcat-servlet-api:2.5 jsp-api
	eclipse_unbundle-jar plugins/org.apache.commons.codec_*.jar commons-codec
	eclipse_unbundle-jar plugins/org.apache.commons.el_*.jar commons-el
	eclipse_unbundle-jar plugins/org.apache.commons.httpclient_*.jar commons-httpclient:3
	eclipse_unbundle-jar plugins/org.apache.commons.logging_*.jar commons-logging
	#eclipse_unbundle-jar plugins/org.apache.jasper_*.jar tomcat-jasper
	eclipse_unbundle-jar plugins/org.apache.lucene_*.jar lucene:1.9
	eclipse_unbundle-jar plugins/org.apache.lucene.analysis_*.jar lucene-analyzers:1.9
	eclipse_unbundle-jar plugins/org.eclipse.swt."${ws}.${os}.${arch}"_*.jar swt:${SLOT}
	eclipse_unbundle-jar plugins/org.hamcrest.core_*.jar hamcrest-core
	#eclipse_unbundle-jar plugins/org.mortbay.jetty_*.jar jetty
	eclipse_unbundle-jar plugins/org.objectweb.asm_*.jar asm:3
	eclipse_unbundle-jar plugins/org.sat4j.core_*.jar sat4j-core:2
	eclipse_unbundle-jar plugins/org.sat4j.pb_*.jar sat4j-pseudo:2
	popd > /dev/null
	eend

	# Install Gentoo wrapper and config
	dobin "${FILESDIR}/${SLOT}/eclipse-${SLOT}"
	insinto /etc
	doins "${FILESDIR}/${SLOT}/eclipserc-${SLOT}"

	# Create desktop entry
	make_desktop_entry "eclipse-${SLOT}" "Eclipse ${PV}" "${destDir}/icon.xpm" || die
}

# Replaces the bundled jars in plugin dir ${1} with links to the jars from
# java-config package ${2}. If ${3} is given, the jars are linked in ${1}/${3}.
eclipse_unbundle-dir() {
	local bundle=${1} package=${2} into=${3}
	local basename=$(basename "${bundle}")
	local barename=${basename%_*}

	if [[ -d "${bundle}" ]] ; then
		einfo "  ${barename} => ${package}"

		pushd "${bundle}" > /dev/null || die
		local classpath=$(manifest_get META-INF/MANIFEST.MF 'Bundle-ClassPath')
		manifest_delete META-INF/MANIFEST.MF 'Name\|SHA1-Digest'
		rm -f ${classpath//,/ } META-INF/ECLIPSEF.{RSA,SF}
		java-pkg_jar-from ${into:+--into "${into}"} "${package}"
		popd > /dev/null
	fi
}

# Extracts plugin jar ${1}, updates its manifest to reference the jars of
# java-config package ${2}, and repacks it.
eclipse_unbundle-jar() {
	local bundle=${1} package=${2} jar=${3}
	local basename=$(basename "${bundle}" .jar)
	local barename=${basename%_*}

	if [[ -f "${bundle}" ]] ; then
		einfo "  ${barename} => ${package}"

		bundle=$(readlink -f "${bundle}")
		mkdir "${T}/${basename}" && pushd "${T}/${basename}" > /dev/null || die
		$(java-config --jar) -xf "${bundle}" \
				META-INF/MANIFEST.MF {feature,fragment,plugin}.{properties,xml} || die
		rm "${bundle}" || die

		local classpath=$(java-pkg_getjars "${package}")
		[[ ${classpath} ]] || die "java-pkg_getjars ${package} failed"
		[[ ${jar} ]] && classpath=$(echo "${classpath}" | grep -o '[^:]*/'"${jar}"'\.jar')
		manifest_replace META-INF/MANIFEST.MF 'Bundle-ClassPath' \
				"external:${classpath//:/,external:}"
		manifest_delete META-INF/MANIFEST.MF 'Name\|SHA1-Digest'

		$(java-config --jar) -cfm "${bundle}" META-INF/MANIFEST.MF . || die
		popd > /dev/null
		rm -r "${T}/${basename}" || die
	fi
}

# Removes feature.xml references to plugins matching ${1}.
eclipse_delete-plugins() {
	sed_xml_element 'includes\|plugin' -e '/id="'"${1}"'"/d' \
			-i "${buildDir}"/features/*/feature.xml "${S}"/eclipse-build-feature/feature.xml \
		|| die 'eclipse_delete-plugins failed'
}

# Prints the first value from manifest file ${1} whose key matches regex ${2},
# unfolding as necessary.
manifest_get() {
	sed -n -e '/^\('"${2}"'\): /{h;:A;$bB;n;/^ /!bB;H;bA};d;:B;g;s/^[^:]*: //;s/\n //g;p;q' "${1}" \
		|| die 'manifest_get failed'
}

# Deletes values from manifest file ${1} whose keys match regex ${2}, taking
# into account folding.
manifest_delete() {
	sed -n -e ':A;/^\('"${2}"'\): /{:B;n;/^ /!{bA};bB};p' -i "${1}" \
		|| die 'manifest_delete failed'
}

# Replaces the value for key ${2} in the first section of manifest file ${1}
# with ${3}, or adds the key-value pair to that section if the key was absent.
manifest_replace() {
	LC_ALL='C' awk -v key="${2}" -v val="${3}" '
function fold(s,  o, l, r) {
	o = 2 ; l = length(s) - 1 ; r = substr(s, 1, 1)
	while (l > 69) { r = r substr(s, o, 69) "\n " ; o += 69 ; l -= 69 }
	return r substr(s, o)
}
BEGIN { FS = ": " }
f { print ; next }
i { if ($0 !~ "^ ") { f = 1 ; print } ; next }
$1 == key { print fold(key FS val) ; i = 1 ; next }
/^\r?$/ { print fold(key FS val) ; print ; f = 1 ; next }
{ print }
END { if (!f) { print fold(key FS val) } }
' "${1}" > "${1}-" && mv "${1}"{-,} || die 'manifest_replace failed'
}

# Executes sed over each XML element with a name matching ${1}, rather than
# over each line. The entire element (and its children) may be removed with the
# 'd' command, or they may be edited using all the usual sed foo. Basically,
# the script argument will be executed only for elements matching ${1}, and the
# sed pattern space will consist of the entire element, including any nested
# elements. Note that this is not perfect and requires no more than one XML
# element per line to be reliable.
sed_xml_element() {
	local elem="${1}" ; shift
	sed -e '/<\('"${elem}"'\)\([> \t]\|$\)/{:_1;/>/!{N;b_1};/\/>/b_3' \
			-e ':_2;/<\/\('"${elem}"'\)>/!{N;b_2};b_3};b;:_3' "${@}"
}
