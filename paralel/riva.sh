#!/usr/bin/env bash
git clone -q https://github.com/fabianonline/telegram.sh telegram
	TELEGRAM=telegram/telegram
	KERNEL_NAME="GREENFORCE"
	TELEGRAM_ID=${chat_id}
	TELEGRAM_TOKEN=${token}
	export TELEGRAM_TOKEN
	export KERNEL_TYPE
	export ARCH=arm64
	export SUBARCH=arm64
	export KBUILD_BUILD_USER=MhmmdFadlyas
	export KBUILD_BUILD_HOST=GF-LaB
tg_channelcast() {
    "${TELEGRAM}" -c "${TELEGRAM_ID}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}
clean_build() {
rm -rf out ${ZIP_DIR} ${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME} ${TEMP}/*.log
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
KERNEL_DIR="$(pwd)"
mkdir $KERNEL_DIR/5A
TEMP="$KERNEL_DIR/5A"
KERNEL_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"
KERNEL_DEVICE="Xiaomi Redmi 5A"
KERNEL_CONFIG="riva_defconfig"
CODENAME_DEVICE="riva"
TOOLCHAIN_DIR="/root/toolchain"
ZIP_DIR="$KERNEL_DIR/${CODENAME_DEVICE}"
git clone -j32 --depth=1 https://github.com/Mhmmdfas/anykernel3 -b ${CODENAME_DEVICE} ${CODENAME_DEVICE}
echo "clone ${CODENAME_DEVICE}"
main_uts() {
KERNEL_UTS_VERSION=$(cat ${KERNEL_DIR}/out/include/generated/compile.h | grep UTS_VERSION | cut -d '"' -f2)
}
push_log() {
	curl -F document=@$(echo ${TEMP}/*.log) "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
	-F chat_id="${fadlyas}"
}
push() {
	curl -F document=@$(echo ${ZIP_DIR}/*.zip) "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
	-F chat_id="${TELEGRAM_ID}" \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="Build took $(($DIFF2 / 60)) minute(s) and $(($DIFF2 % 60)) second(s). <b>For ${KERNEL_DEVICE}</b> [ <code>$KERNEL_UTS_VERSION</code> ]"
}
DATE2=$(TZ=Asia/Jakarta date +'%H%M-%d%m%y')
BUILD_START2=$(date +"%s")
if [[ "$PARSE_BRANCH" == "HMP" ]];
then
	KERNEL_TYPE=HMP
	export $KERNEL_TYPE
	TOOLCHAIN_DIRNAME="clang"
	export $TOOLCHAIN_DIRNAME
	make_clangaosp
elif [[ "$PARSE_BRANCH" == "EAS" ]];
then
	KERNEL_TYPE=EAS
	export $KERNEL_TYPE
	make_gcc
elif [[ "$PARSE_BRANCH" == "aosp/android-3.18" ]];
then
	KERNEL_TYPE=PURE-CAF
	export $KERNEL_TYPE
	TOOLCHAIN_DIRNAME="proton"
	export $TOOLCHAIN_DIRNAME
	make_proton
elif [[ ! "$KERNEL_TYPE" ]];
then
	KERNEL_TYPE=TEST
	echo "Maybe i'm on test-build/scripts right now!"
	export $KERNEL_TYPE
	TOOLCHAIN_DIRNAME="proton"
	export $TOOLCHAIN_DIRNAME
	make_proton
fi
main_uts
BUILD_END2=$(date +"%s")
DIFF2=$((${BUILD_END2} - ${BUILD_START2}))
if [[ ! -f "${KERNEL_IMG}" ]];
then
	push_log
	exit 1;
fi
cd ${ZIP_DIR}
cp ${KERNEL_IMG} ${ZIP_DIR}/zImage
zip -r9q ${KERNEL_NAME}-${KERNEL_TYPE}-${CODENAME_DEVICE}-${DATE2}.zip * -x .git README.md LICENCE
push
push_log
cd ~/project/
clean_build
