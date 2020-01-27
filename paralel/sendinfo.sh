#!/usr/bin/env bash
export TZ=":Asia/Jakarta"
export STICKER
export KERNEL_TYPE
git clone https://github.com/fabianonline/telegram.sh telegram
TELEGRAM_ID=${chat_id}
TELEGRAM_TOKEN=${token}
export TELEGRAM_TOKEN

# Github Env Vars
KERNEL_NAME="GREENFORCE"
UNIFIED="Xiaomi Redmi 4A & 5A"
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
COMMIT_POINT="$(git log --pretty=format:'%h: %s by %an' -1)"

if [ "$PARSE_BRANCH" == "HMP-vdso32" ];
then
	KERNEL_TYPE=HMP
	export $KERNEL_TYPE
	STICKER="CAADBQADeQEAAn1Cwy71MK7Ir5t0PhYE"
	export $STICKER
elif [ "$PARSE_BRANCH" == "EAS" ];
then
	KERNEL_TYPE=EAS
	export $KERNEL_TYPE
	STICKER="CAADBQADIwEAAn1Cwy5pf2It72fNXBYE"
	export $STICKER
elif [ "$PARSE_BRANCH" == "aosp/android-3.18" ];
then
	KERNEL_TYPE=Pure-CaF
	export $KERNEL_TYPE
	STICKER="CAADBQADfAEAAn1Cwy6aGpFrL8EcbRYE"
	export $STICKER
elif [ ! "$KERNEL_TYPE" ];
then
	KERNEL_TYPE=TEST
	export $KERNEL_TYPE
	STICKER="CAADBQADPwEAAn1Cwy4LGnCzWtePdRYE"
	export $STICKER
fi
TELEGRAM=telegram/telegram
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
tg_channelcast "<b>${KERNEL_NAME} ${KERNEL_TYPE} build is available</b>!" \
			"<b>Device :</b> <code>${UNIFIED}</code>" \
			"<b>Branch :</b> <code>${PARSE_BRANCH}</code>" \
			"<b>Latest commit :</b> <code>${COMMIT_POINT}</code>" \
			"<b>Compile start :</b> <code>$(TZ=Asia/Jakarta date)</code>"
