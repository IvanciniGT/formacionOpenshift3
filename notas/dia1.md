# Kubernetes

Es un orquestador de gestores de contenedores apto para entornos de producción.
Lo componen una colección grande de programas. -> Servicios a nivel de SO + Corren como contenedores dentro del propio cluster = Plano de control

  Cluster de Kubernetes
    - Nodo1 \
    - Nodo2  | Plano de control (Scheduller, Etcd, Api server, Controller manager...)
    - Nodo3 /
      - CRIO / ContainerD <- Gestionan los contenedores... y a su vez, son gestionados por Kubernetes
    - Nodo trabajo 1      
      - CRIO / ContainerD
    - Nodo trabajo 2
      - CRIO / ContainerD
    - Nodo trabajo 3
      - CRIO / ContainerD
    - Nodo trabajo n
      - CRIO / ContainerD

Hay muchas distros de kubernetes. Kubernetes responde a un estándar, que describe la funcionalidad mínima que debe tener un entorno para poder hacerse llamar kubernetes.
- K8S: Kubernetes
- K3S: Distro ligera de kubernetes
- Minikube: Entorno de desarrollo
- OKD: Openshift Origin
- Openshift Container platform : Distro de Kubernetes de Redhat
- Karbon: Distro de Kubernetes de Nutanix
- Tanzu: Distro de Kubernetes de VMware
- AKS: Distro de Kubernetes de Azure
- EKS: Distro de Kubernetes de AWS
Cada distro aporta cierto valor sobre el estándar de kubernetes.

# Redhat

Es una compañía que sigue una clara política con respecto a sus productos:
- Todo ellos son opensource
- Y tienen 2 versiones: 
  - Una de pago: Modelo basado en suscripción... que incluye soporte, documentación y algunas funcionalidades extra.
        ^^^^ 
  - Otra gratuita: Nuevas funcionaliadades aún no presentes en la versión de pago, pero que se espera que en un futuro lo estén. (PROYECTOS UPSTREAM)

    FEDORA -> REDHAT ENTERPRISE LINUX (-> CENTOS)
    WILDFLY -> JBOSS
    Ansible Project -> Ansible Engine
    AWX -> Ansible Tower
    OPENSHIFT ORIGIN (OKD) -> OPENSHIFT CONTAINER PLATFORM

# OKD

Es la versión gratuita de Openshift Container Platform... su proyecto upstream.

Esto no es un kubernetes al uso... va muy cargado de nuevas funcionalidades.
Eso implica que su forma de instalarlo y configurarlo es diferente a la de un kubernetes normal.
De hecho hay limitaciones importantes en cuanto a infraestructura:
- No puedo instalarlo en un solo nodo, al menos necesito 3 nodos.

Hay una versión gratuita para desarrolladores... más limitada en funcionalidades, pero que me permite instalarlo en un solo nodo y jugar, aprender y desarrollar con él: MINISHIFT


# Openshift, OKD

Openshift es la distro de Kubernetes de la gente de Redhat.
Aquí encontramos lo que es un kubernetes normal, según el estándar, pero con un montón de cosas añadidas: Kubernetes VITAMINIZADO !!!
- Soporte / Documentación
- Entorno gráfico mejorado.
- Politicas de seguridad más restrictivas
- Tienda de operadores
- Gestión de usuarios
  - Repos de usuario (locales)
  - Federados (LDAP, AD, Github, Gitlab...)
  - Roles y permisos a nivel de usuario -> Proyectos
- Proyectos ~ Namespace
- Escalado de Máquinas:
  - Node: Objeto estandar de kubernetes se refiere a una instancia en ejecución de un nodo con kubernetes: kubelet.
  - Machine: Objeto de Openshift que se refiere a una máquina física, que puede tener un kubernetes corriendo en ella o no.
  - MachineSet: Me permiten crear máquinas de forma automática, basadas en un template.
  - MachineAutoscaler: Me permite escalar el número de máquinas de forma automática, basado en la carga de trabajo.
- Route: Extensión de lo que es un INGRESS. Es un INGRESS ( Configuración de un proxy reverso ) + Configuración auto. de un certificado SSL + Configuración auto. de un DNS.
- Clusters federados: Cluster de clusters
- Gestión y generación de Imagenes de contenedores

---

# Entorno de producción:

