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
export KERNEL_TYPE

	git clone -q https://github.com/fabianonline/telegram.sh telegram
	echo -c "clone Telegram.."

TELEGRAM=telegram/telegram
TELEGRAM_ID=${chat_id}
TELEGRAM_TOKEN=${token}
export TELEGRAM_TOKEN

# Github Env Vars
KERNEL_NAME="GREENFORCE"
UNIFIED="Xiaomi Redmi 4A & 5A"
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
COMMIT_POINT="$(git log --pretty=format:'%h: %s by %an' -1)"
TOOLCHAIN_DIR="/root/toolchain"

if [ "$PARSE_BRANCH" == "HMP" ];
then
	KERNEL_TYPE=HMP
	export $KERNEL_TYPE
	STICKER="CAADBQADeQEAAn1Cwy71MK7Ir5t0PhYE"
	export $STICKER
	TOOLCHAIN_DIRNAME="clang"
	export $TOOLCHAIN_DIRNAME
elif [ "$PARSE_BRANCH" == "EAS" ];
then
	KERNEL_TYPE=EAS
	export $KERNEL_TYPE
	STICKER="CAADBQADIwEAAn1Cwy5pf2It72fNXBYE"
	export $STICKER
elif [ "$PARSE_BRANCH" == "aosp/android-3.18" ];
then
	KERNEL_TYPE=PURE-CAF
	export $KERNEL_TYPE
	STICKER="CAADBQADfAEAAn1Cwy6aGpFrL8EcbRYE"
	export $STICKER
	TOOLCHAIN_DIRNAME="proton"
	export $TOOLCHAIN_DIRNAME
elif [ ! "$KERNEL_TYPE" ];
then
	KERNEL_TYPE=TEST
	echo -e "Maybe i'm on test-build/scripts right now!"
	export $KERNEL_TYPE
	STICKER="CAADBQADPwEAAn1Cwy4LGnCzWtePdRYE"
	export $STICKER
	TOOLCHAIN_DIRNAME="proton"
	export $TOOLCHAIN_DIRNAME
fi

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

tg_sendstick

if [ "$KERNEL_TYPE" == "EAS" ];
then
	tg_channelcast "<b>${KERNEL_NAME} ${KERNEL_TYPE} build is available</b>!" \
				"<b>Device :</b><code> ${UNIFIED} </code>" \
				"<b>Branch :</b><code> ${PARSE_BRANCH} </code>" \
				"<b>Toolchain :</b><code> $(${TOOLCHAIN_DIR}/gcc/bin/aarch64-linux-android-gcc --version | head -n 1 ) </code>" \
				"<b>Latest commit :</b><code> ${COMMIT_POINT} </code>"
elif [ ! "$KERNEL_TYPE" == "EAS" ];
then
	tg_channelcast "<b>${KERNEL_NAME} ${KERNEL_TYPE} build is available</b>!" \
			"<b>Device :</b><code> ${UNIFIED} </code>" \
			"<b>Branch :</b><code> ${PARSE_BRANCH} </code>" \
			"<b>Toolchain :</b><code> $(${TOOLCHAIN_DIR}/${TOOLCHAIN_DIRNAME}/bin/clang --version | head -n 1 | perl -pe 's/\(https.*?\)//gs' | sed -e 's/  */ /g') </code>" \
			"<b>Latest commit :</b><code> ${COMMIT_POINT} </code>"
fi
tg_channelcast "<b>Build Started At </b><code>$(TZ=Asia/Jakarta date)</code>"
