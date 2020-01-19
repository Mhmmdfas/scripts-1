 #
 # Script For Building Android arm64 Kernel
 #
 # Copyright (C) 2019-2020 Muhammad Fadlyas (@Mhmmdfas)
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #	 http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
#!/usr/bin/env bash

export TZ=":Asia/Jakarta"
export USE_CCACHE=1
export CACHE_DIR=~/.ccache
export STICKER

	git clone -q https://github.com/fabianonline/telegram.sh telegram
	echo -c "clone Telegram.."

TELEGRAM=telegram/telegram
TELEGRAM_ID=${chat_id}
TELEGRAM_TOKEN=${token}
export TELEGRAM_TOKEN

tg_channelcast() {
    "${TELEGRAM}" -c "${TELEGRAM_ID}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

tg_sendstick() {
   curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendSticker" \
	-d sticker="${STICKER}" \
	-d chat_id="${TELEGRAM_ID}"
}

main_uts() {
UTS_VER=$(cat ${KERNEL_DIR}/out/include/generated/compile.h | grep UTS_VERSION | cut -d '"' -f2)
}

make_proton() {
	export LD_LIBRARY_PATH="${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME}/bin/../lib:$PATH"
	make -s -C "${KERNEL_DIR}" -j$(nproc) O=out ARCH=arm64 ${KERNEL_CONFIG}
	PATH="${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME}/bin:${PATH}" \
	make -C "${KERNEL_DIR}" -j$(nproc) -> ${TEMP}/riva.log O=out \
                  					ARCH=arm64 \
                  					CC=clang \
							CLANG_TRIPLE=aarch64-linux-gnu- \
							CROSS_COMPILE=aarch64-linux-gnu- \
							CROSS_COMPILE_ARM32=arm-linux-gnueabi-
}

make_clangaosp() {
	export KBUILD_COMPILER_STRING="$(${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME}/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
	make -s -C "${KERNEL_DIR}"-j$(nproc) O=out ARCH=arm64 ${KERNEL_CONFIG}
	PATH="${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME}/bin:${TOOLCHAIN_DIR}/gcc/bin:${TOOLCHAIN_DIR}/gcc32/bin:${PATH}" \
	make -s -C "${KERNEL_DIR}" -j$(nproc) -> ${TEMP}/riva.log O=out \
							ARCH=arm64 \
							CC=clang \
							CLANG_TRIPLE=aarch64-linux-gnu- \
							CROSS_COMPILE=aarch64-linux-android- \
							CROSS_COMPILE_ARM32=arm-linux-androideabi-
}

make_gcc() {
	make -s -C "${KERNEL_DIR}" -j$(nproc) O=out ARCH=arm64 ${KERNEL_CONFIG}
	PATH="${TOOLCHAIN_DIR}/gcc/bin:${TOOLCHAIN_DIR}/gcc32/bin:${PATH}" \
	make -s -C "${KERNEL_DIR}" -j$(nproc) -> ${TEMP}/riva.log O=out \
							ARCH=arm64 \
							CROSS_COMPILE=aarch64-linux-android- \
							CROSS_COMPILE_ARM32=arm-linux-androideabi-
}

function push() {
	curl -F document=@$(echo ${ZIP_DIR}/*.zip) "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
	-F chat_id="${TELEGRAM_ID}" \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). <b>For ${KERNEL_DEVICE}</b> [ <code>$UTS_VER</code> ]"
}

push_log() {
	curl -F document=@$(echo ${TEMP}/*.log) "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
	-F chat_id="${fadlyas}"
}

clean_build() {
	rm -rf out ${ZIP_DIR} ${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME} ${TEMP}/*.log
}

# Miscellaneous env vars
KERNEL_NAME="GREENFORCE"
KERNEL_CONFIG="riva_defconfig"

# Building kernel for ..
KERNEL_DEVICE="Xiaomi Redmi 5A"
CODENAME_DEVICE="riva"

# Idk why you have to make it like this too
KERNEL_DIR="$(pwd)"
TOOLCHAIN_DIR="/root/toolchain"
ZIP_DIR="$KERNEL_DIR/anykernel3"

# Github env vars
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
	export KERNEL_TYPE
	export ARCH=arm64
	export SUBARCH=arm64
	export KBUILD_BUILD_USER=MhmmdFadlyas
	export KBUILD_BUILD_HOST=GF-LaB
	git clone -j32 --depth=1 https://github.com/Mhmmdfas/anykernel3 -b ${CODENAME_DEVICE}

# If you are on paralel build,use this for message to sendcast
UNIFIED="Xiaomi Redmi 4A & 5A"
		
if [ "$PARSE_BRANCH" == "HMP" ];
then
	KERNEL_TYPE=HMP
	export $KERNEL_TYPE
	TOOLCHAIN_DIRNAME="clang"
	export $TOOLCHAIN_DIRNAME
elif [ "$PARSE_BRANCH" == "EAS" ];
then
	KERNEL_TYPE=EAS
	export $KERNEL_TYPE
elif [ "$PARSE_BRANCH" == "aosp/android-3.18" ];
then
	KERNEL_TYPE=PURE-CAF
	export $KERNEL_TYPE
	TOOLCHAIN_DIRNAME="proton"
	export $TOOLCHAIN_DIRNAME
elif [ ! "$KERNEL_TYPE" ];
then
	KERNEL_TYPE=TEST
	echo -e "Maybe i'm on test-build/scripts right now!"
	export $KERNEL_TYPE
	TOOLCHAIN_DIRNAME="proton"
	export $TOOLCHAIN_DIRNAME
fi

# Make sure we know after the kernel is finished building we have to
KERNEL_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"

mkdir $KERNEL_DIR/TEMP
TEMP="$KERNEL_DIR/TEMP"

touch $KERNEL_TYPE
echo -c "oh yes oh yes..ahh..ahh..."

TANGGAL=$(TZ=Asia/Jakarta date +'%H%M-%d%m%y')
DATE='date'
BUILD_START=$(date +"%s")
if [ "$KERNEL_TYPE" == "HMP" ];
then
	make_clangaosp
elif [ "$KERNEL_TYPE" == "EAS" ];
then
	make_gcc
elif [ "$KERNEL_TYPE" == "PURE-CAF" ];
then
	make_proton
elif [ "$KERNEL_TYPE" == "TEST" ];
then
	make_proton
fi
main_uts
BUILD_END=$(date +"%s")
DIFF=$((${BUILD_END} - ${BUILD_START}))

if [[ ! -f "${KERNEL_IMG}" ]];
then
	push_log
	exit 1;
fi
cp ${KERNEL_IMG} ${ZIP_DIR}/zImage
cd ${ZIP_DIR}
zip -r9q ${KERNEL_NAME}-${KERNEL_TYPE}-${CODENAME_DEVICE}-${TANGGAL}.zip * -x .git README.md LICENCE
push
push_log
cd ${KERNEL_DIR}
clean_build