- HA              \
- Escalabilidad   /  Cluster: Entornos + Procesos
- Seguridad
                                                                                      DNS                             CLIENTE
          Nodo1
            Pod1
              Contenedor1- IBM Liberty   <-----+- Balanceador <------- Proxy Reverso               <----- Proxy ----- Federico
              Contenedor2                      |                      (proteger el backend)         (proteger el origen)
          Nodo2                                |                        - Apache httpd
            Pod1-Copia                         |                        - Nginx
              Contenedor1- IBM Liberty   <-----+                        - HAProxy         
              Contenedor2                                               - Envoy
          Nodo3

## Escalabilidad:

Ajustar la infra a las necesidades de cada momento.
- Escalado vertical:   Aumentar o disminuir los recursos de un entorno
- Escalado horizontal: Aumentar o disminuir el número de nodos de un cluster

---

# Configuración de kubernetes

En los cluster de kubernetes, las configuraciones se realizan mediante OBJETOS DE CONFIGURACION que cargamos en el cluster.
Kubernetes (el estandar) define un montón de objetos de configuración que podemos utilizar para configurar nuestro cluster.
Y también define, cómo puedo crear nuevos tipos objetos de configuración: CRD (Custom Resource Definition).
Y al final, eso es lo que hacen las distros de kubernetes: 
- Fijar una configuración base, que incluye:
  - IngressController
  - Dashboard
  - Provisionador dinamico de almacenamiento
  - Provisionador dinamico de Certificados SSL
Añadir nuevos objetos de configuración, para poder configurar el cluster de una forma más sencilla. En el caso de OS:
- Machine
- MachineSet
- MachineAutoscaler
- Route
- User
- Project
- ...

## Objetos configurables en Kubernetes

- Service           = Balanceador de carga
- IngressController = Proxy reverso
- Ingress           = Configuración de proxy reverso (IngressController)
- PVC
- NetworkPolicy
- HPA: Horizontal Pod Autoscaler = Escalabilidad horizontal: Aumentar o disminuir el número de pods que tengo para un determinado servicio
  ^ Qué problema me puedo encontrar? Yo le digo a Kubernetes... Vete creando hasta 50 pods si te hace falta... cada uno con 8Gbs de RAM y 2 cores.
    Me puede pasar que en un momento pete el cluster de pods... que tengan bloqueados los recursos... y no pueda crear más pods.
    Solo he podido crear 21 pods... y no puedo crear más... porque no tengo recursos físicos: RAM, CPU, Disco... Y AHORA QUE?
    Quiero jugar con el número de nodos... quiero poder tener más nodos, cuando necesite más recursos físicos... para poder ejecutar más pods.
    O menos, cuando no necesite tantos recursos físicos.
    Y en kubernetes... no puedo hacerlo... de forma automatizada... En manual SI... pero en automático NO.
---

## Plano de control de Kubernetes
                                                                                      INSTANCIAS
- Scheduler             Busca el nodo idoneo para despegar un pod                         1-2
- Etcd                  BBDD de kubernetes                                                 3
- CoreDNS               DNS de la red interna de kubernetes                               1-2
- Controller Manager    Todo el trabajo pesado:                                           1-2
                         - Monitorización de los nodos
                         - Monitorización de los pods
                         - Monitorización de los servicios
                         - Da la órdenes de crear un pod, o configurar un servicio        1-2
- API Server            Expone la API de kubernetes <---- kubectl                         1-2
- KubeProxy             Mantiene la configuración (reglas de red) de los servicios 
                        y comunicaciones internas                                         1 por nodo
- Kubelet               Corre como un servicio a nivel de SO...                           1 por nodo
                        y es el que se encarga de gestionar los gestores de
                        contenedores (CRIO, ContainerD)

---
# Contenedor

Es un entorno aislado dentro de un SO que corra un kernel LINUX donde ejecutar procesoS.
Los contenedores, como entornos aislados que son:
- Tiene su propia configuración de red -> Su propia IP (dentro de una red virutal)
- Tiene sus propias variables de entorno
- Tiene su propio sistema de archivos (file system)
- Pueden tener limitados los recursos de HW

Es posible correr un SO dentro de un contenedor? NO... es imposible. Esa es la gran diferencia con respecto a las VM.

---

# VOLUMEN

