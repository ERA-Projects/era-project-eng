"""
Public Package Control API
"""
import sys

try:
    events = __import__(
        "Package Control.package_control.events",
        fromlist=["Package Control.package_control"],
    )
except Exception:
    if sys.version_info[:2] > (3, 3):
        raise

    from os.path import dirname, join
    from sublime_plugin import ZipLoader

    __zip_path = join(
        dirname(dirname(dirname(__file__))),
        "Installed Packages",
        "Package Control.sublime-package",
    )
    events = ZipLoader(__zip_path).load_module(
        "Package Control.package_control.events"
    )
    del globals()["__zip_path"]
    del globals()["dirname"]
    del globals()["join"]
    del globals()["ZipLoader"]

events.__name__ = "package_control.events"
events.__package__ = "package_control"

if hasattr(events, "__spec__"):
    events.__spec__.name = events.__name__

sys.modules[events.__name__] = events
del globals()["sys"]
