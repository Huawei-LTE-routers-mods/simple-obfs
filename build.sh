#!/bin/bash
set -e

export PATH="/home/valdikss/mobile-modem-router/e5372/kernel/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin:$PATH"

mkdir -p installed/huawei/{vfp3,novfp} || true


# Balong Hi6921 V7R11 (E3372h, E5770, E5577, E5573, E8372, E8378, etc) and Hi6930 V7R2 (E3372s, E5373, E5377, E5786, etc)
# softfp, vfpv3-d16 FPU
export CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -O2 -s"

# libev
[ ! -d libev ] && ./autogen.sh && mkdir libev && cd libev && wget http://dist.schmorp.de/libev/Attic/libev-4.33.tar.gz && tar zxf libev-4.33.tar.gz && cd ..
cd libev/libev-4.33
make clean || true
./configure --build=x86_64 --host=arm-linux-gnueabi --target=arm \
 --disable-shared --enable-static \
 --prefix="$PWD/installed/huawei/vfp3"
make "$@"
make install
# Disable -lm ldflag as we're going to link it statically
sed -i 's~-lm~~' installed/huawei/vfp3/lib/libev.la
cd ../..

make clean || true
./configure --build=x86_64 --host=arm-linux-gnueabi --target=arm \
 --disable-ssp --disable-documentation \
 --prefix="$PWD/installed/huawei/vfp3" \
 --with-ev="$PWD/libev/libev-4.33/installed/huawei/vfp3" \
 LIBS="-l:libm_pic.a"
make "$@"
make install

patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/vfp3/bin/obfs-local
patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/vfp3/bin/obfs-server

#exit 0
# Balong Hi6920 V7R1 (E3272, E3276, E5372, etc)
# soft, novfp
export CFLAGS="-march=armv7-a -mfloat-abi=soft -mthumb -O2 -s"

# libev
cd libev/libev-4.33
make clean || true
./configure --build=x86_64 --host=arm-linux-gnueabi --target=arm \
 --disable-shared --enable-static \
 --prefix="$PWD/installed/huawei/novfp"
make "$@"
make install
# Disable -lm ldflag as we're going to link it statically
sed -i 's~-lm~~' installed/huawei/novfp/lib/libev.la
cd ../..

make clean || true
./configure --build=x86_64 --host=arm-linux-gnueabi --target=arm \
 --disable-ssp --disable-documentation \
 --prefix="$PWD/installed/huawei/novfp" \
 --with-ev="$PWD/libev/libev-4.33/installed/huawei/novfp" \
 LIBS="-l:libm_pic.a"
make "$@"
make install

patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/novfp/bin/obfs-local
patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/novfp/bin/obfs-server
