EAPI=5
USE_RUBY="ruby21 ruby22 ruby23"

inherit ruby-fakegem

DESCRIPTION="Web UI + RESTful API for Oxidized"
HOMEPAGE="https://github.com/ytti/oxidized-web"

DEPEND=""
RDEPEND="${DEPEND}
	>=dev-ruby/oxidized-0.19
	>=dev-ruby/puma-2.8
	>=dev-ruby/sinatra-1.4.6
	>=dev-ruby/sinatra-contrib-1.4.6
	>=dev-ruby/haml-4.0
	>=dev-ruby/sass-3.3
	>=dev-ruby/emk-sinatra-url-for-0.2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
