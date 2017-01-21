# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3
DESCRIPTION="neat and simple webcam grabbing app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/"
EGIT_REPO_URI="https://github.com/fsphil/fswebcam.git"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="media-libs/gd"
RDEPEND="${DEPEND}"
