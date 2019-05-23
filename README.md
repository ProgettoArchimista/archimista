## Archimista
Archimista è un'applicazione web open source per la descrizione di archivi storici. È disponibile in due versioni: standalone e server.
La versione corrente è la **3.1.0**.

## Requisiti
Archimista funziona sui sistemi operativi GNU/Linux, Mac OS X, Windows Vista e superiori. Per Windows XP è necessario utilizzare una versione apposita che viene compilata allo scopo.
I requisiti generali dell’applicazione sono i seguenti:
* Ruby 2.1.5
* Rails 4.2.1
* Varie gemme Ruby dichiarate nel file Gemfile
* Gemma rubyzip
* ImageMagick (opzionale, per la gestione di oggetti digitali)
* Database: MySQL (>= 5.1) o PostgreSQL (>= 9.1) o SQLite
* Webserver configurato per applicazioni Rails

## Installazione
Sono disponibili le versioni standalone con un proprio pacchetto di installazione per le versioni windows XP e per le versioni superiori. I pacchetti di installazione sono disponibili su github nella directory releases.
Per la versione server, nel caso di prima installazione:
1. Predisporre il proprio computer con il software indicato nei Requisiti
2. Creare un file di configurazione per il database: config/database.yml. Per maggiori informazioni leggi: [http://guides.rubyonrails.org/v2.3.11/getting_started.html#configuring-a-database](http://guides.rubyonrails.org/v2.3.11/getting_started.html#configuring-a-database)
3. Eseguire il task rake gems:install
4. Eseguire il task RAILS_ENV=production rake db:setup
5. Nel file config/initializers/metadata.rb modificare la variabile BASE_URL inserendo il proprio url di archivista, modificare il file tmp/Configurazione_dl.rb con i dati da usare negli export SAN
6. Avviare il webserver

L'utente per il primo login è:
* user: admin_archimista
* pass: admin_archimista

Nel caso di aggiornamento da versioni precedenti dell'applicazione:
1. Eseguire il task RAILS_ENV=production rake db:migrate
2. Eseguire il task RAILS_ENV=production rake assets:clean

### Installazione in container Docker

Per installare Archimista cross-platform come server locale:

1. Scaricare ed installare [Docker](https://www.docker.com/);
2. installare [git](https://git-scm.com/) e clonare il progetto da github.com:
```bash
git clone https://github.com/ProgettoArchimista/archimista.git
```
3. creare il file di configurazione del database, per esempio:
```yaml
defaultMySql: &defaultMySql
  adapter:    mysql2
  encoding:   utf8
  host:       dbMy
  username:   root
  password:   generic_password
  pool:       5

development:
  <<:         *defaultMySql
  database:   archimista_development

test:
  <<:         *defaultMySql
  database:   archimista_test

production:
  <<:         *defaultMySql
  database:   archimista_production
```
4. creare il file di configuazione dei secrets, per esempio:
```yaml
development:
  secret_key_base: eb49b41d0d03e8b0aa951eb60e213e7d1ab905ec8c276c9b99be1a6cd90665d03e198fe9479f32ce839ed703efe81629388f9488b79d8842d1974bd412b4f2d7

test:
  secret_key_base: 66faed6eedb3e17674c6be1370b3b20913fe9f177f03703e807347026ad3b711b6a05cf9ea42651c3b6d6c82b2064973f2120f4113d54d44b737768e2328e60d

production:
  secret_key_base: 7ec7f033f7d1811f5d4e23351f80eeec6d3142d1cdd2eaceafc71a5951a3446b1507e738de88afb19664491ad6be0e792f9c58714c85abfdb35f031a4ad9dbaf
```
5. eseguire la build tramite Docker Compose:
```bash
docker-compose build
```
6. avviare Docker Compose con il comando start:
```bash
docker-compose up
```

7. eseguire il comando di creazione del database:
```bash
docker-compose exec web rake db:setup RAILS_ENV=production
```

8. spegnere l'applicativo tramite la pressione di ctrl + c.

#### Start applicazione
Per eseguire l'avvio dell'applicazine tramite Docker Compose digitare il comando start:
```bash
docker-compose start
```

#### Stop applicazione
Per fermare archivista eseguire:
```bash
docker-compose stop
```

## Crediti
Archimista è un progetto promosso da:
* [Direzione Generale per gli Archivi](http://www.regione.lombardia.it)
* [ICAR – Istituto Centrale per gli Archivi](http://www.icar.beniculturali.it/)
* [Regione Lombardia, Direzione Generale Istruzione, Formazione e Cultura](http://www.regione.lombardia.it/wps/portal/istituzionale/HP/istituzione/direzioni-generali/direzione-generale-autonomia-e-cultura)
* [Università degli Studi di Pavia](http://www.unipv.eu/site/home.html)
* [Politecnico di Milano](https://www.polimi.it/)
* [Regione Piemonte](https://www.regione.piemonte.it/)

## Autori
Codex Società Cooperativa, Pavia ([http://www.codexcoop.it](http://www.codexcoop.it))
TAI S.a.s. ([http://www.taisas.com](http://www.taisas.com))
Lo sviluppo attuale è curato da INGLOBA360 s.r.l. ([http://www.ingloba360.it](http://www.ingloba360.it))

## Licenza
Archimista è rilasciato sotto licenza GNU General Public License v2.0 o successive.
