import os
import logging
from sys import platform
import warnings

# Lamb Framework
from lamb.utils.logging import inject_logging_factory

logging.captureWarnings(True)
warnings.filterwarnings("default", category=DeprecationWarning, module="django")
warnings.filterwarnings("default", category=DeprecationWarning, module="lamb")
warnings.filterwarnings("default", category=DeprecationWarning, module="oz_gateway")
warnings.filterwarnings("default", category=DeprecationWarning, module="oz_core")
    
PORT = 8880
DEBUG = False
SCHEME = 'http'
ALLOWED_HOSTS = [
    '*'
]
HOST = 'oz-api-nginx'

##database
DB_USER = 'gateway_user'
DB_HOST = 'oz-api-pg'
DB_PORT = '5432'
DB_PASS = 'Aa12345aA!'
DB_NAME = 'gateway'
DB_ENGINE = 'django.db.backends.postgresql'
DB_CONNECT_OPTS = None

OZ_FFMPEG_BINARY = '/usr/bin/ffmpeg'
OZ_SERVICE_TFSS_HOST = 'http://192.168.0.33:8501/v1/'
OZ_BUNDLE_TFSS_HOST = 'https://192.168.0.33:8501/v1/'

OZ_SERVICE_REGULA_HOST = 'https://regula.rc.qa.ozforensics.ai/'
OZ_SERVICE_REGULA_SEARCH_STRINGENCY =  'moderately'

OZ_SERVICE_TFSS_SLICING = {
    'podium_a': {
        'mode': 'rate',
        'value': 25
    },
    'podium_src_a': {
        'mode': 'rate',
        'value': 10
    },
    'inquisitor_a': {
        'mode': 'rate',
        'value': 10
    }
}

CELERY_BROKER_URL = 'redis://:ozapipass@oz-redis:6379/1'
OZ_REDIS_THROTTLING_NODE = 'redis://:ozapipass@oz-redis:6379/3'
OZ_REDIS_ANALYZES_NODE = 'redis://:ozapipass@oz-redis:6379/2'
CELERY_RESULT_BACKEND = 'redis://:ozapipass@oz-redis:6379/0'

OZ_EXTERNAL_REQUEST_TIMEOUT = 240
OZ_CELERY_RETRY_MAX_COUNT = 0
OZ_CELERY_RETRY_STEP = 30
#OZ_ANALYSE_PROCESSING_EXPIRE_TIMEOUT = 1 * 30

OZ_VIDEO_DURATION_MAX = 6
OZ_ATTACHMENT_MAX_SIZE = 10 * 1024 * 1024
OZ_SERVICE_TFSS_PODIUM_FRAME_COUNT = 50
OZ_SESSION_TTL = 60 * 60 * 24 * 365

OZ_CELERY_HEALTH_CHECK_QUEUES = [ "default", "maintenance", "preview_convert", "resolution", "tfss", "regula" ]
OZ_HEALTH_CHECK_CELERY_TIMEOUT = 10
OZ_HEALTH_CHECK_TASK_TIMEOUT = 5

