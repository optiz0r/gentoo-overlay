EAPI=5
USE_RUBY="ruby22 ruby23"

inherit ruby-fakegem

DESCRIPTION="A pluggable and extendable data lookup system http://jerakia.io"
HOMEPAGE="https://github.com/crayfishx/jerakia"

DEPEND="
	|| ( app-admin/puppet-agent app-admin/puppet )
	dev-ruby/rspec
	dev-ruby/mocha
	dev-ruby/webmock-rspec-helper
"

RDEPEND="${DEPEND}
	dev-ruby/deep_merge
	dev-ruby/dm-sqlite-adapter
	dev-ruby/faster_require
	dev-ruby/lookup_http
	dev-ruby/msgpack
	dev-ruby/rack
	dev-ruby/rake
	dev-ruby/sinatra
	dev-ruby/thor
	>=www-servers/thin-1.6.5
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
