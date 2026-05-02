#!/usr/bin/env bash

URL="$1"            # Required: Base URL for OpenAI-compatible endpoint
API_KEY="$2"        # Required: API key (a non-empty text string allowed by endpoint)
MODEL="$3"          # Required: Model "id"  as seen in /v1/models or /api/v1/models
PROMPT_FILE="$4"    # Optional: Can be a prompt string or a path (/path/to/filename)

if [ -z "$URL" ] || [ -z "$API_KEY" ] || [ -z "$MODEL" ]; then
  echo "Usage: $0 <URL> <API_KEY> <MODEL_NAME> <optional: PROMPT or PROMPT_FILE>"
  exit 1
fi

# Use the PROMPT_FILE string as the prompt filename if it's readable
if [ -z "$PROMPT_FILE" ]; then PROMPT_FILE="hello"; fi
if [ -r "$PROMPT_FILE" ]; then
  PROMPT=$(jq -Rs . < "$PROMPT_FILE")
else PROMPT="$PROMPT_FILE"
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
        \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}]
      }")

END_TIME=$(now_ms)
ELAPSED_MS=$((END_TIME - START_TIME))

CONTENT=$(echo "$RESP" | jq -r '.choices[0].message.content')

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

