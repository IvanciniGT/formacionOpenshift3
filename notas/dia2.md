
# Empaquetar una app propia como imagen de contenedor

Yo tengo mi código:
- App JAVA JEE (microservicio-Springboot)
  - Antiguamente se generaba un .war | .ear -> Servidor de aplicaciones (Tomcat, JBoss, Wildfly, Weblogic, Websphere) -Capa middleware-
  - Hoy en día: -> .jar (autoejecutable), que lleva embebido un servidor de aplicaciones (Tomcat, Jetty, Undertow) 
    -> Meter nuestro programa (artefacto) en una imagen de contenedor (Dockerfile) -> Imagen de contenedor (.tar) -> Registry -> Contenedor

- App Web frontal (Angular)
  - Al empaquetarlo tengo una carpeta llena de ficheros HTML, JS, CSS...
  - Lo paso a un servidor web (nginx)
  - Monto una imagen de contenedor, basada en la imagen de nginx y le meto mi código... y esa imagen la subo a un registro de imágenes de contenedores

Este proceso era muy artesanal... en el hecho de crearlo... pero una vez creado, se automatiza su ejecución.
- Tenía que crear los fichero Dockerfile
- Configurar un pipeline de CI/CD (Jenkins, Gitlab CI/CD, AzureDevops)
  - Tenía que ejecutarlos
  - Tenía que subirlos a un registro de imágenes de contenedores

Esa configuración, me la regala un Openshift.
A Openshift le puedo dar mi repo de git, con mi código y él se encarga de todo lo demás:
- Crear un Dockerfile
- Crear un pipeline de CI/CD
- Ejecutarlo
- El resultado subirlo a un registro de imágenes de contenedores dentro de mi propio cluster de Openshift
- Crear luego pods con esos contenedores desde mi propio registro de imágenes de contenedores

---

# DEVOPS

Es un movimiento en pro de la automatización.
Al automatizar me quito problemas de comunicación entre los equipos de desarrollo y operaciones.

Hay mucha automatización... y con cosas como Openshift más aún: Automatizo la generación de los automatismos.
Evidentemente, no es lo mismo un traje a medida que una camiseta del Primark.

Hoy en día, montamos servidores de aplicaciones en contenedores... BBDD en contenedores... servidores web en contenedores... y todo eso lo automatizamos desde plantillas (Helm Charts, Operator Framework). No están tuneadas... No van finas... pero funcionan.
No puedo esperar el mismo rendimiento, ni configuración que cuando antes tenía a un ti@ que me lo configuraba todo a medida (DB Amin, Middleware)
Lo resolvemos a golpe de CPU y RAM.
La misma app que antes necesitaba 8 cores y 20 Gbs... ahora necesita 16 cores y 40 Gbs.
Me sale mucho más caro... pero me ahorro: 
- Los tios de operaciones

JAVA... es un lenguaje que genera un destrozo en RAM de cojones. La misma app hecha en C++ requiere la mitad o menos de RAM... pero también requiere el doble de horas de desarrollo de tios que tengan más conocimientos de programación.

---

# Imágenes de contenedor

Las imagenes se depositan y extraen de Registros de Repositorios de Imágenes de Contenedores (Docker Hub, Azure Container Registry, Google Container Registry, Amazon Elastic Container Registry, Quay.io, Gitlab Container Registry, Artifactory, Nexus).

Las imágenes se identifican mediante una URL:
    registry/repo:tag
    Por ejemplo: docker.io/library/ubuntu:latest
                 docker image pull artefactos.iochannel.tech/ivancinigt/iochannel-ssh-container:latest

Muchas veces omitimos el registry.. en ese caso, el gestor de contenedores que tenga instalado, tendrá configurado unos registros por defecto. Por ejemplo, Docker tiene configurado por defecto Docker Hub. Podman tiene configurado por defecto Docker hub y Quay.io.

## Tag: latest

Eso es una palabra mágica que hay en el mundo de los contenedores o algo?
Si pongo latest, que me descargue la última que se haya subido al repo?
La etiqueta latest es una etiqueta más.. que puede incluso no existir en un repo. De hecho se considera una mala practica el usar etiqueta latest.

# Network Policy

Reglas de firewall a nivel de red para los pods.

