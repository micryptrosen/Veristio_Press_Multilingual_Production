#!/usr/bin/env python3
"""Run a real DeepSeek advisory review through the OpenAI-compatible API.

The runner reads DEEPSEEK_API_KEY from the process environment, never prints it,
and never writes it to disk. Output markdown records only non-secret call metadata
and the model response body.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
from pathlib import Path
import sys
import urllib.error
import urllib.request


DEFAULT_BASE_URL = "https://api.deepseek.com"
DEFAULT_MODEL = "deepseek-v4-flash"
DEFAULT_FALLBACK_MODEL = "deepseek-v4-pro"
DEFAULT_ENDPOINT = "/chat/completions"


class DeepSeekCallError(RuntimeError):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a real DeepSeek advisory API review.")
    parser.add_argument("--input", required=True, help="Input file path to review or summarize.")
    parser.add_argument("--output", required=True, help="Output markdown path to write.")
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL, help="DeepSeek API base URL.")
    parser.add_argument("--endpoint", default=DEFAULT_ENDPOINT, help="Chat completions endpoint path.")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="Preferred DeepSeek model.")
    parser.add_argument("--fallback-model", default=DEFAULT_FALLBACK_MODEL, help="Fallback DeepSeek model.")
    parser.add_argument("--prompt-purpose", default="DeepSeek advisory-only review", help="Purpose recorded in output markdown.")
    parser.add_argument("--max-input-chars", type=int, default=12000, help="Maximum input characters to send.")
    parser.add_argument("--max-tokens", type=int, default=800, help="Maximum response tokens.")
    parser.add_argument("--temperature", type=float, default=0.1, help="Sampling temperature.")
    parser.add_argument("--timeout", type=int, default=45, help="HTTP timeout seconds.")
    parser.add_argument("--connectivity-test", action="store_true", help="Use a tiny connectivity-test prompt.")
    return parser.parse_args()


def require_api_key() -> str:
    api_key = os.environ.get("DEEPSEEK_API_KEY")
    if not api_key:
        raise DeepSeekCallError("DEEPSEEK_API_KEY is missing from the process environment.")
    return api_key


def load_input(path: Path, max_chars: int) -> str:
    if not path.exists():
        raise DeepSeekCallError(f"Input file does not exist: {path}")
    content = path.read_text(encoding="utf-8")
    if len(content) > max_chars:
        return content[:max_chars] + "\n\n[INPUT TRUNCATED FOR API CALL]"
    return content


def endpoint_url(base_url: str, endpoint: str) -> str:
    return base_url.rstrip("/") + "/" + endpoint.lstrip("/")


def build_messages(input_text: str, purpose: str, connectivity_test: bool) -> list[dict[str, str]]:
    system = (
        "You are DeepSeek performing an advisory-only editorial/translation review. "
        "Do not claim human review, native-language review, final review, publication readiness, or release approval. "
        "Be concise and label the output advisory-only."
    )
    if connectivity_test:
        user = (
            "Connectivity test only. Reply with exactly this text and nothing else: "
            "REAL_DEEPSEEK_API_RESPONSE"
        )
    else:
        user = (
            f"Prompt purpose: {purpose}\n\n"
            "Review the following input as advisory-only. Identify concrete findings, safe repair candidates, "
            "deferred items for a real native/human reviewer, and any publication/release boundary concerns.\n\n"
            "INPUT:\n"
            f"{input_text}"
        )
    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


def call_deepseek(
    *,
    api_key: str,
    base_url: str,
    endpoint: str,
    model: str,
    messages: list[dict[str, str]],
    max_tokens: int,
    temperature: float,
    timeout: int,
) -> tuple[str, dict]:
    payload = {
        "model": model,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
    }
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        endpoint_url(base_url, endpoint),
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            raw = response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        error_body = exc.read().decode("utf-8", errors="replace")
        raise DeepSeekCallError(f"DeepSeek API HTTP {exc.code} for model {model}: {error_body[:500]}") from exc
    except urllib.error.URLError as exc:
        raise DeepSeekCallError(f"DeepSeek API network error for model {model}: {exc.reason}") from exc
    except TimeoutError as exc:
        raise DeepSeekCallError(f"DeepSeek API timeout for model {model}.") from exc

    try:
        parsed = json.loads(raw)
        response_text = parsed["choices"][0]["message"]["content"]
    except (json.JSONDecodeError, KeyError, IndexError, TypeError) as exc:
        raise DeepSeekCallError(f"DeepSeek API returned an unexpected response shape for model {model}.") from exc

    if not str(response_text).strip():
        raise DeepSeekCallError(f"DeepSeek API returned an empty response for model {model}.")

    return str(response_text), parsed


def write_output(
    *,
    output_path: Path,
    model: str,
    base_url: str,
    endpoint: str,
    prompt_purpose: str,
    response_text: str,
    connectivity_test: bool,
) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    timestamp = dt.datetime.now(dt.UTC).isoformat(timespec="seconds")
    body = f"""# DeepSeek API Advisory Output

## Real API Response

YES

## Timestamp UTC

{timestamp}

## Model

`{model}`

## API Base URL

`{base_url}`

## API Endpoint

`{endpoint}`

## Prompt Purpose

{prompt_purpose}

## Connectivity Test

{str(connectivity_test).upper()}

## Advisory Boundary

DeepSeek output is advisory-only. It is not human review, not native-language review, not final review, not publication readiness, and not release approval.

## Response Body

{response_text.strip()}
"""
    output_path.write_text(body, encoding="utf-8")


def main() -> int:
    args = parse_args()
    input_path = Path(args.input).resolve()
    output_path = Path(args.output).resolve()

    try:
        api_key = require_api_key()
        input_text = load_input(input_path, args.max_input_chars)
        messages = build_messages(input_text, args.prompt_purpose, args.connectivity_test)

        errors: list[str] = []
        for model in [args.model, args.fallback_model]:
            try:
                response_text, _raw = call_deepseek(
                    api_key=api_key,
                    base_url=args.base_url,
                    endpoint=args.endpoint,
                    model=model,
                    messages=messages,
                    max_tokens=args.max_tokens,
                    temperature=args.temperature,
                    timeout=args.timeout,
                )
                write_output(
                    output_path=output_path,
                    model=model,
                    base_url=args.base_url,
                    endpoint=args.endpoint,
                    prompt_purpose=args.prompt_purpose,
                    response_text=response_text,
                    connectivity_test=args.connectivity_test,
                )
                print(f"DEEPSEEK_API_CALL_SUCCEEDED model={model} output={output_path}")
                return 0
            except DeepSeekCallError as exc:
                errors.append(str(exc))
                if model == args.fallback_model:
                    break

        raise DeepSeekCallError("DeepSeek API call failed for preferred and fallback models: " + " | ".join(errors))
    except DeepSeekCallError as exc:
        print(f"DEEPSEEK_API_CALL_FAILED: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
