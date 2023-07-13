import logging
import os
import sys

from jupyter_client import kernelspec
import requests
from requests.adapters import HTTPAdapter

# pylint: disable=anomalous-backslash-in-string, line-too-long, undefined-variable
c.NotebookApp.open_browser = False
c.ServerApp.token = ""
c.ServerApp.password = ""
c.ServerApp.port = 8080
c.ServerApp.root_dir = "/home/jupyter"


# Additional scripts append Jupyter configuration. Please keep this line.
