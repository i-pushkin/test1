import datetime
from gunicorn.glogging import Logger

class CustomLogger(Logger):

    def now(self):
        return datetime.datetime.now().isoformat(sep=' ', timespec='milliseconds')

logger_class = CustomLogger