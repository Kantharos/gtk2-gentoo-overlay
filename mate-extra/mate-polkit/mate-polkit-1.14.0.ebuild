# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

GCONF_DEBUG="no"

inherit gnome2 versionator

MATE_BRANCH="$(get_version_component_range 1-2)"

SRC_URI="http://pub.mate-desktop.org/releases/${MATE_BRANCH}/${P}.tar.xz"
DESCRIPTION="A MATE specific DBUS session bus service that is used to bring up authentication dialogs"
HOMEPAGE="https://github.com/mate-desktop/mate-polkit"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="gtk3 +introspection"

RDEPEND=">=dev-libs/glib-2.36:2
	>=sys-auth/polkit-0.102:0[introspection?]
	!gtk3? ( >=x11-libs/gtk+-2.24:2[introspection?]
	x11-libs/gdk-pixbuf:2[introspection?]
	)
	gtk3? ( x11-libs/gtk+:3[introspection?] )
	virtual/libintl:0
	introspection? ( >=dev-libs/gobject-introspection-0.6.2:0 )"

# We call gtkdocize so we need to depend on gtk-doc.
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-1.3:0
	>=dev-util/intltool-0.35:*
	>=mate-base/mate-common-1.10:0
	sys-devel/gettext:*
	virtual/pkgconfig:*
	!<gnome-extra/polkit-gnome-0.102:0"

# Entropy PMS specific. This way we can install the pkg into the build chroots.
ENTROPY_RDEPEND="!lxde-base/lxpolkit"

src_configure() {
	local use_gtk3
	use gtk3 && use_gtk3="${use_gtk3} --with-gtk=3.0"
	use !gtk3 && use_gtk3="${use_gtk3} --with-gtk=2.0"
	gnome2_src_configure \
		--disable-static \
		${use_gtk3} \
		$(use_enable introspection)
}

DOCS="AUTHORS HACKING NEWS README"
