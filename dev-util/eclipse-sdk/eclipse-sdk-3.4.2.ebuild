# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit java-pkg-2 check-reqs

MY_PV=${PV/_pre/M}
DMF="R-${MY_PV}-200902111700"
MY_A="eclipse-sourceBuild-srcIncluded-${MY_PV}.zip"
S=${WORKDIR}

DESCRIPTION="Eclipse SDK"
HOMEPAGE="http://www.eclipse.org/eclipse/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${MY_A}"

LICENSE="EPL-1.0"
SLOT="3.4"
KEYWORDS="~amd64"
IUSE="doc source"

CDEPEND=">=dev-java/swt-${PV}:${SLOT}
	>=dev-java/ant-1.7.0
	>=dev-java/ant-core-1.7.0
	>=dev-java/ant-eclipse-ecj-${PV}:${SLOT}
	>=dev-java/asm-3.1:3
	>=dev-java/commons-el-1.0
	>=dev-java/commons-logging-1.0.4
	>=dev-java/icu4j-3.8.1:0
	>=dev-java/jsch-0.1.37
	>=dev-java/junit-3.8.2:0
	dev-java/junit:4
	>=dev-java/lucene-1.9.1:1.9
	>=dev-java/lucene-analyzers-1.9.1:1.9
	>=dev-java/sat4j-core-2.0.3:2
	>=dev-java/sat4j-pseudo-2.0.3:2
	dev-java/tomcat-servlet-api:2.4"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"
DEPEND="${CDEPEND}
	app-arch/unzip
	app-arch/zip
	>=virtual/jdk-1.6"

ALL_WS='carbon gtk motif photon wpf'
ALL_OS='aix hpux linux macosx qnx solaris win32'
ALL_ARCH='ia64 PA_RISC ppc s390 s390x sparc x86 x86_64'

pkg_setup() {
	ws='gtk'
	if use x86 ; then os='linux' ; arch='x86'
	elif use amd64 ; then os='linux' ; arch='x86_64'
	fi

	java-pkg-2_pkg_setup

	CHECKREQS_MEMORY="512"
	check_reqs

	if use doc ; then
		ewarn "Having the 'doc' USE flag enabled greatly increases the build time."
		ewarn "You might want to disable it for ${PN} if you don't need it."
	fi

	CLASSPATH=$(java-pkg_getjars --with-dependencies "ant-eclipse-ecj:${SLOT}")
}

