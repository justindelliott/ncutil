#!/bin/sh

for variant in MacOSX Darwin; do
  lc_variant=`echo $variant | tr "[:upper:]" "[:lower:]"`
  for release in 10_4 10_5; do
    dot_release=`echo $release | sed 's/_/./'`
    echo cp build-$lc_variant-$release/Release/ncutil ncutil-3.3-beta/$variant/$dot_release/ncutil
    cp build-$lc_variant-$release/Release/ncutil ncutil-3.3-beta/$variant/$dot_release/ncutil
  done
done

tar --bzip -cf ncutil-3.3-beta.tar.bz ncutil-3.3-beta

