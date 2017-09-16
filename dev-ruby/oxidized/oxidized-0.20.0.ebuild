EAPI=5
USE_RUBY="ruby22 ruby23"

inherit ruby-fakegem

DESCRIPTION="Configuration backup software (IOS, JunOS)"
HOMEPAGE="https://github.com/ytti/oxidized"

DEPEND="dev-ruby/pry
	>=dev-ruby/bundler-0.1
	>=dev-ruby/rake-10.0
	>=dev-ruby/minitest-5.8
	>=dev-ruby/mocha-1.1"

RDEPEND="${DEPEND}
	>=dev-ruby/asetus-0.1
	>=dev-ruby/slop-0.1
	>=dev-ruby/net-ssh-3.0.2
	>=dev-ruby/rugged-0.21.4"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