src_prepare() {
	java-pkg_jar-from "eclipse-ecj:${SLOT}"

	ebegin 'Removing plugins of irrelevant platforms'
	local remove=" ${ALL_WS[@]} ${ALL_OS[@]} ${ALL_ARCH[@]} "
	remove=${remove/ ${ws} / } ; remove=${remove/ ${os} / } ; remove=${remove/ ${arch} / }
	remove=${remove# } ; remove=${remove% } ; remove=${remove// /'\|'}
	find \( -type d -o -name '*.xml' \) \
			! -regex '.*[./]\(net\|update\.core\.'"${os}"'\)\([./].*\|\)' \
			-regex '.*[./]\('"${remove}"'\)\([./].*\|\)' -prune -exec rm -rf {} +
	eclipse_delete-plugins '.*[./]\('"${remove}"'\)\([./].*\|\)'
	eend

	ebegin 'Removing bundled binaries'
	find -type f \( -name '*.so' -o -name 'eclipse' \) -delete
	eend

	ebegin 'Unbundling dependencies'
	eclipse_unbundle-dir plugins/org.apache.ant_* ant-core,ant-nodeps lib
	eclipse_unbundle-dir plugins/org.eclipse.swt."${ws}.${os}.${arch}"_*.jar swt:${SLOT}
	eclipse_unbundle-dir plugins/org.junit_* junit
	eclipse_unbundle-dir plugins/org.junit4 junit:4
	eclipse_unbundle-jar plugins/com.ibm.icu_*.jar icu4j
	eclipse_unbundle-jar plugins/com.jcraft.jsch_*.jar jsch
	eclipse_unbundle-jar plugins/javax.servlet_*.jar tomcat-servlet-api:2.4 servlet-api
	eclipse_unbundle-jar plugins/javax.servlet.jsp_*.jar tomcat-servlet-api:2.4 jsp-api
	eclipse_unbundle-jar plugins/org.apache.commons.el_*.jar commons-el
	eclipse_unbundle-jar plugins/org.apache.commons.logging_*.jar commons-logging
	#eclipse_unbundle-jar plugins/org.apache.jasper_*.jar tomcat-jasper
	eclipse_unbundle-jar plugins/org.apache.lucene_*.jar lucene:1.9
	eclipse_unbundle-jar plugins/org.apache.lucene.analysis_*.jar lucene-analyzers:1.9
	#eclipse_unbundle-jar plugins/org.mortbay.jetty_*.jar jetty
	eclipse_unbundle-jar plugins/org.objectweb.asm_*.jar asm:3
	eclipse_unbundle-jar plugins/org.sat4j.core_*.jar sat4j-core:2
	eclipse_unbundle-jar plugins/org.sat4j.pb_*.jar sat4j-pseudo:2
	eend

	if use doc ; then
		# No need to keep unpacking and repacking stuff
		sed -e '/<antcall target="install\.eclipse/d' \
				-e '/<move .*-old"/,/<delete .*-old/d' \
				-e 's/\(java\b.*\bjar="\).*\(\${launcher}\)/\1${plugin.destination}\/\2/' \
				-i build.xml || die
		sed_xml_element 'pathconvert\|delete\|copy' \
				-e '/property="launcher"/s/\(<fileset dir=\)"[^"]*"/\1"${plugin.destination}"/' \
				-e '/\${buildDirectory}\/eclipse/d' \
				-i build.xml || die
	else
		ebegin 'Removing documentation plugins'
		rm -rf plugins/*.doc{,.*}
		eclipse_delete-plugins '.*\.doc\([./].*\|\)'
		sed_xml_element 'antcall' -e '/target="build\.doc\.plugins"/d' -i build.xml || die
		eend
	fi

	if ! use source ; then
		ebegin 'Removing source features and plugins'
		rm -rf {features,plugins}/*.source{,_*}
		eclipse_delete-plugins '.*\.source\(_[0-9].*\|\/\|\)'
		eend
	fi

	ebegin 'Preparing build system'
	# Disable compiler warnings
	find -name 'build.xml' -exec sed -e 's/<javac\b/<javac nowarn="true"/' -i {} +
	# Fix OSGi plugin classpath
	sed -e '/<path id="@dot\.classpath">/a<pathelement path="'"$(java-config --runtime)"'"/>' \
			-i plugins/org.eclipse.osgi/build.xml || die
	# Skip final archiving phase
	sed -e '/<exec executable="tar" dir="${assemblyTempDir}">/,/<delete dir="${assemblyTempDir}"\/>/d' \
			-i {assemble,package}.*.xml || die
	eend
}

src_compile() {
	local java_home=$(java-config --jdk-home)

	# Compile Eclipse SDK
	CLASSPATH=${CLASSPATH} ant insertBuildId compile || die 'ant compile failed'

	# Compile Equinox native launcher
	chmod +x "features/org.eclipse.equinox.executable/library/${ws}/build.sh"
	"features/org.eclipse.equinox.executable/library/${ws}/build.sh" -java "${java_home}" \
		|| die 'equinox native launcher build failed'
	ln "features/org.eclipse.equinox.executable/library/${ws}/eclipse" \
			"features/org.eclipse.equinox.executable/bin/${ws}/${os}/${arch}/" \
		|| die 'ln equinox native launcher failed'
	ln "features/org.eclipse.equinox.executable/library/${ws}"/eclipse*.so \
			"plugins/org.eclipse.equinox.launcher.${ws}.${os}.${arch}/" &&
	ln "features/org.eclipse.equinox.executable/library/${ws}"/eclipse*.so \
			"plugins/org.eclipse.equinox.launcher/fragments/org.eclipse.equinox.launcher.${ws}.${os}.${arch}/" \
		|| die 'ln equinox native library failed'

	# Compile liblocalfile
	emake -C "plugins/org.eclipse.core.filesystem/natives/unix/${os}" \
			JAVA_HOME="${java_home}" || die 'emake liblocalfile failed'
	ln "plugins/org.eclipse.core.filesystem/natives/unix/${os}/liblocalfile_1_0_0.so" \
			"plugins/org.eclipse.core.filesystem.${os}.${arch}/os/${os}/${arch}/" \
		|| die 'ln liblocalfile failed'

	# Compile libupdate
	ant -buildfile "plugins/org.eclipse.update.core.${os}/src/build.xml" \
		|| die 'ant build libupdate failed'

	# Package everything up
	ant -DinstallWs="${ws}" -DinstallOs="${os}" -DinstallArch="${arch}" install \
		|| die 'ant install failed'

	# Generate P2 repository
	$(java-config --java) \
			-jar tmp/eclipse/plugins/org.eclipse.equinox.launcher_*.jar \
			-data workspace \
			-application org.eclipse.equinox.p2.metadata.generator.EclipseGenerator \
			-source "${S}/tmp/eclipse" \
			-metadataRepository "file:${S}/tmp/eclipse/repo" \
			-metadataRepositoryName 'Gentoo Portage' \
			-artifactRepository "file:${S}/tmp/eclipse/repo" \
			-artifactRepositoryName 'Gentoo Portage' \
			-publishArtifacts \
			-root 'Gentoo Eclipse SDK' -rootVersion "${PV%_*}" \
			-flavor tooling \
		|| die 'P2 repository generation failed'

	# Disable Internet update sites
	sed -e '/^repositories\/http:/ s/\(enabled=\)true/\1false/' \
			-i tmp/eclipse/configuration/.settings/org.eclipse.equinox.p2.*.prefs || die
}

src_install() {
	local destdir="/usr/$(get_libdir)/eclipse-${SLOT}"

	# Copy root files
	insinto "${destdir}"
	doins -r features/org.eclipse.platform/rootfiles/{.eclipseproduct,*}

	# Install Eclipse SDK with P2
	$(java-config --java) \
			-Declipse.p2.data.area="file:${D}${destdir}/p2" \
			-jar tmp/eclipse/plugins/org.eclipse.equinox.launcher_*.jar \
			-data workspace \
			-application org.eclipse.equinox.p2.director.app.application \
			-metadataRepository "file:${S}/tmp/eclipse/repo" \
			-artifactRepository "file:${S}/tmp/eclipse/repo" \
			-installIU 'Gentoo Eclipse SDK' -version "${PV%_*}" \
			-destination "${D}${destdir}" \
			-profile SDKProfile \
			-profileProperties 'org.eclipse.update.install.features=true' \
			-bundlepool "${D}${destdir}" \
			-p2.ws "${ws}" -p2.os "${os}" -p2.arch "${arch}" \
			-roaming \
		|| die 'P2 installation failed'

	# Java doesn't know about symlinks
	find plugins -type l -name '*.jar' |
		while read -r link ; do
			ref=$(readlink "${link}") ; link=${link#plugins/}
			ln -sf "${ref}" "$(echo "${D}${destdir}/plugins/${link%%/*}"*)/${link#*/}" || die
		done

	# Install Gentoo wrapper and config
	dobin "${FILESDIR}/${SLOT}/eclipse-${SLOT}"
	insinto /etc/
	doins "${FILESDIR}/${SLOT}/eclipserc-${SLOT}"

	# Create desktop entry
	newicon "features/org.eclipse.equinox.executable/bin/${ws}/${os}/${arch}/icon.xpm" \
			"eclipse-${SLOT}.xpm" || die
	make_desktop_entry "eclipse-${SLOT}" "Eclipse ${MY_PV}" "eclipse-${SLOT}.xpm" || die
}

