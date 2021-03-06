# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python3_{4,5,6} )

inherit python-r1 autotools eutils git-r3

MY_PN="${PN/d/D}"

DESCRIPTION="An implementation of the MPRIS 2 interface as a client for MPD"
HOMEPAGE="http://github.com/eonpatapon/mpDris2"
EGIT_REPO_URI="https://github.com/eonpatapon/mpDris2.git"
#EGIT_REPO_URI="git://github.com/eonpatapon/mpDris2.git"
#EGIT_BRANCH="python-3"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

LANGS="fr nl"

for lang in ${LANGS}; do
	IUSE+=" l10n_${lang}"
done

#DEPEND=">=dev-lang/python-2.4
DEPEND="python_targets_python3_4? ( dev-lang/python:3.4 )
	python_targets_python3_5? ( dev-lang/python:3.5 )
	python_targets_python3_6? ( dev-lang/python:3.6 )
	>=dev-python/dbus-python-0.80
	>=dev-python/pygobject-2.14
	>=dev-python/python-mpd-0.3.0"

DOCS="AUTHORS COPYING INSTALL NEWS README README.md"

src_prepare() {
	eautoreconf
}

_clean_up_locales() {
	einfo "Cleaning up locales..."
	for lang in ${LANGS}; do
		use "l10n_${lang}" && {
			einfo "- keeping ${lang}"
			continue
		}
		rm -Rf "${ED}"/usr/share/locale/"${lang}" || die
	done
}

src_install() {
	emake install DESTDIR="${D}" || die "Failed to install"

	_clean_up_locales

}
