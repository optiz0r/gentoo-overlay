EAPI=5
USE_RUBY="ruby22 ruby23"

inherit ruby-fakegem

DESCRIPTION="rancid clogin-like script to push configs to devices + library interface to do same"
HOMEPAGE="https://github.com/heruan/oxidized-fetch"

RDEPEND=">=dev-ruby/oxidized-0.2.0
	>=dev-ruby/slop-3.5"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
