"""Utilities for basic accessibility checks without a browser."""

from html.parser import HTMLParser
from pathlib import Path
from typing import List, Dict


class _ImgAltParser(HTMLParser):
    """HTML parser that collects image tags without alternative text."""

    def __init__(self) -> None:
        super().__init__()
        self.total: int = 0
        self.missing: List[str] = []

    def handle_starttag(self, tag: str, attrs: List[tuple]) -> None:
        if tag.lower() != "img":
            return

        self.total += 1
        attr_dict = {name.lower(): (value or "") for name, value in attrs}
        alt_text = attr_dict.get("alt", "").strip()
        if not alt_text:
            self.missing.append(attr_dict.get("src", ""))


def analyze_image_alts(path: str) -> Dict[str, object]:
    """Return a summary of image alt attributes for the given HTML file."""
    html = Path(path).read_text(encoding="utf-8")
    parser = _ImgAltParser()
    parser.feed(html)
    return {"total": parser.total, "missing": parser.missing}


def assert_no_missing_alts(path: str) -> int:
    """Robot Framework keyword that fails if any image lacks alt text."""
    result = analyze_image_alts(path)
    if result["missing"]:
        raise AssertionError(f"Images without alt text: {result['missing']}")
    return result["total"]

