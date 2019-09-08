from django.test import TestCase

from djangochaos.tests.tests_admin import ChaosAdminMixin
from djangochaos import mock_data


mockfn = mock_data.make_action_response


class ChaosAdminDBTest(ChaosAdminMixin, TestCase):
    modelstr = "chaosactionresponse"

    def _call_mockfn(self, *args, **kwargs):
        # Avoid wildcard actions in tests
        if "act_on_url_name" not in kwargs:
            kwargs["act_on_url_name"] = "default_mock_view"
        return globals()["mockfn"](*args, **kwargs)