# Replaces the bundled jars in plugin dir ${1} with links to the jars from
# java-config package ${2}. If ${3} is given, the jars are linked in ${1}/${3}.
eclipse_unbundle-dir() {
	local bundle=${S}/${1} package=${2} into=${3}
	local basename=$(basename "${bundle}")
	local barename=${basename%_*}

	if [[ -d "${bundle}" ]] ; then
		pushd "${bundle}" > /dev/null || die
		einfo "  ${barename} => ${package}"

		rm -rf "../${barename}.source${basename#${barename}}"*
		eclipse_delete-plugins ".*${barename//./\.}\.source.*"

		local classpath=$(manifest_get META-INF/MANIFEST.MF 'Bundle-ClassPath')
		manifest_delete META-INF/MANIFEST.MF 'Name\|SHA1-Digest'
		rm -f ${classpath//,/ } META-INF/ECLIPSEF.{RSA,SF}
		java-pkg_jar-from ${into:+--into "${into}"} "${package}"
		popd > /dev/null
	fi
}

# Extracts plugin jar ${1} and updates its manifest to reference the jars of
# java-config package ${2}.
eclipse_unbundle-jar() {
	local bundle=${S}/${1} package=${2}
	local basename=$(basename "${bundle}" .jar)
	local barename=${basename%_*}

	pushd "$(dirname "${bundle}")" > /dev/null || die
	if [[ -f "${basename}.jar" ]] ; then
		einfo "  ${barename} => ${package}"

		rm -rf "${barename}.source${basename#${barename}}"*
		eclipse_delete-plugins ".*${barename//./\.}\.source.*"

		mkdir "${basename}" && cd "${basename}" || die
		$(java-config --jar) -xf "../${basename}.jar" \
				META-INF/MANIFEST.MF {feature,fragment,plugin}.{properties,xml} || die

		local classpath=$(java-pkg_getjars "${package}")
		[[ ${classpath} ]] || die "java-pkg_getjars ${package} failed"
		CLASSPATH="${CLASSPATH}:${classpath}"
		manifest_replace META-INF/MANIFEST.MF 'Bundle-ClassPath' \
				"external:${classpath//:/,external:}"
		manifest_delete META-INF/MANIFEST.MF 'Name\|SHA1-Digest'
		sed_xml_element 'plugin' -e '/id="'"${barename//./\.}"'"/s/unpack="false"//' \
				-i "${S}"/features/*/feature.xml || die
		eclipse_replace-pathelement "${basename//./\.}" "${classpath////\/}"

		rm "../${basename}.jar" || die
		sed_xml_element 'copy' \
				-e '/\bfile=".*'"${basename//./\.}"'/{
					s/<copy/<copydir/;s/\.jar//g;s/\bfile=/src=/;s/\btofile=/dest=/}' \
				-i "${S}"/package.*.xml || die
	fi
	popd > /dev/null
}

# Replaces Ant path elements that match ${1} with ${2}.
eclipse_replace-pathelement() {
	local from=${1} to=${2}
	sed -e '/<pathelement path="/s/\([":;]\)[^":;]*\('"${from}"'\)[^":;]*\([":;]\)/\1'"${to}"'\3/' \
			-i "${S}"/{,features/*/,plugins/*/}build.xml \
		|| die 'eclipse_replace-pathelement failed'
}

# Removes Ant commands that reference plugins matching ${1}.
eclipse_delete-plugins() {
	sed_xml_element 'ant' -e '/dir="'"${1}"'"/d' -i "${S}"/features/*/build.xml &&
	sed_xml_element 'includes\|plugin' -e '/id="'"${1}"'"/d' -i "${S}"/features/*/feature.xml &&
	sed_xml_element 'customGather\|antcall' -e '/="'"${1}"'"/d' -i "${S}"/assemble.*.xml &&
	sed_xml_element 'copy\|antcall' -e '/="'"${1}"'"/d' -i "${S}"/package.*.xml \
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
