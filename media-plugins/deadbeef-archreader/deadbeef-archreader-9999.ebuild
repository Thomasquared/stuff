# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-fb/deadbeef-archreader-9999.ebuild,v 1 2012/09/08 02:11:35 megabaks Exp $

EAPI=4

inherit eutils subversion

DESCRIPTION="Dedbeef plugin for play files directly from RAR, 7z and Gzip archive files"
HOMEPAGE="http://subversion.assembla.com/svn/deadbeef_vfs_archive_reader/"
ESVN_REPO_URI="http://subversion.assembla.com/svn/deadbeef_vfs_archive_reader/trunk/src"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="media-sound/deadbeef
	!media-sound/deadbeef-archreader"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

src_install() {
	insinto /usr/$(get_libdir)/deadbeef
	doins ddb_archive_reader.so
}