# LAMB core overrides
LAMB_RESPONSE_DATE_FORMAT = "%Y-%m-%d"
LAMB_LOG_LINES_FORMAT = "PREFIX"
LAMB_DEVICE_DEFAULT_LOCALE = "en_US"
LAMB_DEVICE_INFO_LOCALE_VALID_SEPS = ("_", "-")
LAMB_EXECUTION_TIME_LOG_TOTAL_LEVEL = logging.INFO
LAMB_EXECUTION_TIME_SKIP_METHODS = "OPTIONS"
LAMB_RESPONSE_ENCODER = "lamb.json.encoder.JsonEncoder"
LAMB_RESPONSE_JSON_INDENT = None
LAMB_RESPONSE_JSON_ENGINE = None
LAMB_RESPONSE_DATETIME_TRANSFORMER = "lamb.utils.transformers.transform_datetime_milliseconds_float"
LAMB_DEVICE_INFO_HEADER_FAMILY = "HTTP_X_LAMB_DEVICE_FAMILY"
LAMB_DEVICE_INFO_HEADER_PLATFORM = "HTTP_X_LAMB_DEVICE_PLATFORM"
LAMB_DEVICE_INFO_HEADER_OS_VERSION = "HTTP_X_LAMB_DEVICE_OS_VERSION"
LAMB_DEVICE_INFO_HEADER_LOCALE = "HTTP_X_LAMB_DEVICE_LOCALE"
LAMB_DEVICE_INFO_HEADER_APP_VERSION = "HTTP_X_LAMB_APP_VERSION"
LAMB_DEVICE_INFO_HEADER_APP_BUILD = "HTTP_X_LAMB_APP_BUILD"
LAMB_DEVICE_INFO_HEADER_APP_ID = "HTTP_X_LAMB_APP_ID"
LAMB_DEVICE_INFO_COLLECT_IP = False
LAMB_DEVICE_INFO_COLLECT_GEO = False
LAMB_ERROR_OVERRIDE_PROCESSOR = None
LAMB_PAGINATION_KEY_OMIT_TOTAL = "total_omit"
LAMB_VERBOSE_SQL_LOG = False
#LAMB_VERBOSE_SQL_LOG_THRESHOLD = None

LANGUAGE_CODE = "en"
TIME_ZONE = "Etc/UTC"

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LAMB_LOG_FOLDER = os.path.join(BASE_DIR, "log")

inject_logging_factory()
# loggers
LOGGING = {
"version": 1,
"disable_existing_loggers": False,
"formatters": {
    "verbose": {
        "class": "lamb.utils.logging.LambFormatter",
        "format": "[%(asctime)s: xray=%(trace_id)s, user_id=%(gw_user_id)s: %(levelname)8s] <%(name)s:%(filename)s:%(lineno)4d>  %(message)s ",
    },
    "simple": {
        "class": "lamb.utils.logging.LambFormatter",
        "format": "[%(asctime)s: xray=%(trace_id)s, user_id=%(gw_user_id)s: %(levelname)8s] %(message)s",
    },
},
"filters": {"oz_context": {"()": "oz_core.logging.OzContextFilter"}},
"handlers": {
    "console": {
        "level": "DEBUG", 
        "class": "logging.StreamHandler",
        "formatter": "simple",
        "filters": ["oz_context"],
    },
},
"loggers": {
    "django": {"handlers": ["console"], "propagate": True, "level": "DEBUG" },
    "py.warnings": {"handlers": ["console"], "propagate": True, "level": "DEBUG" },
    "api": {"handlers": ["console"], "propagate": True, "level": "DEBUG" },
    "oz_core": {"handlers": ["console"], "propagate": True, "level": "DEBUG" },
    "lamb": {"handlers": ["console"], "propagate": True, "level": "DEBUG" },
    "services": {"handlers": ["console"], "propagate": True, "level": "DEBUG" },
    "oz_core.ext.regula": {"handlers": ["console"], "propagate": False, "level": "INFO" },
},
 
}

# O2N 
OZ_SERVICE_O2N_HOST = "http://oz-api-o2n:8010/"
# OZ_SERVICE_O2N_HOST = "http://{{ include "oz.name" (list . $.Values.Params.o2n.appName) }}-{{ $.Values.Params.global.suffixes.service }}:{{ $.Values.Params.o2n.service.svcPort }}/"
# OZ_SERVICE_O2N_SEARCH_THRESHOLD = {{ $.Values.Params.o2n.OZ_SERVICE_O2N_SEARCH_THRESHOLD }}
# OZ_SERVICE_O2N_SEARCH_LIMIT = {{ $.Values.Params.o2n.OZ_SERVICE_O2N_SEARCH_LIMIT }}