"""Simple WCAG-inspired accessibility checks without external deps."""

from html.parser import HTMLParser
from pathlib import Path
from typing import Dict, List
from urllib.parse import urlparse

import requests


class _WCAGParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.missing_alt: List[str] = []
        self.has_title: bool = False
        self._in_title: bool = False
        self.has_h1: bool = False
        self.lang: str = ""

    def handle_starttag(self, tag: str, attrs: List[tuple]) -> None:
        attr_dict = {name.lower(): (value or "") for name, value in attrs}
        tag_lower = tag.lower()
        if tag_lower == "img":
            alt_text = attr_dict.get("alt", "").strip()
            if not alt_text:
                self.missing_alt.append(attr_dict.get("src", ""))
        elif tag_lower == "title":
            self._in_title = True
        elif tag_lower == "h1":
            self.has_h1 = True
        elif tag_lower == "html":
            self.lang = attr_dict.get("lang", "").strip()

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() == "title":
            self._in_title = False

    def handle_data(self, data: str) -> None:
        if self._in_title and data.strip():
            self.has_title = True


def _load_html(url: str) -> str:
    parsed = urlparse(url)
    if parsed.scheme in ("http", "https"):
        response = requests.get(url)
        response.raise_for_status()
        return response.text
    return Path(url).read_text(encoding="utf-8")


def analyze_page_accessibility(url: str) -> Dict[str, object]:
    """Return basic accessibility information for the given page."""
    html = _load_html(url)
    parser = _WCAGParser()
    parser.feed(html)
    return {
        "missing_alt": parser.missing_alt,
        "has_title": parser.has_title,
        "has_h1": parser.has_h1,
        "has_lang": bool(parser.lang),
    }


def generate_accessibility_report(url: str) -> str:
    """Generate a human readable accessibility summary for the page."""
    result = analyze_page_accessibility(url)
    lines = [
        f"Accessibility report for {url}:",
        f" - Images without alt: {len(result['missing_alt'])}",
        f" - Has title: {result['has_title']}",
        f" - Has h1: {result['has_h1']}",
        f" - Has lang attribute: {result['has_lang']}",
    ]
    return "\n".join(lines)


def assert_wcag_basic(url: str) -> None:
    """Robot keyword that fails if basic WCAG rules are violated."""
    result = analyze_page_accessibility(url)
    issues = []
    if result["missing_alt"]:
        issues.append("missing alt text")
    if not result["has_title"]:
        issues.append("missing title element")
    if not result["has_h1"]:
        issues.append("missing h1 element")
    if not result["has_lang"]:
        issues.append("missing lang attribute on html element")
    if issues:
        raise AssertionError("; ".join(issues))
