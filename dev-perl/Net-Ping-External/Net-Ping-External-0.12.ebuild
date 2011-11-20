# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

MODULE_AUTHOR=CHORNY
MODULE_VERSION=0.12
inherit perl-module

DESCRIPTION="Cross-platform interface to ICMP 'ping' utilities"
HOMEPAGE="http://search.cpan.org/~colinm/Net-Ping-External-0.10/External.pm"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

SRC_TEST=do

