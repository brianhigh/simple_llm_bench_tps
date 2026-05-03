#!/usr/bin/env python3
"""
Python script to benchmark LLM endpoints (OpenAI-compatible API).
Replicates the functionality of llm_bench.sh shell script.

Usage:
    python llm_bench.py <URL> <API_KEY> <MODEL> [PROMPT_FILE]

Arguments:
    URL         - Base URL for OpenAI-compatible endpoint
    API_KEY     - API key for authentication
    MODEL       - Model ID as seen in /v1/models or /api/v1/models
    PROMPT_FILE - Optional: Can be a prompt string or a path to a file

Output (CSV format):
    model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second
"""

import sys
import os
import json
import time
import urllib.request
import urllib.error


def now_ms():
    """Return current time in milliseconds."""
    return int(time.time() * 1000)


def load_prompt(prompt_arg):
    """
    Load prompt from file if it's a readable file path, otherwise return as-is.
    
    Args:
        prompt_arg: Either a prompt string or a path to a file
        
    Returns:
        The prompt content as a string
    """
    if os.path.isfile(prompt_arg) and os.access(prompt_arg, os.R_OK):
        with open(prompt_arg, 'r') as f:
            return f.read()
    return prompt_arg


def make_api_call(url, api_key, model, prompt):
    """
    Make a POST request to the OpenAI-compatible chat completions endpoint.
    
    Args:
        url: Base URL for the endpoint
        api_key: API key for authentication
        model: Model ID to use
        prompt: The prompt content
        
    Returns:
        Tuple of (response_json, elapsed_ms)
    """
    start_time = now_ms()
    
    # Prepare the request
    data = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}]
    }).encode('utf-8')
    
    req = urllib.request.Request(
        f"{url}/v1/chat/completions",
        data=data,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        },
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            response_data = response.read().decode('utf-8')
            end_time = now_ms()
            return json.loads(response_data), end_time - start_time
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        print(f"HTTP Error {e.code}: {e.reason}", file=sys.stderr)
        print(f"Response: {error_body}", file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"URL Error: {e.reason}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"JSON decode error: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    # Check arguments
    if len(sys.argv) < 4:
        print("Usage: python llm_bench.py <URL> <API_KEY> <MODEL> [PROMPT_FILE]", file=sys.stderr)
        sys.exit(1)
    
    url = sys.argv[1]
    api_key = sys.argv[2]
    model = sys.argv[3]
    prompt_file = sys.argv[4] if len(sys.argv) > 4 else "hello"
    
    # Load prompt
    prompt = load_prompt(prompt_file)
    
    # Make API call
    resp_json, elapsed_ms = make_api_call(url, api_key, model, prompt)
    
    # Extract metrics
    content = resp_json.get('choices', [{}])[0].get('message', {}).get('content', '')
    tok_in = resp_json.get('usage', {}).get('prompt_tokens', 0)
    tok_out = resp_json.get('usage', {}).get('completion_tokens', 0)
    tok_total = resp_json.get('usage', {}).get('total_tokens', 0)
    
    # Calculate tokens per second
    if elapsed_ms > 0:
        tok_per_sec = tok_out / (elapsed_ms / 1000.0)
    else:
        tok_per_sec = 0.0
    
    # Output CSV format
    print(f"{model},{tok_in},{tok_out},{tok_total},{elapsed_ms},{tok_per_sec:.2f}")


if __name__ == "__main__":
    main()