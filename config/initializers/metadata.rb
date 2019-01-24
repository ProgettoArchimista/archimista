# Application metadata
APP_NAME = "Archimista"
APP_VERSION = "3.1.0"
APP_STATUS = ""
AEF_COMPATIBLE_VERSIONS = [110, 120, 121, 200, 210, 211, 220, 300, 301, 302, 310]
APP_CREATOR = "INGLOBA360 srl"
APP_EDITION = "server" # server | standalone | hub
IM_ENABLED = DigitalObject.is_enabled?

DEST_DIR = "."

# Sistema aderente SAN.
PROVIDER = "ARC-ICAR"

# Url base
BASE_URL = "http://archivista.icar.beniculturali.it/"

# Url base dei complessi archivistici.
FONDS_URL = "#{BASE_URL}/fonds"

# Url base dei soggetti produttori.
CREATORS_URL = "#{BASE_URL}/creators"

# Url base dei soggetti conservatori.
CUSTODIANS_URL = "#{BASE_URL}/custodians"

# Url base delle fonti archivistiche.
SOURCES_URL = "#{BASE_URL}/sources"

# Url base delle unità archivistiche.
UNITS_URL = "#{BASE_URL}/units"

# Url base degli oggetti digitali.
DIGITAL_OBJECTS_URL = "#{BASE_URL}/digital_objects"

# Url base dei profili documentari.
DOCUMENT_FORMS_URL = "#{BASE_URL}/document_forms"

# Url base dei profili istituzionali.
INSTITUTIONS_URL = "#{BASE_URL}/institutions"

# ICAR-IMPORT dati statici
ICAR_IMPORT_SYSTEM_TITLE = "Archimista ICAR"
ICAR_IMPORT_CONTACT_MAIL = "email@archimista.it"
ICAR_IMPORT_FILE_DESC_TITLE = "Export ICAR-IMPORT"
ICAR_IMPORT_FILE_DESC_ABSTRACT = "Esportazione complesso archivistico."
