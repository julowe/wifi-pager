import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import config
from dashboard_state import DashboardState


def test_default_config_thresholds():
    assert config.WARNING_MINUTES == 5
    assert config.CRITICAL_MINUTES == 30
    assert config.ALWAYS_CRITICAL_ALERTS == []


def test_empty_alerts_is_all_ok():
    state = DashboardState([])
    assert state.is_all_ok is True
    assert state.has_warnings is False
    assert state.has_alerts is False
    assert state.has_criticals is False
    assert state.healthy_alerts == []
    assert state.warning_alerts == []
    assert state.alert_alerts == []
    assert state.critical_alerts == []
    assert state.get_display_summary() == "All Ok  :-)"


def test_healthy_alerts():
    alerts = [
        {"name": "Rack Room alert", "state": "ok", "newStateDate": "2022-09-23T10:11:16Z"},
        {"name": "Shiphouse temp", "state": "ok", "newStateDate": "2022-09-23T10:15:00Z"},
    ]
    state = DashboardState(alerts)
    assert state.is_all_ok is True
    assert state.has_warnings is False
    assert state.has_alerts is False
    assert state.has_criticals is False
    assert state.healthy_alerts == ["Rack Room alert", "Shiphouse temp"]
    assert state.get_display_summary() == "All Ok  :-)"


def test_warning_pending_state():
    alerts = [
        {"name": "Pending Service", "state": "pending", "newStateDate": "2022-09-23T10:11:16Z"}
    ]
    state = DashboardState(alerts)
    assert state.is_all_ok is False
    assert state.has_warnings is True
    assert state.has_alerts is False
    assert state.has_criticals is False
    assert state.warning_alerts == ["Pending Service"]
    assert state.get_display_summary() == "Pending Service is warning."


def test_warning_no_data_under_threshold():
    # 3 minutes of no_data (< WARNING_MINUTES which defaults to 5)
    alerts = [
        {"name": "Sensor Alpha", "state": "no_data", "newStateDate": "2022-09-23T10:07:00Z"}
    ]
    current_time = "2022-09-23T10:10:00Z"  # 3 minutes later
    state = DashboardState(alerts, current_time=current_time)
    assert state.is_all_ok is False
    assert state.has_warnings is True
    assert state.has_alerts is False
    assert state.has_criticals is False
    assert state.warning_alerts == ["Sensor Alpha"]
    assert state.get_display_summary() == "Sensor Alpha is warning."


def test_alert_no_data_over_threshold():
    # 6 minutes of no_data (>= WARNING_MINUTES which defaults to 5)
    alerts = [
        {"name": "Sensor Alpha", "state": "no_data", "newStateDate": "2022-09-23T10:04:00Z"}
    ]
    current_time = "2022-09-23T10:10:00Z"  # 6 minutes later
    state = DashboardState(alerts, current_time=current_time)
    assert state.is_all_ok is False
    assert state.has_warnings is False
    assert state.has_alerts is True
    assert state.has_criticals is False
    assert state.alert_alerts == ["Sensor Alpha"]
    assert state.get_display_summary() == "Sensor Alpha is alerting."


