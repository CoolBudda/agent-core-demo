from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class FormSubmission:
    """Represents a validated user form submission."""

    name: str
    email: str
    phone: str
    sport: str
    raw_text: str = ""
    metadata: dict[str, str] = field(default_factory=dict)

    def is_structured(self) -> bool:
        """Return True when all structured fields are populated."""
        return all([self.name, self.email, self.phone, self.sport])
