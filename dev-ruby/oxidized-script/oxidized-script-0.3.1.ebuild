EAPI=5
USE_RUBY="ruby21 ruby22 ruby23"

inherit ruby-fakegem

DESCRIPTION="CLI and LIB for scripting network devices via Oxidized"
HOMEPAGE="https://github.com/ytti/oxidized-script"

DEPEND=">=dev-ruby/oxidized-0.15
	>=dev-ruby/slop-3.5"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
