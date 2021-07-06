Applicazioni Archimista/Archivista Dockerizzate
===============================================

Manuale per l'installazione e l'uso su personal computer o server (host) delle applicazioni dockerizzate di Archimista e Archivista.


Installazione Docker Engine e Docker compose
--------------------------------------------

- Su sistemi Windows o Mac installare Docker Desktop seguendo le istruzioni di:
  - https://docs.docker.com/desktop/

- Su sistemi Linux:
  - Installare la versione più recente di Docker Engine seguendo le istruzioni di:
    - https://docs.docker.com/engine/install/

  - Installare la versione più recente di Docker Compose seguendo le istruzioni di:
    - https://docs.docker.com/compose/install/



Verifica dell'installazione di Docker Engine
--------------------------------------------

In una finestra di terminale o prompt dei comandi

- per verificare la versione di Docker Client e Docker Engine installate, digitare:

      docker version


- per verificare la versione di Docker Compose installata, digitare:

      docker compose version     (Windows)

      docker-compose version     (Linux)


NOTA BENE: la sintassi dei comandi Docker Compose differisce per sistemi Windows e Linux

  Per sistemi Windows il comando base è:

    docker compose

  mentre per sistemi Linux è:

    docker-compose

  negli esempi che seguono si userà la sintassi Windows che, per sistemi Linux, dovrà essere adattata come sopra indicato



Verifica del corretto funzionamento del Docker Engine
-----------------------------------------------------

In una finestra di terminale o prompt dei comandi digitare:

    docker run hello-world

  se le prime righe dell'output a terminale sono le seguenti:

    Hello from Docker!
    This message shows that your installation appears to be working correctly.

  allora Docker funziona correttamente sulla vostra macchina



Operazioni preliminari all'avio del progetto dockerizzato
---------------------------------------------------------

- creare sulla macchina host una directory in cui dovrà essere copiato il file yaml per l'avvio del progetto Archimista/Archivista dockerizzato

      Es: mkdir dockerarchimista

- copiare il file docker-compose.yml nella cartella appena creata

- nel terminale spostarsi nella cartella appena creata

      Es: cd dockerarchimista


NOTA BENE: TUTTE le operazioni di installazione, avvio, stop e rimozione del progetto dockerizzato di seguito descritte dovranno essere effettuate digitando comandi in una finestra di terminale o prompt dei comandi mentre ci si trova nella directory di cui sopra



Primo avvio del progetto Archimista/Archivista dockerizzato
-----------------------------------------------------------

nel terminale digitare:

    docker compose up -d


NOTA BENE: durante il primo avvio vengono scaricate le immagini del progetto da Docker Hub (https://hub.docker.com/u/icar2021), vengono inoltre creati i container per l'esecuzione delle immagini e i volumi (dischi virtuali) per la persistenza dei dati, vengono infine avviati i server web e MySQL

È necessario attendere qualche minuto perché tutte le operazioni vengano completate



Inizializzazione del Database di Archimista
-------------------------------------------

Per inizializzare il Database di Archimista digitare:

    docker compose exec web rake db:reset


NOTA BENE:

- l'inizializzazione del database comporta la perdita dei dati presenti nel databasee di Archimista 

- se durante l'inizializzazione si ottengono messaggi d'errore, fra cui:

    #<Mysql2::Error: Can't connect to MySQL server on 'db' (111 "Connection refused")>

  è possibile che il server di Database MySQL non sia ancora pronto ad accettare connessioni, per cui è necessario attendere qualche minuto prima di riprovare con il comando di inizializzazione del Database



Accesso ad Archimista e Archivista via web
------------------------------------------

NOTA BENE: per impostazione predefinita il progetto Archimista/Archimista dockerizzato usa, rispettivamente, le porte TCP 80 e 8080 per servire gli applicativi web di Archimista e Archivista.
Queste porte devono essere libere e disponibili sulla macchina host per il corretto avvio del progetto.

Puntare un browser web al localhost della macchina che ospita il progetto dockerizzato alle URL:

- per Archimista:

    http://localhost

- per Archivista:

    http://localhost:8080  



Stop dei container
------------------

Per fermare l'esecuzione dei container docker e dei server web e MySQL digitare:

    docker compose stop


NOTA BENE: allo spegnimento della macchina host i container vengono fermati automaticamente



Avvio dei container
-------------------

Per avviare i container fermi digitare:

    docker compose start


NOTA BENE: per impostazione predefinita i container vengono avviati automaticamente dal Docker Engine all'avvio della macchina host



Stop e rimozione dei container
------------------------------

Per fermare i container ed eliminarli digitare:

    docker compose down 


NOTA BENE: la rimozione dei container non comporta la perdita dei dati (es: dati nel database) presenti nei volumi di storage persistente, né comporta la rimozione delle immagini Docker dall'host



Nuova creazione dei container dopo la rimozione
-----------------------------------------------

Per ricreare i container dopo la loro rimozione digitare:

    docker compose up -d 


NOTA BENE: se in precedenza vi erano dati nei volumi di storage persistenti e se i volumi di storage non sono stati rimossi, allora i dati saranno recuperati.



Eliminazione dei volumi di storage persistente
----------------------------------------------

Per ottenere la lista dei volumi di storage usati dal progetto digitare:

    docker volume ls

Per cancellare un volume:

    docker volume rm <nome_volume>

Esempio:

    docker volume ls
    
    DRIVER    VOLUME NAME
    local     dockerarchimista_app_public
    local     dockerarchimista_db


    docker volume rm dockerarchimista_app_public

    docker volume rm dockerarchimista_db


NOTA BENE:

- l'eliminazione dei volumi di storage è possibile solo dopo aver rimosso i container che li usano

- l'eliminazione dei volumi di storage comporta la PERDITA DEI DATI memorizzati in Archimista (es: dati nel Database, oggetti digitali)
