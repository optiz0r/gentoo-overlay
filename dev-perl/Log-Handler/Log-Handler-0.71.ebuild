# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

MODULE_AUTHOR=BLOONIX
MODULE_VERSION=0.71
inherit perl-module

DESCRIPTION="Log messages to several outputs."

LICENSE="&& ( Artistic GPL-1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

SRC_TEST="do"
