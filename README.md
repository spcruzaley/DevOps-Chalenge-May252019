# Digital OnUs - DevOps Challenge

![alt Digital OnUs](https://www.digitalonus.com/wp-content/uploads/2018/03/cropped-logo.png)


**Ejericio**: Escribir un objeto/controlador de kubernetes para **iniciar una única instancia de PostgreSQL** de acuerdo a lo siguiente:

  - **Username:** postgres
  - **Password:** Aw3s0m3
  - **Database:** WORKSHOP
  - ****Crear la tabla con información **será un plus*****
  - **Directivas:** Si el pod se da de baja, enviar un correo de alerta.

#### Solución propuesta

  - **Kubernetes**
    - Crear un archivo yml con variables de ambeinte (*Datos de conexion y correo*)
    - Crear un archivo yml para generar un storage (*compartir archivos*)
    - Crear un archivo yml para generar el deploy del componente (*PostgreSQL*)
    - Crear un archivo yml para exponer el servicio (*Exponer fuera del contenedor*)
  - **Imagen de PostgreSQL** (*En su version latest*)
  - **Dependencias**
    - Python 2.7 (*Para realizar el envío de correo de alerta*)
    - pip 2 (*Para instalar dependencias del API de Google*)
    - API de Google (*Para la autenticación con Gmail*)

**Se ha generado una imagen con las dependencias necesarias** que será utilizada en este ejemplo, la imagen esta alojada en mi cuenta de **[Docker HUB]**, **sin embargo se provee el archivo Dockerfile** en caso de querer hacer alguna modificación extra.

#### Configuración

##### Instalación de kubernetes
No entraré en detalles sobre la instalación de kubernetes ya que en su página oficial se describe de manera exacta y detallada:

 - **[Instalar docker]**
 - **[Instalar kubectl]**
 - **[Instalar dashboard]** (*Aunque en este caso no lo usaremos*)

##### Configurar cuenta de Gmail
#
#
**`NOTA:`**` Es recomendable `**`estar firmados a su cuenta`**` al ingresar a los enlaces que comentaré más adelante.`

Quizá esta es la parte más confusa de todo el ejercicio, ya que para ello es necesario **generar dos archivos que provee Gmail** para poder envíar correos (*Ademas de muchas otras cosas más*), estos archivos son:

- **credentials.json**
- **token.pickle**

Primero, para generar el archivo ***credentials.json*** nos dirigimos a *[esta página](https://developers.google.com/gmail/api/quickstart/python)*, en la cuál google nos provee de códigos de ayúda para diferentes lenguajes, en mi caso **utilicé python**

**`NOTA:`**` En el caso de enviar correos (`*`Sin importar el lenguaje que utilicemos`*`), debemos `**`ESPECIFICAR EL SCOPE`**` en el cual vamos a trabajar, esto se hace indicando la(s) url(s), en nuestro caso para el envío de email usaremos la URL `*`https://www.googleapis.com/auth/gmail.send`*`, tal como la documentación indica `*`(https://developers.google.com/gmail/api/auth/scopes)`*`.`

![alt google-step-1](http://www.cruzaley-web.com/wp-content/uploads/2019/05/descarga-credentials-json.png)

Y dán click al **botón azul** que dice **ENABLE THE GMAIL API**, el cúal les mostrará la siguiente ventana para descargar el archivo con la configuración de la cuenta gmail con la que están firmados.

![alt google-step-2](http://www.cruzaley-web.com/wp-content/uploads/2019/05/descarga-credentials-json-2.png)

Una vez descargado el archivo ***credentials.json***, debemos generar el script de ejemplo que nos provee google y ejecutarlo, ya que esto va a generar una URL que nos permitirá descargar el siguiente archivo ***token.pickle*** en la ruta en la que estemos trabajando, **la URL generada** será mas o menos como esta:

`https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=2344297242-u9o7v6nvqicg7pp3kri7e3v9hk8nv.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A8080%2F&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fgmail.readonly&state=uSKZmXzu3BITAtkejJHPovvnn&access_type=offline`

![alt google-step-3](http://www.cruzaley-web.com/wp-content/uploads/2019/05/permisos-step-1.png)

![alt google-step-4](http://www.cruzaley-web.com/wp-content/uploads/2019/05/permisos-step-2.png)

![alt google-step-5](http://www.cruzaley-web.com/wp-content/uploads/2019/05/permisos-step-3.png)

Despues de ésta última solicitud de permisos, la página nos redirecciona a una página en blanco que simplemente cerramos.

![alt google-step-6](http://www.cruzaley-web.com/wp-content/uploads/2019/05/permisos-step-4.png)
Ahora, en el directorio desde el cual ejecutamos el script, **deberá haber un archivo llamado token.pickle** con el que completamos la configuración necesaria **para el envío de correos** a través de Gmail

![alt google-step-7](http://www.cruzaley-web.com/wp-content/uploads/2019/05/permisos-step-5.png)

Y eso es todo por la parte de la generación de los archivos de autenticacón con Gmail, **más adelante se describe el funcionamiento**.

##### Generación de scripts para crear tabla y datos en DB
#
Para la creación de la tabla y la inserción de los datos (*Que en realidad solo hice 1 insert, pero pueden ser mas*), utilice una ***propiedad de kubernetes llamada*** **[postStart]**, la cual permite ejecutar *"algo, antes"* de que **EL POD INICIE**.

Por lo cual, en el proceso de arranque del pod (*con el script `start.sh`*), hago una copia del archivo `script-db.sh` y el archivo `create.sql` (*localizados en el directorio db/*) y en la opcion de **[postStart]** se invoca archivo sh el cúal **ejecuta mediante psql** el archivo sql que crea y pobla la tabla.

And... That's it!

##### Generación de scripts para envío de correo
#
Antes de entrar en detalles de esta parte, para poder envíar el correo, utilice una ***propiedad de kubernetes llamada*** **[preStop]**, la cual permite ejecutar *"algo, antes"* de que **EL POD TERMINE**, por lo que en este caso, ejecuté el shell `sendEmail.sh` para el envío del correo, el cual mostraré mas adelante.

Una vez obtenidos los archivos de configuración para poder autenticarnos con Gmail y enviar correos, **toca el turno al componente que hará el envío de estos correos**, para mi caso, **utilicé python** debido a su facilidad de uso, sin embargo, en la página de Google hay ejemplos para **diversos lenguajes** como:

- PHP
- Node JS
- Java
- .NET
- GO
- Ruby

Mi implementación fue algo simple:

- Crear variables de ambiente que serán manejadas por kubernetes, de esta manera los valores **no se setean en código duro** en la imagen, estas variables son:
    - *Correo que envía*
    - *Correo receptor*
    - *Encabezado*
    - *Mensaje*
    - *Password de la cuenta* (*Lamentablemente solo lo pude hacer con texto en claro*)
    - *Directorio de trabajo*, esta variable la agregue debido a problemas al ejecutar los scripts, y ayudo a estandarizar mis pruebas unitarias.
- Crear archivo `sendEmail.sh` que obtniene las variables de entorno seteadas al momento de levantar el pod y ejecuta el siguiente archivo:
- `gmail.py` el cual se encarga de la magia para autenticar con Google y hacer el envío del correo de acuerdo a los datos especificados.

Estos datos se encuentran en el archivo `config/configmap.yml`, lo que nos ayuda a hacer cambios solo a este archivo en caso de querer cambiar el receptor, cuerpo del mensaje, etc.

### Instalación & ejecución

Despues de la teoría, vamos a la ejecución, cabe mencionar que esta propuesta de solución **se basa en una solución que no depende de la infraestrucutra** (*Como debe de ser*), por lo que **se puede ejecutar en Linux, MacOS o Windows** (*Para el caso de Windows, bastará con actualizar el valor de variable `WORK_DIR` localizada en el archivo `configmap.yml`*)

##### Vámos a ello...
#
Una vez descargado el repositorio a tu equipo, bastará simplemente con **ejecuar el shell *`start.sh`***, principalmente el shell se encarga de ejecutar los comandos necesarios de kubernetes, por lo que es probable que tarde un poco debido a que tiene que descargar la imagen que se utilizará.

```sh
$ ./start.sh
```
![alt start 1](http://www.cruzaley-web.com/wp-content/uploads/2019/05/start-new.png)

En caso de que exista algun error con kubernetes, el shell enviara el error con la descripción y dara de baja el pod.

![alt start-stop](http://www.cruzaley-web.com/wp-content/uploads/2019/05/error-starting.png)

Comprobamos que la DB esta en funcionamiento y que, tanto la **base de datos y la tabla se hayan creado** con los datos indicados.

![alt DB](http://www.cruzaley-web.com/wp-content/uploads/2019/05/query-table.png)

Y podemos validar que el pod esta en ejecución con el siguiente comando
```sh
$ kubectl get pods
```

Por último detenemos el pod, ejecuando el siguiente shell, para generar el correo de notificación
```sh
$ ./stop.sh
```
![alt stop](http://www.cruzaley-web.com/wp-content/uploads/2019/05/stop-new.png)

Comprobamos la bandeja de entrada de la cuenta configurada para **recibir las notificaciones**

![alt email 1](http://www.cruzaley-web.com/wp-content/uploads/2019/05/email-1.png)

![alt email 2](http://www.cruzaley-web.com/wp-content/uploads/2019/05/email-2.png)

Es muy probable que esta solución sea un tanto arcaica tomando en cuanta que existen diversas herramientas que permiten hacer eso y más, sin embargo... **funciona** :D !!!

## SPCruzaley

   [Docker HUB]: <https://cloud.docker.com/u/spcruzaley/repository/docker/spcruzaley/postgres-dou-challenge>
   [Instalar docker]: <https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started>
   [Instalar kubectl]: <https://kubernetes.io/docs/tasks/tools/install-kubectl/>
   [Instalar dashboard]: <https://kubernetestutorials.com/how-to-install-kubernetes-dashboard/>
   [postStart]: <https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/#before-you-begin>
   [preStop]: <https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/#define-poststart-and-prestop-handlers>
