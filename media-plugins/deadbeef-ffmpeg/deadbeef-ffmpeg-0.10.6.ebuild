# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/ffmpeg/ffmpeg-0.10.6.ebuild,v 1.13 2013/03/14 15:07:22 ago Exp $

EAPI="4"
MY_P="${P#deadbeef-}"

inherit eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="Complete solution to record, convert and stream audio and video. Includes libavcodec."
HOMEPAGE="http://ffmpeg.org/"
SRC_URI="http://ffmpeg.org/releases/${MY_P/_/-}.tar.bz2"

LICENSE="GPL-2  GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux"
IUSE="bindist cpudetection gnutls +hardcoded-tables pic static-libs threads +zlib"

# String for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
CPU_FEATURES="3dnow:amd3dnow 3dnowext:amd3dnowext altivec mmx mmxext:mmx2 ssse3 neon"

for i in ${CPU_FEATURES}; do
	IUSE="${IUSE} ${i%:*}"
done

RDEPEND="
	media-libs/opencore-amr
	gnutls? ( >=net-libs/gnutls-2.12.16 )
	zlib? ( sys-libs/zlib )
	!media-video/qt-faststart
	!media-libs/libpostproc
	!media-video/deadbeef-ffmpeg"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	gnutls? ( virtual/pkgconfig )
	mmx? ( dev-lang/yasm )
"
S=${WORKDIR}/${MY_P/_/-}

QA_TEXTRELS="usr/lib/libpostproc-deadbeef.so.52.0.100
usr/lib/libavfilter-deadbeef.so.2.61.100
usr/lib/libavutil-deadbeef.so.51.35.100
usr/lib/libavformat-deadbeef.so.53.32.100
usr/lib/libavcodec-deadbeef.so.53.61.100
usr/lib/libswresample-deadbeef.so.0.6.100"

QA_PRESTRIPPED="usr/lib/libpostproc-deadbeef.so.52.0.100
usr/lib/libavfilter-deadbeef.so.2.61.100
usr/lib/libavutil-deadbeef.so.51.35.100
usr/lib/libavformat-deadbeef.so.53.32.100
usr/lib/libavcodec-deadbeef.so.53.61.100
usr/lib/libswresample-deadbeef.so.0.6.100"

src_configure() {
	use cpudetection && myconf="${myconf} --enable-runtime-cpudetect"
	use gnutls && myconf="${myconf} --enable-gnutls"

	# Threads; we only support pthread for now but ffmpeg supports more
	use threads && myconf="${myconf} --enable-pthreads"

	# CPU features
	for i in ${CPU_FEATURES}; do
		use ${i%:*} || myconf="${myconf} --disable-${i#*:}"
	done
	if use pic ; then
		myconf="${myconf} --enable-pic"
		# disable asm code if PIC is required
		# as the provided asm decidedly is not PIC for x86.
		use x86 && myconf="${myconf} --disable-asm"
	fi
	[[ ${ABI} == "x32" ]] && myconf+=" --disable-asm" #427004

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	for i in $(get-flag march) $(get-flag mcpu) $(get-flag mtune) ; do
		[ "${i}" = "native" ] && i="host" # bug #273421
		myconf="${myconf} --cpu=${i}"
		break
	done

	# Mandatory configuration
	myconf="
		--disable-debug
		--disable-vaapi
		--enable-gpl
		--disable-doc
		--disable-ffplay
		--disable-ffprobe
		--disable-ffserver
		--disable-avdevice
		--disable-ffmpeg
		--disable-swscale
		--disable-network
		--disable-swscale-alpha
		--disable-vdpau
		--disable-dxva2
		--disable-hwaccels
		--disable-encoders
		--disable-muxers
		--disable-indevs
		--disable-outdevs
		--disable-devices
		--disable-filters
		--disable-parsers
		--enable-parser=ac3
		--enable-demuxer=ac3
		--disable-bsfs
		--disable-bzlib
		--disable-protocols
		--disable-decoders
		--enable-decoder=wmapro
		--enable-decoder=wmav1
		--enable-decoder=wmav2
		--enable-decoder=wmavoice
		--enable-decoder=alac
		--enable-decoder=ac3
		--enable-decoder=amrnb
		--disable-demuxers
		--enable-demuxer=asf
		--enable-demuxer=alac
		--enable-demuxer=oma
		--enable-demuxer=ac3
		--enable-demuxer=mov
		--enable-demuxer=amr
		--enable-libopencore-amrnb
		--enable-version3
		${myconf}"

	# cross compile support
	if tc-is-cross-compiler ; then
		myconf="${myconf} --enable-cross-compile --arch=$(tc-arch-kernel) --cross-prefix=${CHOST}-"
		case ${CHOST} in
			*freebsd*)
				myconf="${myconf} --target-os=freebsd"
				;;
			mingw32*)
				myconf="${myconf} --target-os=mingw32"
				;;
			*linux*)
				myconf="${myconf} --target-os=linux"
				;;
		esac
	fi

	# Misc stuff
	use hardcoded-tables && myconf="${myconf} --enable-hardcoded-tables"

	cd "${S}"
	./configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--shlibdir="${EPREFIX}/usr/$(get_libdir)" \
		--incdir="${EPREFIX}/usr/include/${PN}" \
		--build-suffix=-deadbeef \
		--enable-shared \
		--cc="$(tc-getCC)" \
		--cxx="$(tc-getCXX)" \
		--ar="$(tc-getAR)" \
		--optflags="${CFLAGS}" \
		--extra-cflags="${CFLAGS}" \
		--extra-cxxflags="${CXXFLAGS}" \
		$(use_enable static-libs static) \
		${myconf} || die
}

src_install() {
	emake DESTDIR="${D}" install
	rm -rf "${D}"/usr/bin
	rm -rf "${D}"/usr/share
	for pc in $(find "${D}/usr/$(get_libdir)/pkgconfig" -type f);do
		sed -e 's| libavutil | deadbeef-libavutil |;s| libavcodec | deadbeef-libavcodec |;s|||' -i "${pc}"
		mv "${pc}" "${D}/usr/$(get_libdir)/pkgconfig/deadbeef-${pc##*/}"
	done
}
