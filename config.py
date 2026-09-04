# SPDX-FileCopyrightText: 2026 Justin Lowe
#
# SPDX-License-Identifier: MIT

"""Configuration parameters and business rules for alert urgencies."""

# Alert duration thresholds in minutes
WARNING_MINUTES = 5
CRITICAL_MINUTES = 30

# List of alert names that immediately escalate to Critical when alerting,
# regardless of elapsed duration.
ALWAYS_CRITICAL_ALERTS = []
