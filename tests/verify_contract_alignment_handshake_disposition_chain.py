"""Verify Publishing Core multilingual contract alignment is recorded in governed markdown.

This verifier intentionally reads repo markdown files. It does not accept chat memory,
external notes, or inferred pillar ownership as evidence.
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

GOVERNED_MARKDOWN = [
    Path("docs/contracts/CONTRACT_ALIGNMENT_HANDSHAKE_DISPOSITION_CHAIN_V1.md"),
    Path("docs/contracts/CONTRACT_HANDSHAKE_DISPOSITION_REASON_MAP_V1.md"),
    Path("docs/contracts/CONTRACT_HANDSHAKE_NEXT_ACTIONS_V1.md"),
    Path("docs/status/STATUS_CURRENT.md"),
    Path("handoff/ARRIVAL_ANCHOR_CURRENT.md"),
    Path("docs/governance/receipts/RECEIPT_PROJECT_PIONEER_CONTRACT_ALIGNMENT_HANDSHAKE_DISPOSITION_CHAIN_VERISTIO_PUBLISHING_CORE_V1.md"),
]

MANDATORY_SENTENCE = (
    "Multilingual/localization is a cross-cutting Publishing Core contract dimension, "
    "not isolated to the Multilingual Production pillar."
)

REQUIRED_TERMS = [
    "source language",
    "target language",
    "locale",
    "translation status",
    "terminology/glossary dependency",
    "native-language reviewer state",
    "localization notes",
    "source-lock version used for translation",
    "translation packet lineage",
    "metadata language/edition fields",
    "multilingual QA/advisory boundaries",
    "publication gates per language, edition, and format",
    "blocked/deferred states for missing language review",
    "FUTURE_PILOT_CANDIDATE_ONLY",
]

BOUNDARY_TERMS = [
    "No language edition is publication-ready unless required review, metadata, permission, source-lock, QA, proof, format, and release gates are explicitly satisfied.",
    "Book 1 Spanish is `FUTURE_PILOT_CANDIDATE_ONLY` for Publishing Core contract alignment.",
]

NEXT_CORRIDOR = "VERISTIO_PRESS_BOOK_1_SPANISH_REVIEWER_SELECTION_OR_NATIVE_REVIEW_EXECUTION_V1"

POSITIVE_PUBLICATION_PATTERNS = [
    re.compile(r"(?i)\bbook 1 spanish\b.*\b(publication-ready|publication ready|release-approved|release approved|upload-ready|upload ready)\b"),
    re.compile(r"(?i)\bspanish edition\b.*\b(publication-ready|publication ready|release-approved|release approved|upload-ready|upload ready)\b"),
    re.compile(r"(?i)\bpublication readiness\s*[:=]\s*(ready|complete|completed|passed|approved)\b"),
    re.compile(r"(?i)\brelease approval\s*[:=]\s*(ready|complete|completed|passed|approved|granted)\b"),
]

NEGATION_OR_BLOCKING_WORDS = re.compile(
    r"(?i)\b(no|not|without|unless|until|blocked|pending|does not|do not|must not|cannot|has not|remain[s]? pending|remain[s]? blocked)\b"
)


def read_required_file(relative_path: Path) -> str:
    file_path = ROOT / relative_path
    assert file_path.exists(), f"Missing governed markdown file: {relative_path}"
    return file_path.read_text(encoding="utf-8")


def assert_no_positive_publication_claim(relative_path: Path, content: str) -> None:
    for line_number, line in enumerate(content.splitlines(), start=1):
        for pattern in POSITIVE_PUBLICATION_PATTERNS:
            if pattern.search(line) and not NEGATION_OR_BLOCKING_WORDS.search(line):
                raise AssertionError(
                    f"Potential positive publication/release claim in {relative_path}:{line_number}: {line}"
                )


def test_multilingual_contract_dimension_is_in_governed_markdown() -> None:
    contents = {}
    for relative_path in GOVERNED_MARKDOWN:
        content = read_required_file(relative_path)
        contents[relative_path] = content
        assert MANDATORY_SENTENCE in content, (
            f"Mandatory multilingual contract sentence missing from {relative_path}"
        )
        assert_no_positive_publication_claim(relative_path, content)

    combined = "\n".join(contents.values())
    for term in REQUIRED_TERMS:
        assert term in combined, f"Required multilingual contract term missing from governed markdown: {term}"

    for term in BOUNDARY_TERMS:
        assert term in combined, f"Required boundary phrase missing from governed markdown: {term}"

    assert NEXT_CORRIDOR in combined, "Expected next corridor missing from governed markdown."


def test_contract_chain_covers_required_multilingual_fields() -> None:
    chain = read_required_file(GOVERNED_MARKDOWN[0])
    for term in REQUIRED_TERMS:
        assert term in chain, f"Disposition chain must cover required field: {term}"
    assert "translation packet is admitted workflow evidence, not an authority transfer" in chain.lower()
    assert "Book repos own canonical source manuscripts" in chain


def test_book_1_spanish_is_future_candidate_only_for_publishing_core() -> None:
    status = read_required_file(Path("docs/status/STATUS_CURRENT.md"))
    handoff = read_required_file(Path("handoff/ARRIVAL_ANCHOR_CURRENT.md"))
    receipt = read_required_file(
        Path("docs/governance/receipts/RECEIPT_PROJECT_PIONEER_CONTRACT_ALIGNMENT_HANDSHAKE_DISPOSITION_CHAIN_VERISTIO_PUBLISHING_CORE_V1.md")
    )
    combined = "\n".join([status, handoff, receipt])

    assert "Book 1 Spanish" in combined
    assert "FUTURE_PILOT_CANDIDATE_ONLY" in combined
    assert "HOLD_FOR_NATIVE_REVIEWER_ASSIGNMENT" in combined
    assert "required native-language review" in combined or "native-language reviewer" in combined
    assert "not publication-ready" in handoff or "No language edition is publication-ready unless" in status


if __name__ == "__main__":
    test_multilingual_contract_dimension_is_in_governed_markdown()
    test_contract_chain_covers_required_multilingual_fields()
    test_book_1_spanish_is_future_candidate_only_for_publishing_core()
    print("VERIFICATION PASS")
