# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

inherit gnome2 versionator

MATE_BRANCH="$(get_version_component_range 1-2)"

SRC_URI="http://pub.mate-desktop.org/releases/${MATE_BRANCH}/${P}.tar.xz"
DESCRIPTION="Utilities for the MATE desktop"
HOMEPAGE="http://mate-desktop.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="X applet gtk3 ipv6 test"

RDEPEND="app-text/rarian:0
	dev-libs/atk:0
	>=dev-libs/glib-2.20:2
	>=gnome-base/libgtop-2.12:2=
	sys-libs/zlib:0
	!gtk3? ( >=x11-libs/gtk+-2.24:2
			>=media-libs/libcanberra-0.4:0[gtk]
			)

	x11-libs/gdk-pixbuf:2
	gtk3? ( x11-libs/gtk+:3
			>=media-libs/libcanberra-0.4:0[gtk3]
	)
	x11-libs/cairo:0
	x11-libs/libICE:0
	x11-libs/libSM:0
	x11-libs/libX11:0
	x11-libs/libXext:0
	x11-libs/pango:0
	applet? ( >=mate-base/mate-panel-1.12:0 )"

#applet? ( >=mate-base/mate-panel-1.12:0[gtk3?] )

DEPEND="${RDEPEND}
	>=app-text/scrollkeeper-dtd-1:1.0
	app-text/yelp-tools:0
	>=dev-util/intltool-0.40:*
	>=mate-base/mate-common-1.12:0
	x11-proto/xextproto:0
	sys-devel/gettext:*
	virtual/pkgconfig:*"

src_prepare() {
	gnome2_src_prepare

	# Remove -D.*DISABLE_DEPRECATED cflagss
	# This method is kinda prone to breakage. Recheck carefully with next bump.
	# bug 339074
	LC_ALL=C find . -iname 'Makefile.am' -exec \
		sed -e '/-D[A-Z_]*DISABLE_DEPRECATED/d' -i {} + || die

	# Do Makefile.in after Makefile.am to avoid automake maintainer-mode
	LC_ALL=C find . -iname 'Makefile.in' -exec \
		sed -e '/-D[A-Z_]*DISABLE_DEPRECATED/d' -i {} + || die

	if ! use test; then
		sed -e 's/ tests//' -i logview/Makefile.{am,in} || die
	fi

	# Fix up desktop files.
	LC_ALL=C find . -iname '*.desktop.in*' -exec \
		sed -e 's/Categories\(.*\)MATE/Categories\1X-MATE/' -i {} + || die
}

src_configure() {
	local use_gtk3
	if ! use debug; then
		use_gtk3="${use_gtk3} --enable-debug=minimum"
	fi

	use gtk3 && use_gtk3="${use_gtk3} --with-gtk=3.0"
	use !gtk3 && use_gtk3="${use_gtk3} --with-gtk=2.0"
	gnome2_src_configure \
		$(use_enable applet gdict-applet) \
		$(use_enable ipv6) \
		$(use_with X x) \
		--disable-maintainer-flags \
		--enable-zlib \
		${use_gtk3}
}

DOCS="AUTHORS ChangeLog NEWS README THANKS"
