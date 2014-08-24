EAPI=4
USE_RUBY="ruby18 ruby19 ree18 jruby"

inherit ruby-ng ruby-fakegem

DESCRIPTION="Ruby language binding for GnuPG Made Easy"
HOMEPAGE="https://github.com/ueno/ruby-gpgme"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

each_ruby_configure() {
    ${RUBY} -C ext "${S}/ext/gpgme/extconf.rb" || die "extconf.rb failed"
}

each_ruby_compile() {
    emake -C ext CFLAGS="${CFLAGS} -fPIC" archflag="${LDFLAGS}" || die "emake failed"
    cp "${S}/ext/gpgme_n.so" "${S}/lib" || die
}
