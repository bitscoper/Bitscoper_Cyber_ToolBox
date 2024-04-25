# By Abdullah As-Sadeed

pkgname=Bitscoper_Cyber_ToolBox
pkgver=8.0.2
pkgrel=1
pkgdesc="A Flutter application consisting of TCP Port Scanner, Route Tracer, File Hash Calculator, String Encoder, Series URI Crawler, DNS Record Retriever, and WHOIS Retriever."
arch=('x86_64')
url="https://github.com/bitscoper/Bitscoper_Cyber_ToolBox/"
license=('GPL3')
depends=('gtk3')
makedepends=('jq' 'unzip')
source=("Linux_x64_Executable.zip::$(curl -s https://api.github.com/repos/bitscoper/Bitscoper_Cyber_ToolBox/releases/latest | jq -r '.assets[] | select(.name | contains("Linux_x64_Executable.zip")) | .browser_download_url' || echo 'File not found!')")
sha256sums=('SKIP')

package() {
  install -dm755 "$pkgdir/opt/$pkgname/"
  install -Dm755 "$srcdir/Linux_x64_Executable/Bitscoper_Cyber_ToolBox" "$pkgdir/opt/$pkgname/"

  install -dm755 "$pkgdir/opt/$pkgname/lib/"
  cp -r "$srcdir/Linux_x64_Executable/lib/"* "$pkgdir/opt/$pkgname/lib/"

  install -dm755 "$pkgdir/opt/$pkgname/data/"
  cp -r "$srcdir/Linux_x64_Executable/data/"* "$pkgdir/opt/$pkgname/data/"

  install -dm755 "$pkgdir/usr/bin"
  ln -s "/opt/$pkgname/Bitscoper_Cyber_ToolBox" "$pkgdir/usr/bin/Bitscoper_Cyber_ToolBox"
}