Es un punto de montaje dentro del FS del contenedor, a un almacenamiento externo al contenedor.

  /
    bin/
    etc/
      nginx/
        nginx.conf
    var/
      www/
        html/ <---- es un punto de montaje (mount) que punta a un volumen de almacenamiento externo al fs del contenedor
    home/
    mnt/
    media/

# Los Volumenes son de muchos tipos y tiene muchos usos:

Usos:                                                                                 TIPOS
- Persistencia de datos tras la eliminación de un contenedor                          Volumenes persistentes
- Compartir información con otros contenedores                                        
  - Si los contenedores están definidos en el mismo POD, nacen, viven y mueren juntos Volúmen NO PERSISTENTE
  - Si los contenedores están definidos en distintos PODS,
    uno puede morir y el otro seguir vivo.                                            Volúmen PERSISTENTE
- Inyectar archivos/carpetas a un contenedor (Por ejemplo para configuraciones)       Volúmen NO PERSISTENTE 

- Volúmenes NO PERSISTENTES QUE TENEMOS EN KUBERNETES:
  - Inyectar archivos/carpetas a un contenedor                                        ConfigMap, Secret, HostPath
  - Compartir información con contenedores definidos en el mismo POD                  EmptyDir: {}
                                                                                      EmptyDir: {medium: Memory}      -> Volúmen en memoria RAM
- Volúmenes persistentes:                                                             hostpath, nfs, ceph, glusterfs, iscsi, aws, azure, gcp, ...
                                                                                      pvc

# De qué va eso de los PV 

Una referencia a un VOLUMEN de almacenamiento persistente, accesible por RED.
Los PVs los usamos en conjunto con los volumenes de tipo PVC. Para qué sirven? Para qué se usan?

```yaml
kind: Pod
apiVersion: v1

metadata:
  name: mi-pod

spec:
  containers:
    - name: mi-contenedor
      image: nginx
      volumeMounts:
        - name: mi-volumen
          mountPath: /var/www/html
  volumes:
    - name: mi-volumen
      nfs:  # <<<< Aqui declaro el TIPO DE VOLUMEN
        server: mi-nfs-server://path
      #emptyDir: {}
      #hostPath:
      #configMap:
      #  name: mi-configmap
      #pvc:
      #  claimName: mi-pvc
```
^^^ Este fichero, quien lo rellena? De quien es responsabilidad? Del administrador del kubernetes??? NO, NI DE COÑA !!!!
Esto viene de la aplicación.. Lo monta desarrollo!

Y quien contrata/ configura sistemas de almacenamiento para mi cluster de kubernetes? Desarrollo? NI DE COÑA
Esto si es de Administración de sistemas (kubernetes)
Y el desarrollador, cuando configura el POD, sabe los datos del servidor nfs? lun de la cabina? O el ID del volumen en AZURE? NI DE BROMA
Ni la tengo ni la quiero tener... Qué yo voy a saber dónde se guardan los datos en producción? NI LOCO !!!!!

Y para eso sirven las PV y las PVC, para desacoplar las necesidades de almacenamiento de la aplicación, de la infraestructura de almacenamiento, separando las responsabilidades en su gestión.


```yaml
kind: PersistentVolumeClaim
apiVersion: v1

metadata:
  name: mi-pvc

spec:
  accessModes:                                  |
    - ReadWriteOnce # Pa' mi                    |   METADATOS ESTABLECIDOS POR EL DESARROLLADOR
  storageClassName: rapidito-redundante         |
  resources:                                    |
    requests:                                   |
      storage: 1Gi                              |
---
kind: Pod
apiVersion: v1

metadata:
  name: mi-pod

spec:
  containers:
    - name: mi-contenedor
      image: nginx
      volumeMounts:
        - name: mi-volumen
          mountPath: /var/www/html
  volumes:
    - name: mi-volumen
      persistentVolumeClaim:
        claimName: mi-pvc
```
^^^ ESO LO MONTA DESARROLLO... 

vvv ESTO LO MONTA ADMINISTRACION DEL CLUSTER:
```yaml
kind: PersistentVolume
apiVersion: v1

metadata:
  name: mi-pv-187

spec:
  capacity:                                                                   |
    storage: 3Gi                                                              |    METADATOS ESTABLECIDOS POR EL ADMINISTRADOR
  accessModes:                                                                |
    - ReadWriteOnce # Para 1 solito                                           |
  storageClassName: rapidito-redundante                                       |
  ### vvv AQUI ES DONDE DOY LA INFORMACION DE DONDE ESTA EL VOLUMEN FISICO
  nfs:                                                                        |   LA INFORMACION DEL VOLÚMEN FISICO          
    server: mi-nfs-server://path                                              | 
```

