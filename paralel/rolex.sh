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
	export KBUILD_BUILD_HOST=Mhmmdfas
tg_channelcast() {
    "${TELEGRAM}" -c "${TELEGRAM_ID}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}
sed_template() {
tg_channelcast "<b>${KERNEL_NAME} Build Failed</b>!!" \
		"<b>Compile took :</b> <code>$((${DIFF1} / 60)) minute(s) and $((${DIFF1} % 60)) second(s)</code> <b>before failed!</b>"
}
clean_build() {
rm -rf out telegram ${ZIP_DIR}/zImage ${ZIP_DIR}/*.zip ${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME} ${TEMP}/*.log
}
make_clang() {
	export LD_LIBRARY_PATH="${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME}/bin/../lib:$PATH"
	make -j$(nproc --all) O=out ARCH=arm64 ${KERNEL_CONFIG}
	PATH="${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME}/bin:${PATH}" \
	make -j$(nproc --all) -> ${TEMP}/rolex.log O=out \
                  				ARCH=arm64 \
                  				CC=clang \
						CLANG_TRIPLE=aarch64-linux-gnu- \
						CROSS_COMPILE=aarch64-linux-gnu- \
						CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1| tee ${TEMP}/${TANGGAL}-Log.log
}
make_gcc() {
	make -j$(nproc --all) O=out ARCH=arm64 ${KERNEL_CONFIG}
	PATH="${TOOLCHAIN_DIR}/gcc/bin:${TOOLCHAIN_DIR}/gcc32/bin:${PATH}" \
	make -j$(nproc --all) -> ${TEMP}/rolex.log O=out \
						ARCH=arm64 \
						CROSS_COMPILE=aarch64-linux-android- \
						CROSS_COMPILE_ARM32=arm-linux-androideabi-
}
KERNEL_DIR="$(pwd)"
mkdir $KERNEL_DIR/TEMP
TEMP="$KERNEL_DIR/TEMP"
KERNEL_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"
KERNEL_DEVICE="Xiaomi Redmi 4A"
KERNEL_CONFIG="role_defconfig"
CODENAME_DEVICE="rolex"
TOOLCHAIN_DIR="/root/toolchain"
ZIP_DIR="$KERNEL_DIR/${CODENAME_DEVICE}"
git clone -q -j32 --depth=1 https://github.com/fadlyas07/AnyKernel3-1 ${CODENAME_DEVICE}
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
main_program() {
KERNEL_TOOLCHAIN_VERSION=$(cat ${KERNEL_DIR}/out/include/generated/compile.h | grep LINUX_COMPILER | cut -d '"' -f2)
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
	-F caption="
<b>Compile took :</b> $(($DIFF1 / 60)) minute(s) and $(($DIFF1 % 60)) second(s). [ <code>$KERNEL_UTS_VERSION</code> ] For <b>${KERNEL_DEVICE}</b> ] ★★ <code>${KERNEL_TOOLCHAIN_VERSION}</code> ★★
"
}
# Shuffle Clang-Toolchain
compiler[0]="proton"
compiler[1]="clang"
compiler[2]="nusantara"
randS=$[$RANDOM % ${#compiler[@]}]
compilerS=${compiler[$randS]}
TOOLCHAIN_DIRNAME="${compilerS}"
export $TOOLCHAIN_DIRNAME

if [[ "$PARSE_BRANCH" == "HMP" ]];
then
	KERNEL_TYPE=HMP
	export $KERNEL_TYPE
elif [[ "$PARSE_BRANCH" == "EAS" ]];
then
	KERNEL_TYPE=EAS
	export $KERNEL_TYPE
elif [[ "$PARSE_BRANCH" == "aosp/android-3.18" ]];
then
	KERNEL_TYPE=PURE-CAF
	export $KERNEL_TYPE
elif [[ ! "$KERNEL_TYPE" ]];
then
	KERNEL_TYPE=TEST
	export $KERNEL_TYPE
fi
DATE1=$(TZ=Asia/Jakarta date +'%H%M-%d%m%y')
BUILD_START1=$(date +"%s")
if [[ "$KERNEL_TYPE" == "EAS" ]] || [[ ! "$TOOLCHAIN_DIRNAME" ]]
then
	make_gcc
else
	make_clang
fi
main_program
BUILD_END1=$(date +"%s")
DIFF1=$((${BUILD_END1} - ${BUILD_START1}))
if [[ ! -f "${KERNEL_IMG}" ]];
then
	push_log
    sed_template
	exit 1;
fi
cp ${KERNEL_IMG} ${ZIP_DIR}/zImage
cd ${ZIP_DIR}
zip -r9q ${KERNEL_NAME}-${KERNEL_TYPE}-${CODENAME_DEVICE}-${DATE1}.zip * -x .git README.md LICENCE
cd ..
push
push_log
clean_build
