# Test de operación

## Introducción

Este repositorio contiene los ficheros necesarios para realizar el test de operación de sistemas. Con este test, se intenta valorar tus conocimientos de linux, docker, y tu capacidad para buscar y entender documentación sobre aplicaciones como [etcd](https://etcd.io/), [PostgreSQL](https://www.postgresql.org/), [Patroni](https://github.com/zalando/patroni) o [HAProxy](https://www.haproxy.com/).

El objetivo del test es simular un cluster de alta disponibidad de *PostgreSQL*, consistente en:

- 2 contenedores ejecutando *PostgreSQL*, en modo activo / standby, con replicación asíncrona. Cada contenedor tendrá instalado tanto *PostgreSQL* como *Patroni*, para gestionar la alta disponibilidad.
- 3 contenedores ejecutando *etcd*, formando un cluster que *Patroni* utiliza como almacén de configuración.
- 1 contenedor ejecutando *HAProxy*, como balanceador de los dos pods de *PostgreSQL*.

Para instanciar este cluster, se utilizan los ficheros [docker-compose-yaml](./docker-compose.yaml) y [Dockerfile](./Dockerfile) de este repositorio:

- El fichero [Dockerfile](./Dockerfile) construye una imagen de *PostgreSQL* versión 12, con los ejecutables de *Patroni*.
- El fichero [docker-compose](https://docs.docker.com/compose/compose-file/compose-file-v3/) describe la pila de contenedores que forma el servicio, con:

  - Los tres nodos de *etcd* (`etcd1`, `etcd2` y `etcd3`)
    - *etcd* utiliza el puerto 2379
  - Los dos nodos de *PostgreSQL* (`postgres1` y `postgres2`)
    - *PostgreSQL* utiliza el puerto 5432
    - *Patroni* utiliza el puerto 8008
  - El nodo de *HAProxy*, que no está definido aún (forma parte del ejercicio).

### Construcción de la imagen

Para construir la imagen docker que se utiliza en este test, necesitarás [docker](https://www.docker.com) y [docker-compose](https://docs.docker.com/compose/docker-compose). Ambos están [disponibles para Windows](https://docs.docker.com/desktop/install/windows-install/), aunque se recomienda utilizar una máquina virtual linux.

Una vez tengas el software instalado y el repositorio clonado, puedes usar el comando:

```
docker-compose build
```

### Ejecución del servicio

Para ejecutar la pila de servicios que se utiliza en este test, puedes usar el comando:

```
docker-compose up
```

### Resultado del test

Para entregar tu respuesta al test, clona este repositorio, y haz sobre los ficheros las modificaciones necesarias para responder las cuestiones que hay más abajo. También puedes añadir nuevos ficheros si los necesitas en alguna cuestión.

Una vez tengas resueltas todas las cuestiones, comprime tu directorio en un zip y envíalo a la dirección de correo electrónico que se te proporcionará.

## Cuestiones

### Configuración de Patroni

La configuración de *Patroni* de los servidores `postgres1` y `postgres2` está en los ficheros [postgres1-conf/patroni.yml](./postgres1-conf/patroni.yml) y [postgres2-conf/patroni.yml](./postgres2-conf/patroni.yml). Ambos directorios se montan como volúmenes, cada uno en su contenedor respectivo, en la ruta `/etc/patroni`.

Ambas configuraciones tienen actualmente valores por defecto para todas las URLs, que en este entorno no son correctos. Si ejecutas los comandos `docker-compose build` y `docker-compose up`, verás errores como los siguientes:

```
postgres2_1  | 2023-04-02 19:27:33,896 ERROR: Failed to get list of machines from http://127.0.0.1:2379/v2: MaxRetryError("HTTPConnectionPool(host='127.0.0.1', port=2379): Max retries exceeded with url: /v2/machines (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7efda25fb910>: Failed to establish a new connection: [Errno 111] Connection refused'))")
postgres2_1  | 2023-04-02 19:27:33,896 INFO: waiting on etcd
```

Revisa las configuraciones de los ficheros [postgres1-conf/patroni.yml](./postgres1-conf/patroni.yml) y [postgres2-conf/patroni.yaml](./postgres2-conf/patroni.yml), y corrige las URLS en las secciones `restapi`, `etcd`, `postgresql` y `pg_hba` para que los pods de *Patroni* puedan comunicarse entre sí, con *PostgreSQL*, y con *etcd*.

### Configuración de privilegios

Una vez hayas corregido las configuraciones de *Patroni* y conseguido que los pods conecten al *etcd*, te encontrarás con este otro error:

```
postgres2_1  | 2023-04-02 19:33:28,891 INFO: trying to bootstrap a new cluster
postgres2_1  | pg_ctl: cannot be run as root
```

Modifica el fichero `docker-compose-yaml` o el `Dockerfile` para que los contenedores de *PostgreSQL* se ejecuten con el usuario correcto.

### Ampliación de Dockerfile

Modifica el fichero `Dockerfile` para instalar la versión 3 de la extensión `postgis` de *PostgreSQL*. No modifiques la versión de *PostgreSQL*, que es la 12.

### Ampliación de docker-compose

Modifica el fichero `docker-compose.yaml` para añadir un contenedor ejecutando *HAProxy* versión 2.7 o superior, y configuralo para escuchar en el puerto 5432 y enviar las conexiones TCP al puerto 5432 de los nodos de *PostgreSQL*. En el repositorio de *Patroni* encontrarás un ejemplo de fichero de configuración para *HAProxy*.

### Documentación

Indica qué comandos has ejecutado para comprobar que tus respuestas son válidas:

1. ¿Qué has hecho para comprobar que el cluster etcd está levantado, y que los tres nodos se ven entre sí?

2. ¿Qué has hecho para comprobar que uno de los servidores postgres está activo, y que el otro está replicando del activo?

3. ¿Qué has hecho para comprobar que puedes conectar a postgres a través del balanceador?

4. ¿Qué has hecho para comprobar que si el contenedor postgres activo cae, el servidor secundario se convierte automáticamente en activo?

5. ¿Qué has hecho para comprobar que después de que el servidor secundario se haya convertido en primario, al conectar de nuevo a través de *HAProxy*, la conexión se establece con el nuevo primario?
