EAPI=5
USE_RUBY="ruby22 ruby23"

inherit ruby-fakegem

DESCRIPTION="A tool designed to speedup library loading (startup time) in Ruby by caching library locations"
HOMEPAGE="http://github.com/rdp/faster_require"

DEPEND=""

RDEPEND="${DEPEND}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