Y kubernetes haciendo uso de los metadatos establecidos por el desarrollador, y por el administrador del cluster, hace match y genera el amor!!!!
Y al hacer MAtch, asocia el volumen físico al pvc... y el pvc está a su vez USADO por un POD.
Y el POD, obtiene la información del VOLUMEN FISICO.

---
        accessModes:                                    |
            - ReadWriteOnce # Pa' mi                    |   METADATOS ESTABLECIDOS POR EL DESARROLLADOR
          storageClassName: rapidito-redundante         |
          resources:                                    |
            requests:                                   |
              storage: 1Gi                              |
---
        capacity:                                                                   |
          storage: 3Gi                                                              |    METADATOS ESTABLECIDOS POR EL ADMINISTRADOR
        accessModes:                                                                |
          - ReadWriteOnce # Para 1 solito                                           |
        storageClassName: rapidito-redundante                                       |
---
Surgirá el amor con esos metadatos? SI
Y al final, la app recibe? 1Gb? o 3Gb? 3Gbs
---
# Pods

Es un conjunto de contenedor, que:
- Comparten configuración de RED: IP
  - Entre ellos hablan por la red de loopback: "localhost"
- Tengo garantizado que se despliegan juntos, en el mismo nodo del cluster.
  - Pueden compartir volúmenes de almacenamiento LOCALES
- Escalan simultáneamente
- Comparten recursos de HW

Todos los contenedores en un cluster de kubernetes, estén en el mismo pod o no, pueden compartir VOLUMENES DE ALMACENAMIENTO REMOTOS.
Los contenedores de un POD, pueden compartir un volumen de almacenamiento LOCAL adicional.

Tienen los contenedores persistencia de la información de forma nativa? SI .. 100% out of the box!!!
Qué pasa si BORRO un Contenedor? Qué pasa con su sistema de archivos? Se destruye (Se borra)... y los datos? Borrados también.
Qué pasa si BORRO una VM?        Qué pasa con su sistema de archivos? Se destruye (Se borra)... y los datos? Borrados también.
Qué pasa si BORRO un laptop?     Qué pasa con su sistema de archivos? Se destruye (Se borra)... y los datos? Borrados también.

Otro tema es que los contenedores los vamos a borrar con una frecuencia pasmosa! Todo el día borrando contenedores... y creando NUEVOS.
Por contra, no hacemos eso cuando trabajamos con VMS ni con laptops, ni hierros... 

---

Cuántos pods voy a crear YO en un cluster de Kubernetes? Yo ninguno.
Kubernetes es quién crea pods.

Y además, los irá creando según le vayan haciendo falta... y los irá destruyendo cuando ya no los necesite.

Nosotros lo que vamos a configurar son PLANTILLAS DE PODS dentro de un cluster de Kubernetes:
- Deployment:       Es una plantilla de POD + Número de replicas (+ otros: cómo hacer el despliegue, cómo hacer el rollback...)
                      Para el resto 
- StatefulSet:      Es una plantilla de POD + Una o más plantillas de PVCs + Número de replicas
                      Los usamos para cualquier app en cluster (más de 1 réplica) que necesite persistencia de datos, siendo los datos de cada réplica diferentes entre si:
                      Todas las herramientas que trabajan con DATOS: BBDD, Indexador, Sistema de mensajería...
                      MySQL, MariaDB, Kafka, ElasticSearch, MongoDB, Cassandra, Redis...
- DaemonSet:        Es una plantilla de POD de la que Kubernetes creará un POD por cada nodo del cluster
                      Los creamos poco.... Eso son para : KUBE-PROXY... un sistema de MONITORIZACION... un sistema de LOGGING...

Configurar uno u otro tipo exige un conocimiento previo de la aplicación que vamos a desplegar en el cluster de kubernetes.

---

Los contenedores de los pods... qué tipo de software pueden ejecutar?
Aplicaciones, Servicios y Demonios. Script? NO

