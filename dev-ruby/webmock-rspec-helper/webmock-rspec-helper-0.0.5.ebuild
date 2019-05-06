EAPI=5
USE_RUBY="ruby22 ruby23 ruby24"

inherit ruby-fakegem

DESCRIPTION="Easily define WebMock stubs that point to JSON files"
HOMEPAGE="http://github.com/lserman/webmock-rspec-helper"

DEPEND=""

RDEPEND="${DEPEND}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

all_ruby_install() {
	all_fakegem_install

	# File collision with dev-ruby/rspec
	rm ${D}usr/bin/rspec || die
}