- Ingress: Entrada
- Egress: Salida

Para cada tipo de pod, de cada namespace, se puede definir una Network Policy:
- A que direcciones puede acceder el pod
- Desde que direcciones puede ser accedido el pod

Namespace: Miproyecto
    - Pod BBDD -> Solo puede ser accedido por los pods de la aplicación (de los del mismo namespace)
    - Pod App  -> Solo puede acceder a la BBDD y pueden ser accedidos por el ingress del cluster

Lo cierto es que se usan cada vez menos. No porque sean poco importantes. SON MUY IMPORTANTES... de no hacerlo, dejo unos huecos de Seguridad muy grandes.
El problema es que con las arquitecturas de diseño de sistemas que usamos hoy en día, con microservicios, es una locura mantener las Network Policies al día.
Acabamos con literalmente cientos, sino miles de Network Policies... y mantenerlas al día es una locura.

---

SELINUX:
Nos permite definir restricciones en la ejecución de programas, acceso a ficheros, sockets, puertos, etc.
Lo que hacemos es configurarlo en modo permissivo y SELINUX va registrando todas las operaciones que se van realizando.
Luego le pido un listado de ellas... Y compruebo:
- Esta si
- Esta no
- Esta si
- Esta si
- Esta si
- Esta no
Lo pongo en modo enforcing y le digo que me aplique esas reglas.

De vez en cuando él me saca un listado de las nuevas cosas que ha visto... y yo las añado a mi lista de reglas.

---

# Storage Classes

Yo dije ayer que los pv los crean los sysadmins. Pero eso es cierto? Hoy en día no... antes si.
Hoy en día, los sysadmin del cluster lo que hacen es instalar un provisionador dinámico de volumenes de almacenamiento.
Ese provisionador generará VOLUMENES dinámicamente en un BACKEND: 
- NFS
- Cabina de de almacenamiento (LUN)
- Cloud: IBM , Azure

Yo puedo instalar multiples provisionadores de volumenes de almacenamiento en un cluster de kubernetes, con distintas configuraciones... y cada uno lo identifico con un StorageClass.

Cuando para una app se solicita un volumen de almacenamiento (PVC), se solicita para un StorageClass concreto.


---

# Routes

                   PROXY REVERSO     IP BALANCEO        PROCESO en ejecución dentro del contenedor
Cliente -https-> IngressController -> Service       ->  Pod -> nginx :8080

        https                           https
       --------->                  --------------------------->

       ------------https (passthrough)------------------------>

La route es un ingress + configuración automática en DNS público.

---

# Service Account

Un service account es un TOKEN que lleva parejo una asignación de roles y cluster roles... (con sus correspondientes permisos)
que es necesario presentar cada vez que quiera comunicarme con el API Server.

Ese TOKEN, se lo puedo entregar a una persona, a un proceso(Que esté corriendo en un contenedor de un pod)... y con él podrá hacer peticiones al API Server.
Nosotros como humanos, al acceder al dashboard, o conectarnos mediante kubectl necesitamos un token...
en el caso de contar mediante kubectl, ese token se encuentra en ~/.kube/config

Los permisos los definimos en os ROLES o CLUSTER ROLES.
Las asignaciones de permisos se hacen mediante ROLE BINDING o CLUSTER ROLE BINDING.

Hay muchos programas que también requieren de un service account para poder comunicarse con el API Server.... Depende del programa que yo haga.

Si monto una aplicación web, funcionando sobre NGINX, posiblemente mi app web no necesite interactuar con el API de kubernetes... y no necesite un Service Account para nada.
Si por ejemplo estoy desarrollando un Operador que permita hacer creación dinámica de PVs en base a PVCs, si necesitaré un Service Account.

Ese programa está mirando los pvcs que hay en el cluster en cualquier namespace

$ kubectl get pvc --all-namespaces --watch