Kubernetes espera que los contenedores de un POD no acaben NUNCA SU TRABAJO: Sean eternos: Aplicaciones, Servicios y Demonios.... que se quedan corriendo de perpetuo.
Si un contenedor deja de funcionar, KUBERNETES SE VUELVE LOCO: Activas las alarmas... y trata a toda costa de recuperar el contenedor... y si no puede... lo mata y lo vuelve a crear.... lo que sea para que arranque de nuevo.

De hecho... si necesitase dentro de un pod ejecutar un script, hay un tipo especial de contenedor que podría usar (aunque con limitaciones):InitContainer

  Pod
    InitContainer1
    InitContainer2
    Contenedor1
    Contenedor2
    Contenedor3
  
Qué tipo de software puedo ejecutar en un InitContainer?
App, Servicios, Demonios? NO. Script, comando? SI

Kubernetes espera que los InitContainers de un POD acaben SU TRABAJO: sean efímeros: Script, comando... que se ejecutan una vez y mueren.
De hecho, si un initContainer no acaba su trabajo, KUBERNETES SE VUELVE LOCO: Activas las alarmas... y trata a toda costa de detener el contenedor (piensa que se ha quedao colgao)... y vuelve a crearlo... lo que sea para que acabe de ejecutar el script.

Los initContainers se ejecutan de forma SECUENCIAL, uno detrás de otro, en orden de aparición en el fichero de configuración del POD.
Hasta que el primero no ha acabado su trabajo, no se ejecuta el segundo... y así sucesivamente.
Por contra, lo containers de un pod se ejecutan de forma PARALELA, todos a la vez.... una vez que todos los initContainers han acabado su trabajo.

En el caso que quiera ejecutar un Script, podría crear un POD con un initContainer que ejecute el script y un container que ejecute la aplicación.
MUCHO MAS HABITUAL EN ESTE CASO ES CONFIGURAR : Un JOB

JOB: Es un tipo de POD que se ejecuta una sola vez, y que se destruye una vez que ha acabado su trabajo.
Kubernetes entiende que los JOBs son efímeros, y los borra una vez que han acabado su trabajo.

Pero nosotros no creamos Jobs en Kubernetes... Kubernetes es quien crea Jobs... habitualmente basándose en una PLANTILLA DE JOB:

- CRONJOB = Plantilla de JOB + cron (para planificar la ejecución del JOB)

---

# COMUNICACIONES.

    POD1: IP1
      Tomcat

    POD2: IP2
      MariaDB

  Podría usar desde el POD1, la IP2 para acceder a la BBDD? SI podría, pero.... pude ser que la IP Cambie... y de hecho, a priori, ni siquiera la conozco.

  En kubernetes lo que usamos son SERVICIOS para configurar COMUNICACIONES:
  Servicio?:

  ## COMUNICACIONES PRIVADAS 
  - ClusterIP:      IP de balanceo de carga + Entrada en el DNS interno del cluster apunta a la IP de balanceo de carga
  
  ## COMUNICACIONES PUBLICAS
  - NodePort        Es un ClusterIP + Un puerto(>30000) que se abre en cada nodo del cluster y que apunta (NAT) a la IP DE BALANCEO DE CARGA
  - LoadBalancer    NodePort + Gestión automatizada de un balanceador de carga externo (que tengo que tener PREINSTALADO)
                      Los clouds, cuando les pido un cluster de Kubernetes, ellos me ofrecen un Balanceador Externo de carga compatible con kubernetes. 
                      Si me instalo un kubernetes on prem, necesito yo instalar un balanceador de carga externo compatible con kubernetes: METALLB

  - Ingress : Regla de un proxy reverso: INGRESS CONTROLLER
  - Route (OpenShift)= Ingress + Configuración de un certificado SSL + Configuración de un DNS externo automático.

