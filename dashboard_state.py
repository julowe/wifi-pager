# SPDX-FileCopyrightText: 2026 Justin Lowe
#
# SPDX-License-Identifier: MIT

"""Pure-logic DashboardState module for parsing and categorizing Grafana alerts."""

import time


def _parse_iso8601(date_str):
    """Parse an ISO 8601 timestamp string into epoch seconds (UTC).

    Compatible with Python 3 and CircuitPython without heavy dependencies.
    """
    if not date_str or not isinstance(date_str, str):
        return None
    try:
        s = date_str.strip()
        if "T" in s:
            date_part, time_part = s.split("T", 1)
        elif " " in s:
            date_part, time_part = s.split(" ", 1)
        else:
            return None

        year_s, mon_s, day_s = date_part.split("-")
        year, mon, day = int(year_s), int(mon_s), int(day_s)

        tz_offset_seconds = 0
        if time_part.endswith(("Z", "z")):
            time_part = time_part[:-1]
        elif "+" in time_part:
            time_part, tz_s = time_part.split("+", 1)
            tz_parts = tz_s.split(":")
            tz_offset_seconds = int(tz_parts[0]) * 3600 + (
                int(tz_parts[1]) * 60 if len(tz_parts) > 1 else 0
            )
        elif "-" in time_part:
            time_part, tz_s = time_part.split("-", 1)
            tz_parts = tz_s.split(":")
            tz_offset_seconds = -(
                int(tz_parts[0]) * 3600 + (int(tz_parts[1]) * 60 if len(tz_parts) > 1 else 0)
            )

        if "." in time_part:
            time_part = time_part.split(".", 1)[0]

        time_parts = time_part.split(":")
        hour = int(time_parts[0])
        minute = int(time_parts[1])
        second = int(time_parts[2]) if len(time_parts) > 2 else 0

        t_tuple = (year, mon, day, hour, minute, second, 0, 0, 0)
        try:
            import calendar

            base_ts = float(calendar.timegm(t_tuple))
        except (ImportError, AttributeError):
            base_ts = float(time.mktime(t_tuple))

        return base_ts - tz_offset_seconds
    except (ValueError, IndexError, TypeError, OverflowError, KeyError):
        return None


def _to_timestamp(t):
    """Convert current_time (struct_time, float, int, ISO str, or None) to float seconds."""
    if t is None:
        return None
    if isinstance(t, (int, float)):
        return float(t)
    if isinstance(t, str):
        return _parse_iso8601(t)
    try:
        try:
            import calendar

            return float(calendar.timegm(t))
        except (ImportError, AttributeError):
            return float(time.mktime(t))
    except (TypeError, ValueError, OverflowError, KeyError):
        return None


class DashboardState:
    """Parses Grafana alerts JSON and categorizes into domain urgency levels."""

    def __init__(self, alerts_json, config=None, current_time=None):
        if config is None:
            try:
                import config as default_config

                config = default_config
            except ImportError:
                config = None

        if isinstance(config, dict):
            self._warning_minutes = config.get("WARNING_MINUTES", 5)
            self._critical_minutes = config.get("CRITICAL_MINUTES", 30)
            self._always_critical_alerts = config.get("ALWAYS_CRITICAL_ALERTS", [])
        else:
            self._warning_minutes = getattr(config, "WARNING_MINUTES", 5) if config else 5
            self._critical_minutes = getattr(config, "CRITICAL_MINUTES", 30) if config else 30
            self._always_critical_alerts = (
                getattr(config, "ALWAYS_CRITICAL_ALERTS", []) if config else []
            )

        self._current_ts = _to_timestamp(current_time)

        self.healthy_alerts = []
        self.warning_alerts = []
        self.alert_alerts = []
        self.critical_alerts = []

        self._process_alerts(alerts_json)

    def _process_alerts(self, alerts_json):
        if not alerts_json:
            return

        for item in alerts_json:
            if not isinstance(item, dict):
                continue

            name = str(item.get("name", "Unknown alert"))
            raw_state = item.get("state", "alerting")
            if isinstance(raw_state, str):
                raw_state = raw_state.strip().lower()
            else:
                raw_state = str(raw_state).strip().lower()
            new_state_date = item.get("newStateDate")

            # Calculate duration in minutes if current_ts and new_state_date are available
            duration_minutes = None
            if self._current_ts is not None and new_state_date:
                alert_ts = _parse_iso8601(new_state_date)
                if alert_ts is not None:
                    duration_minutes = max(0.0, (self._current_ts - alert_ts) / 60.0)

            # Categorize based on domain rules
            if raw_state == "ok":
                self.healthy_alerts.append(name)
            elif raw_state == "pending":
                self.warning_alerts.append(name)
            elif raw_state == "no_data":
                # Fail-safe if duration unknown: treated as Alert immediately
                if duration_minutes is None:
                    self.alert_alerts.append(name)
                elif duration_minutes < self._warning_minutes:
                    self.warning_alerts.append(name)
                else:
                    self.alert_alerts.append(name)
            else:
                # "alerting" or other error states
                if name in self._always_critical_alerts:
                    self.critical_alerts.append(name)
                elif duration_minutes is None:
                    # Fail-safe: treated as Critical immediately
                    self.critical_alerts.append(name)
                elif duration_minutes >= self._critical_minutes:
                    self.critical_alerts.append(name)
                else:
                    self.alert_alerts.append(name)

    @property
    def is_all_ok(self) -> bool:
        """True if all alerts are healthy (no warnings, alerts, or criticals)."""
        return (
            len(self.warning_alerts) == 0
            and len(self.alert_alerts) == 0
            and len(self.critical_alerts) == 0
        )

    @property
    def has_warnings(self) -> bool:
        """True if any alert is in Warning urgency."""
        return len(self.warning_alerts) > 0

    @property
    def has_alerts(self) -> bool:
        """True if any alert is in Alert urgency."""
        return len(self.alert_alerts) > 0

    @property
    def has_criticals(self) -> bool:
        """True if any alert is in Critical urgency."""
        return len(self.critical_alerts) > 0

    def get_display_summary(self) -> str:
        """Generate formatted summary text for e-ink display."""
        if self.is_all_ok:
            return "All Ok  :-)"

        lines = []
        if self.critical_alerts:
            verb = "are" if len(self.critical_alerts) > 1 else "is"
            lines.append(f"{', '.join(self.critical_alerts)} {verb} critical.")

        if self.alert_alerts:
            verb = "are" if len(self.alert_alerts) > 1 else "is"
            lines.append(f"{', '.join(self.alert_alerts)} {verb} alerting.")

        if self.warning_alerts:
            verb = "are" if len(self.warning_alerts) > 1 else "is"
            lines.append(f"{', '.join(self.warning_alerts)} {verb} warning.")

        return "\n".join(lines)