Y puedo montar un programa que este haciendo ese trabajo...
Y cuando identifique en esa lista uno nuevo, entonces solicitar a kubernetes que genere un pv para ese pvc.
- Crea un volumen en una cabina de almacenamiento (Comandos de BASH... Usando unos drivers de la cabina de almacenamiento)
- Una vez creado ese volumen en la cabina, crear un pv en kubernetes:
  - Crear un YAML con la información del pv 
    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-1
    spec:
      capacity:
        storage: 1Gi
      accessModes:
        - ReadWriteOnce
      // Info concreate del volumen físico
      ```
  -$ kubectl apply -f pv-1.yaml

Claro.. para eso, mi programa tiene que contar con permisos para poder hacer esas actividades contra mi cluster de kubernetes.

```yaml
# Crear un service account para el programa
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mi-programa
---

# Crear un cluster role para el programa
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: mi-programa

rules:
- apiGroups: [""]
  resources: ["persistentvolumes"] # Los pv son objetos que van asociados a NameSpaces en Kubernetes? NO
  verbs: ["create", "delete", "get", "list", "watch"]
---
# Crear un role para el programa
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: mi-programa
  namespace: proyecto

rules:
- apiGroups: [""]
  resources: ["persistentvolumesclaim"]
  verbs: ["get", "list", "watch"]
---

# Asignar el cluster role al service account
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mi-programa

subjects:
- kind: ServiceAccount
  name: mi-programa
  namespace: default

roleRef:
  kind: ClusterRole
  name: mi-programa
  apiGroup: rbac.authorization.k8s.io

---

# Asignar el role al service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: mi-programa
  namespace: proyecto

subjects:
- kind: ServiceAccount
  name: mi-programa
  namespace: default

roleRef:
  kind: Role
  name: mi-programa
  apiGroup: rbac.authorization.k8s.io
```

Posteriormente, al crear un POD, al pod le asocio el service account.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mi-pod
spec:
  containers:
  - name: mi-contenedor
    image: mi-imagen
  serviceAccountName: mi-programa
```

En Openshift TODO POD tiene un Service Account asociado por defecto.
A mi me interesará controlar que permisos tiene ese Service Account por defecto.
Más bien añadir un Service Account con permisos específicos para los pods de una aplicación concreta.

Y por defecto, el service account que use no tiene permisos para hacer nada.

---

En Openshift de forma nativa tenemos la opción de configurar repositorios de usuarios de LDAP o de Active Directory o internos de Openshift.
También nos permite federar con otros sistemas de autenticación (Oauth, Github)

A cada usuario le asigno es una serie de roles y de cluster roles... de hecho un usuario es una extensión de un service account,
que me permita obtener el service account mediante un proceso de autenticación.

Habrá una diferencia muy clara entre usar un repositorio de usuarios o en utilizar un sistema de autenticación federado.

LDAP o un Active Directory no es sino una BBDD de usuarios.. con un esquema predefinido.
A un LDAP o un Active Directory le ataco mediante una sintaxis distinta de SQL... pero es una BBDD.
Necesito una cadena de conexión al ldap o al AD... con su protocolo:
- En las BBDD Normales, me pasa lo mismo: jdbc:mysql://localhost:3306/mibbdd
- En LDAP: ldap://ldapserver:389/

En lugar de SQL se usa una sintaxis de búsqueda de objetos (LDAP Query Language): Las BBDD LDAP son jerárquicas...
- (uid=ivancinigt)
- Los usuarios de una unidad organizativa: (ou=usuarios, dc=ivancinigt, dc=tech)

Al final, la autenticación se la come Openshift... Openshift le pide al LDAP el listado de usuarios que contiene y sus contraseñas.
Y Openshift se encarga de autenticar a los usuarios.

Muy diferente es cuando trabajamos con un sistema de autenticación federado: SAML, Oauth.

En ese caso, la autenticación la hace el sistema federado... y me devuelve un token de autenticación.
En este caso Openshift no tiene que autenticar a los usuarios... solo tiene que validar/usar el token que le llega del sistema federado que se encarga de la autenticación.

Una configuración mediante LDAP es más sencilla... pero menos flexible. y potente.

En organizaciones solemos montar nuestros propios sistema de autenticación: IAM (Identity Access Management - Keycloak: Redhat)

  Openshift -> Keycloak -> LDAP
                        -> Active Directory
                        -> Estar federado contra un sistema de autenticación de Google, Github, Facebook

Por ejemplo en Keycloak puedo establecer/forzar políticas de contraseñas, autenticación por doble factor, etc.

Esto también puede hacerse con Kubernetes... pero me lo curro yo.
