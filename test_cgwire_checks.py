import json
import pytest
import requests

from unittest import TestCase
from unittest.mock import patch

from cgwire_checks import CheckURL


def connection_error(yes):
    raise requests.exceptions.ConnectionError()


class TestCheckURL(TestCase):
    def setUp(self):
        self.t = CheckURL("http://127.0.0.1")
        self.msg_ok = "✅ 01 Check Kitsu /"
        self.msg_ko = "🔥 01 Check Kitsu /"

    def test_init(self):
        assert self.t.base_url == "http://127.0.0.1"
        assert self.t.status == 0
        assert self.t.request == None

        t = CheckURL("http://127.0.0.1:8080")
        assert t.base_url == "http://127.0.0.1:8080"

    def test_check_url_root(self):
        with patch("requests.get") as mock_request:
            mock_request.return_value.status_code = 200
            assert (self.t.check_url("/", self.msg_ok, self.msg_ko)) == self.msg_ok
            assert self.t.status == 0
            mock_request.assert_called_once_with("http://127.0.0.1/")

    def test_check_url_without_server(self):
        with patch("requests.get") as mock_request:
            mock_request.return_value.status_code = 502
            mock_request.return_value.text = "<html>502 Bad Gateway</html>"
            assert (
                self.t.check_url("/api/ko", self.msg_ok, self.msg_ko)
            ) == self.msg_ko + "\n<html>502 Bad Gateway</html>"
            assert self.t.status == 1
            mock_request.assert_called_once_with("http://127.0.0.1/api/ko")

    def test_check_url_with_502(self):
        with patch("requests.get") as mock_request:
            mock_request.return_value.status_code = 502
            mock_request.return_value.text = "<html>502 Bad Gateway</html>"
            assert (
                self.t.check_url("/api/ko", self.msg_ok, self.msg_ko)
            ) == self.msg_ko + "\n<html>502 Bad Gateway</html>"
            assert self.t.status == 1
            mock_request.assert_called_once_with("http://127.0.0.1/api/ko")

    def test_check_url_with_db_error(self):
        msg_db_ko = "{'error': True, 'login': False, 'message': \"Database doesn't seem reachable.\"}"
        with patch("requests.get") as mock_request:
            mock_request.return_value.status_code = 500
            mock_request.return_value.text = msg_db_ko
            assert (
                self.t.check_url("/api/db_ko", self.msg_ok, self.msg_ko)
            ) == self.msg_ko + "\n" + msg_db_ko
            assert self.t.status == 1
            mock_request.assert_called_once_with("http://127.0.0.1/api/db_ko")

    def test_check_url_with_http_error(self):
        with patch("requests.get", **{"side_effect": connection_error}) as mock_request:
            assert (self.t.check_url("/", self.msg_ok, self.msg_ko)) == self.msg_ko
            assert self.t.status == 1
            mock_request.assert_called_once_with("http://127.0.0.1/")

        with patch("requests.get") as mock_request:
            mock_request.return_value.status_code = 200
            self.t.check_url("/", self.msg_ok, self.msg_ko)
            assert self.t.status == 1

    def test_check_if_last_request_is_a_kitsu(self):
        self.msg_ok = "✅ 01b Check if it's realy a Kitsu"
        self.msg_ko = "🔥 01b Check if it's realy a Kitsu"
        with patch(
            "requests.get",
            **{
                "return_value.status_code": 200,
                "return_value.text": """<html>
                <title>Kitsu - Collaboration Platform For Animation Studios</title>
                </html>
                """,
            }
        ):
            self.t.check_url("/", self.msg_ok, self.msg_ko)
            assert (
                self.t.check_if_last_request_is_a_kitsu(
                    self.msg_ok,
                    self.msg_ko,
                )
            ) == self.msg_ok

    def test_check_if_last_request_is_a_kitsu_ko(self):
        self.msg_ok = "✅ 01b Check if it's realy a Kitsu"
        self.msg_ko = "🔥 01b Check if it's realy a Kitsu"
        with patch(
            "requests.get",
            **{
                "return_value.status_code": 200,
                "return_value.text": """<html>
                <title>Another web page</title>
                </html>
                """,
            }
        ):
            self.t.check_url("/", self.msg_ok, self.msg_ko)
            assert (
                self.t.check_if_last_request_is_a_kitsu(
                    self.msg_ok,
                    self.msg_ko,
                )
            ) == self.msg_ko

    def test_check_if_last_request_is_a_zou(self):
        self.msg_ok = "✅ 02b Check if it's realy a Zou"
        self.msg_ko = "🔥 02b Check if it's realy a Zou"
        msg_api_ok = '{"api": "Zou", "version": "X.XX.XX"}'

        def json_patch():
            return json.loads(msg_api_ok)

        with patch(
            "requests.get",
            **{
                "return_value.status_code": 200,
                "return_value.text": msg_api_ok,
                "return_value.json.side_effect": json_patch,
            }
        ) as mock_request:
            self.t.check_url("/api", self.msg_ok, self.msg_ko)
            assert (
                self.t.check_if_last_request_is_a_zou(
                    self.msg_ok,
                    self.msg_ko,
                )
            ) == self.msg_ok

    def test_check_if_last_request_is_a_zou_ko(self):
        self.msg_ok = "✅ 02b Check if it's realy a Zou"
        self.msg_ko = "🔥 02b Check if it's realy a Zou"
        msg_api_ko = '{"api": "NotMine", "version": "X.XX.XX"}'

        def json_patch():
            return json.loads(msg_api_ko)

        with patch(
            "requests.get",
            **{
                "return_value.status_code": 200,
                "return_value.text": msg_api_ko,
                "return_value.json.side_effect": json_patch,
            }
        ) as mock_request:
            self.t.check_url("/api", self.msg_ok, self.msg_ko)
            assert (
                self.t.check_if_last_request_is_a_zou(
                    self.msg_ok,
                    self.msg_ko,
                )
            ) == self.msg_ko

    def test_check_url_with_login_ok(self):
        self.msg_ok = "✅ 01 Check Kitsu auth /api/auth/login"
        self.msg_ko = "🔥 01 Check Kitsu auth /api/auth/login"
        msg_login_ok = '{"login": true}'

        def json_patch():
            return json.loads(msg_login_ok)

        with patch(
            "requests.post",
            **{
                "return_value.status_code": 200,
                "return_value.text": msg_login_ok,
                "return_value.json.side_effect": json_patch,
            }
        ) as mock_request:
            assert (
                self.t.check_url(
                    "/api/auth/login",
                    self.msg_ok,
                    self.msg_ko,
                    {"email": "toto@kitsu", "password": "pass"},
                )
            ) == self.msg_ok
            assert self.t.status == 0
            mock_request.assert_called_once_with(
                "http://127.0.0.1/api/auth/login",
                json={"email": "toto@kitsu", "password": "pass"},
            )

            # Check error status
            self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check error status)"
            self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check error status)"
            assert (
                self.t.check_if_error(
                    self.msg_ok,
                    self.msg_ko,
                )
                == self.msg_ok
            )

            # Check login status
            self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check login status)"
            self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check login status)"
            assert (
                self.t.check_login(
                    self.msg_ok,
                    self.msg_ko,
                )
                == self.msg_ok
            )

            self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check login status)"
            self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check login status)"
            assert (
                self.t.check_bad_login(
                    self.msg_ok,
                    self.msg_ko,
                )
                == self.msg_ko
            )

    def test_check_url_with_login_ko(self):
        self.msg_ok = "✅ 01 Check Kitsu auth /api/auth/login"
        self.msg_ko = "🔥 01 Check Kitsu auth /api/auth/login"
        msg_login_ko = '{"error": true}'

        def json_patch():
            data = json.loads(msg_login_ko)
            print(data)
            return data

        with patch(
            "requests.post",
            **{
                "return_value.status_code": 400,
                "return_value.text": msg_login_ko,
                "return_value.json.side_effect": json_patch,
            }
        ) as mock_request:
            assert (
                self.t.check_url(
                    "/api/auth/login",
                    self.msg_ok,
                    self.msg_ko,
                    {"email": "toto@kitsu", "password": "not_the_pass"},
                )
            ) == self.msg_ko + "\n" + msg_login_ko
            assert self.t.status == 1
            mock_request.assert_called_once_with(
                "http://127.0.0.1/api/auth/login",
                json={"email": "toto@kitsu", "password": "not_the_pass"},
            )

            # Same but with the wrong login expected
            assert (
                self.t.check_url(
                    "/api/auth/login",
                    self.msg_ok,
                    self.msg_ko,
                    {"email": "toto@kitsu", "password": "not_the_pass"},
                    400,
                )
            ) == self.msg_ok

            # Check error status
            self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check error status)"
            self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check error status)"
            assert (
                self.t.check_if_error(
                    self.msg_ok,
                    self.msg_ko,
                )
                == self.msg_ko + "\n" + msg_login_ko
            )

            # Check login status
            self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check login status)"
            self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check login status)"
            assert (
                self.t.check_login(
                    self.msg_ok,
                    self.msg_ko,
                )
                == self.msg_ko + "\n" + msg_login_ko
            )

            self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check login status)"
            self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check login status)"
            assert (
                self.t.check_bad_login(
                    self.msg_ok,
                    self.msg_ko,
                )
                == self.msg_ok
            )

    def test_check_if_last_request_without_request(self):
        # Kitsu
        self.msg_ok = "✅ 01b Check if it's realy a Kitsu"
        self.msg_ko = "🔥 01b Check if it's realy a Kitsu"
        assert (
            self.t.check_if_last_request_is_a_kitsu(
                self.msg_ok,
                self.msg_ko,
            )
        ) == self.msg_ko

        # Zou
        self.msg_ok = "✅ 02b Check if it's realy a Zou"
        self.msg_ko = "🔥 02b Check if it's realy a Zou"

        assert (
            self.t.check_if_last_request_is_a_zou(
                self.msg_ok,
                self.msg_ko,
            )
        ) == self.msg_ko

        # check_if_error
        self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check error status)"
        self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check error status)"
        assert (
            self.t.check_if_error(
                self.msg_ok,
                self.msg_ko,
            )
            == self.msg_ko
        )

        # check_login
        self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check login status)"
        self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check login status)"
        assert (
            self.t.check_login(
                self.msg_ok,
                self.msg_ko,
            )
            == self.msg_ko
        )

        # check_bad_login
        self.msg_ok = "✅ 02 Check Kitsu auth /api/auth/login (check login status)"
        self.msg_ko = "🔥 02 Check Kitsu auth /api/auth/login (check login status)"
        assert (
            self.t.check_bad_login(
                self.msg_ok,
                self.msg_ko,
            )
            == self.msg_ko
        )