def test_alert_alerting_under_critical_threshold():
    # 15 minutes of alerting (< CRITICAL_MINUTES which defaults to 30)
    alerts = [
        {"name": "Disk Usage", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"}
    ]
    current_time = "2022-09-23T10:15:00Z"  # 15 minutes later
    state = DashboardState(alerts, current_time=current_time)
    assert state.is_all_ok is False
    assert state.has_warnings is False
    assert state.has_alerts is True
    assert state.has_criticals is False
    assert state.alert_alerts == ["Disk Usage"]
    assert state.get_display_summary() == "Disk Usage is alerting."


def test_critical_alerting_over_critical_threshold():
    # 35 minutes of alerting (>= CRITICAL_MINUTES which defaults to 30)
    alerts = [
        {"name": "Database Connection", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"}
    ]
    current_time = "2022-09-23T10:35:00Z"  # 35 minutes later
    state = DashboardState(alerts, current_time=current_time)
    assert state.is_all_ok is False
    assert state.has_warnings is False
    assert state.has_alerts is False
    assert state.has_criticals is True
    assert state.critical_alerts == ["Database Connection"]
    assert state.get_display_summary() == "Database Connection is critical."


def test_critical_always_critical_alert():
    # In ALWAYS_CRITICAL_ALERTS, alerting for only 1 minute -> immediately Critical
    class CustomConfig:
        WARNING_MINUTES = 5
        CRITICAL_MINUTES = 30
        ALWAYS_CRITICAL_ALERTS = ("Power Grid",)

    alerts = [
        {"name": "Power Grid", "state": "alerting", "newStateDate": "2022-09-23T10:09:00Z"}
    ]
    current_time = "2022-09-23T10:10:00Z"  # 1 minute later
    state = DashboardState(alerts, config=CustomConfig, current_time=current_time)
    assert state.is_all_ok is False
    assert state.has_criticals is True
    assert state.critical_alerts == ["Power Grid"]
    assert state.alert_alerts == []
    assert state.get_display_summary() == "Power Grid is critical."


def test_failsafe_when_current_time_is_none():
    # Fail-safe: alerting -> Critical, no_data -> Alert, pending -> Warning, ok -> Healthy
    alerts = [
        {"name": "Alert One", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"},
        {"name": "Alert Two", "state": "no_data", "newStateDate": "2022-09-23T10:00:00Z"},
        {"name": "Alert Three", "state": "pending", "newStateDate": "2022-09-23T10:00:00Z"},
        {"name": "Alert Four", "state": "ok", "newStateDate": "2022-09-23T10:00:00Z"},
    ]
    state = DashboardState(alerts, current_time=None)
    assert state.is_all_ok is False
    assert state.has_criticals is True
    assert state.has_alerts is True
    assert state.has_warnings is True
    assert state.critical_alerts == ["Alert One"]
    assert state.alert_alerts == ["Alert Two"]
    assert state.warning_alerts == ["Alert Three"]
    assert state.healthy_alerts == ["Alert Four"]


def test_current_time_as_struct_time():
    # CircuitPython ntp.datetime provides struct_time
    st = time.struct_time((2022, 9, 23, 10, 40, 0, 4, 266, 0))
    alerts = [
        {"name": "Core Service", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"}
    ]
    # 40 minutes elapsed -> Critical
    state = DashboardState(alerts, current_time=st)
    assert state.has_criticals is True
    assert state.critical_alerts == ["Core Service"]


def test_current_time_as_float_timestamp():
    # Timestamp: 2022-09-23 10:10:00 UTC = 1663927800
    # Alert at 2022-09-23 10:00:00 UTC = 1663927200 (10 min duration -> Alert)
    current_ts = 1663927800.0
    alerts = [
        {"name": "Worker Node", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"}
    ]
    state = DashboardState(alerts, current_time=current_ts)
    assert state.has_alerts is True
    assert state.has_criticals is False
    assert state.alert_alerts == ["Worker Node"]


def test_display_summary_pluralization_and_ordering():
    alerts = [
        {"name": "Database", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"},
        {"name": "Auth API", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"},
        {"name": "Disk A", "state": "no_data", "newStateDate": "2022-09-23T10:20:00Z"},
        {"name": "Disk B", "state": "no_data", "newStateDate": "2022-09-23T10:20:00Z"},
        {"name": "Cache", "state": "pending", "newStateDate": "2022-09-23T10:30:00Z"},
        {"name": "Queue", "state": "pending", "newStateDate": "2022-09-23T10:30:00Z"},
    ]
    # current_time: 10:35:00
    # Database, Auth API: 35 min -> critical (plural)
    # Disk A, Disk B: 15 min no_data -> alert (plural)
    # Cache, Queue: pending -> warning (plural)
    current_time = "2022-09-23T10:35:00Z"
    state = DashboardState(alerts, current_time=current_time)
    expected_summary = (
        "Database, Auth API are critical.\n"
        "Disk A, Disk B are alerting.\n"
        "Cache, Queue are warning."
    )
    assert state.get_display_summary() == expected_summary


def test_malformed_date_falls_back_to_failsafe():
    alerts = [
        {"name": "Corrupted Alert", "state": "alerting", "newStateDate": "invalid-date-string"}
    ]
    state = DashboardState(alerts, current_time="2022-09-23T10:00:00Z")
    assert state.has_criticals is True
    assert state.critical_alerts == ["Corrupted Alert"]


def test_none_alerts_json():
    state = DashboardState(None)
    assert state.is_all_ok is True
    assert state.healthy_alerts == []
    assert state.warning_alerts == []
    assert state.alert_alerts == []
    assert state.critical_alerts == []
    assert state.get_display_summary() == "All Ok  :-)"


def test_subsecond_and_timezone_offset_iso_timestamps():
    # 2022-09-23T10:11:16.789Z vs 2022-09-23T10:21:16.123Z (10 min elapsed)
    alerts = [
        {"name": "Subsecond Alert", "state": "alerting", "newStateDate": "2022-09-23T10:11:16.789Z"}
    ]
    state = DashboardState(alerts, current_time="2022-09-23T10:21:16.123Z")
    assert state.has_alerts is True
    assert state.alert_alerts == ["Subsecond Alert"]


def test_clock_skew_negative_duration_clamped():
    # current_time slightly before newStateDate
    alerts = [
        {"name": "Skew Alert", "state": "no_data", "newStateDate": "2022-09-23T10:05:00Z"}
    ]
    # Current time is 10:04:00 (1 min before) -> clamped to 0 duration -> Warning (< 5 min)
    state = DashboardState(alerts, current_time="2022-09-23T10:04:00Z")
    assert state.has_warnings is True
    assert state.warning_alerts == ["Skew Alert"]


def test_dict_config():
    custom_cfg = {
        "WARNING_MINUTES": 2,
        "CRITICAL_MINUTES": 10,
        "ALWAYS_CRITICAL_ALERTS": ["Immediate"],
    }
    alerts = [
        {"name": "Immediate", "state": "alerting", "newStateDate": "2022-09-23T10:00:00Z"}
    ]
    state = DashboardState(alerts, config=custom_cfg, current_time="2022-09-23T10:01:00Z")
    assert state.has_criticals is True
    assert state.critical_alerts == ["Immediate"]

