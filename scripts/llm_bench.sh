#!/usr/bin/env bash

URL="$1"
API_KEY="$2"
MODEL="$3"

if [ -z "$URL" ] || [ -z "$API_KEY" ] || [ -z "$MODEL" ]; then
  echo "Usage: $0 <URL> <API_KEY> <MODEL_NAME>"
  exit 1
fi

# Portable millisecond timestamp
now_ms() {
  perl -MTime::HiRes=time -e 'printf("%.0f\n", time()*1000)'
}

START_TIME=$(now_ms)

RESP=$(curl -s -X POST "$URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "{
        \"model\": \"$MODEL\",
        \"messages\": [{\"role\": \"user\", \"content\": \"hello\"}]
      }")

END_TIME=$(now_ms)
ELAPSED_MS=$((END_TIME - START_TIME))

TOK_IN=$(echo "$RESP" | jq -r '.usage.prompt_tokens')
TOK_OUT=$(echo "$RESP" | jq -r '.usage.completion_tokens')
TOK_TOTAL=$(echo "$RESP" | jq -r '.usage.total_tokens')

# Compute tokens/sec safely
if [ "$ELAPSED_MS" -gt 0 ] 2>/dev/null; then
  TOKS_PER_SEC=$(awk "BEGIN { printf \"%.2f\", $TOK_OUT / ($ELAPSED_MS / 1000) }")
else
  TOKS_PER_SEC=""
fi

echo "${MODEL},${TOK_IN},${TOK_OUT},${TOK_TOTAL},${ELAPSED_MS},${TOKS_PER_SEC}"