En la práctica, cómo van a ser los servicios dentro de un cluster tipo de kubernetes?
                            %
      ClusterIP            Todos menos 1
      NodePort              0 (salvo que estás montando algo muy rato,... pero muy raro: 0)
      LoadBalancer          1 (si me apuras 2... más NUNCA)



            192.168.100.1:80 ->
                http://192.168.10.1:30080
                http://192.168.10.11:30080
                http://192.168.10.12:30080
                http://192.168.10.13:30080                miapp1.com=192.168.10.1
            BALANCEADOR DE CARGA                                   |                                                         https://miapp1
            192.168.100.1                                      DNS                                RodrigoPc -> TOMCAT???
                 |                                               |                                   |
    +------------+-----------------------------------------------+-----------------------------------+-------------- RED DE MI EMPRESA
    |
    += 192.168.10.01 - maestro1
    ||                    |    NetFilter: 192.168.10.1:30080 -> 20.20.0.3: 80
    ||                    |    NetFilter: 20.20.0.1: 3306-> 10.10.0.1:3306 
    ||                    |    NetFilter: 20.20.0.2: 8080-> 10.10.0.2:3306 
    ||                    |    NetFilter: 20.20.0.3: 80-> 10.10.0.3:80 
    ||                    |- 10.10.20.1 - Pod CoreDNS
    ||                                        |- 20.20.0.1 = mibbdd
    ||                                        |- 20.20.0.2 = mitomcat
    ||                                        |- 20.20.0.3 = minginx
    ||
    += 192.168.10.11 - nodo1(LINUX)
    ||                    |    NetFilter: 192.168.10.11:30080 -> 20.20.0.3:80
    ||                    |    NetFilter: 20.20.0.1: 3306-> 10.10.0.:3306 
    ||                    |    NetFilter: 20.20.0.2: 8080-> 10.10.0.2:3306 
    ||                    |    NetFilter: 20.20.0.3: 80-> 10.10.0.3:80 
    ||                    |- 10.10.0.2 - Pod Tomcat    < 10.10.0.2:8080          En el archivo del tomcat pongo: BBDD=mibbdd:3306
    ||                                                                            ~~Puedo poner en el archivo de conf. de Tomcat: BBDD=10.10.0.1:3033? SI pero NO~~
    ||
    += 192.168.10.12 - nodo2(LINUX)
    ||                    |    NetFilter: 192.168.10.12:30080 -> 20.20.0.3:80
    ||                    |    NetFilter: 20.20.0.1: 3306-> 10.10.0.:3306  (estas reglas son dadas de alta por KUBE-PROXY)
    ||                    |    NetFilter: 20.20.0.2: 8080-> 10.10.0.2:3306 
    ||                    |    NetFilter: 20.20.0.3: 80-> 10.10.0.3:80 
    ||                    |- 10.10.0.1 - Pod MySQL     < 10.10.0.1:3306
    ||
    ||
    += 192.168.10.13 - nodo3 (LINUX)
    ||                    |    NetFilter: 192.168.10.13:30080 -> 20.20.0.3:80
    ||                    |    NetFilter: 20.20.0.2: 8080-> 10.10.0.2:3306 
    |                    |    NetFilter: 20.20.0.1: 3306-> 10.10.0.:3306  
    ||                    |    NetFilter: 20.20.0.3: 80-> 10.10.0.3:80 
    |                    |- 10.10.0.3- Pod Nginx (Ingress controller)       < 80
    |                                     - INGRESS: miapp1.com -> mitomcat:8080
    |
    Red virtual de kubernetes 10.10.0.0

---

Y si a mi me dan una cuenta para conectarme con un kubernetes... puedo ponerme a cerar pods(deployments...) ... lo que quiera?
Hasta que se acaben los recursos del cluster...
AQUI APLICAN:
- ResourceQuota:
  - Los admin del cluster pueden limitar los recursos a nivel de NAMESPACE... AGREGADOS:
                - Cuantos uso de cores por parte de los pods (en total) en un namespace
                - Cuantos uso de RAM por parte de los pods (en total) en un namespace
                - Cuantos pvc pueden tener los pods en un namespace 
- LimitRange
  - Los admin del cluster pueden limitar los recursos a nivel de POD... dentro de un namespace:
                - Cuanto máximo uso de cores por parte de cada pod
                - Cuanto máximo uso de RAM por parte de cada pod
                - Cuanto máximo uso de PVC por parte de cada pod

        LIMITRANGE                                    RESOURCEQUOTA         
  Cada pod no puedes pedir más de 2 cores...      y en total puedes pedir 7 cores.
  Cada pod no puedes pedir más de 2 Gbs de RAM... y en total puedes pedir 7 Gbs de RAM.

Cuando se monta un cluster de Kubernetes, es necesario crear una RED Virtual entre los nodos del cluster. 