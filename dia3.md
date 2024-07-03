# Clientes de Openshift

## kubectl

Como cluster de Kubernetes que es un cluster de Openshift, puedo manejarlo con kubectl sin problemas.
Ahora bien, Openshift da más funciones que unkubernetes normal:

## oc

Es una extensión del kubectl... me permite lo mismo que kubectl..
Pero adeemás incluye algunas funciones adicionales:

- $ oc login --token=sha256~7_vIEuV7ON0x5SX2WOUT51vXyOCqiwZ_outdyr11ksY \
             --server=https://api.sandbox-m3.1530.p1.openshiftapps.com:6443
- $ oc projects
- $ oc new-project NOMBRE_PROYECTO 
- $ oc whoami

## Sintaxis de los comandos

$ kubectl VERBO TIPO_RECURSO <args>

TIPO_RECURSOS                                       VERBO
    node(s)                             get delete describe
    pod(s)
    deployment
    statefulset
    persistentvolume    pv
    persistentvolumeclaim pvc
    secret(s)                           create
    service svc
    namespace ns
    
<args>
    NOMBRE_DEL_RECURSO
    
$ kubectl describe svc mibd
Se admite también separar el nombre del recurso del tipo por una barra: /
$ kubectl describe svc/mibd

En kubectl es habitual en los comandos pasar el namespace sobre el que hago la operación:
-n --namespace

Con oc no hace falta... por el concepto de proyecto.
Al estar ubicados en un projecto, en automático las operaciones que realicemos son sobre ese namespace (asociado al proyecto)

## Otros comandos

$ oc|kubectl apply  -f "RUTA_FICHERO_CONFIGURACION_DE_RECURSO" # Fichero de manifiesto de kubernetes
$ oc|kubectl delete -f "RUTA_FICHERO_CONFIGURACION_DE_RECURSO" # Fichero de manifiesto de kubernetes

En un fichero pueden ir un montoón de recursos. YAML admite que un fichero contenga multiples documentos YAML.

## Hay otros clientes que usmos muy habitualmente para trabajar con un cluster de kubernetes... 

- HELM: Cliente para hacer despliegues de aplicaciones basados en plantillas (CHARTS)
  Por debajo usa kubectl para conectar al cluster.
  Es la forma estandar de hacer despliegues en un cluster.
  - Para productos comerciales siempre encontramos un chart de helm
  - Para productos propios ... despende de si hemos hecho el chart o no.
  Esto se usa solo para despliegues... no para configuración/monitorización/adminsitración del cluster.
  Encontramos los charts de helm de productos comerciales en: https://artifacthub.io/

---

# Archivos de maniesto de kubernetes/Openshift

Con Kubernetes hablamos en lenguaje DECLARATIVO. NO IMPERATIVO... dentro de lo que son los ficheros de manifiesto
Usando el cliente de kubernetes, ahi si damos una orden... pero la orden es muy peculiar.

kubectl create -f FICHERO # ORDEN A KUBERNETES (Lenguaje imperativo)
kubectl apply  -f FICHERO # ORDEN A KUBERNETES (Lenguaje imperativo)

- Oye! Kubernetes! Crea los recursos de ese fichero que te paso
- Oye! Kubernetes! Aplica ese fichero que te paso

Imaginad que en el fichero de manifiesto DECLARAMOS un deployment.
Al hacer un CREATE de ese archivo de maniesto, qué ocurre? qué le estamos pidiendo realmente a kubernetes?
- Le estoy pidiendo que cree unos pods? NO
- Lo único que le pido es que cargue esa configuración dentro de su BBDD.

Imaginad que en el fichero de manifiesto DECLARAMOS un pod.
Al hacer un CREATE de ese archivo de maniesto, qué ocurre? qué le estamos pidiendo realmente a kubernetes?
- Le estoy pidiendo que cree el pod? NO
- Lo único que le pido es que cargue esa configuración dentro de su BBDD.

Todas estas operaciones son ASINCRONAS. VAN EN 2 fases.
Yo lo que hago es cargar CONFIGURACIONES en kubernetes.
- El trabajo POSTERIOR de kubernetes es ASEGURAR que esas sonfiguraciones se están aplicando en el cluster en todo momento.
  Desde ahora hasta INDEFINIDAMENTE 

---
# ImagePullPolicy

CUIDADO !!!

- Si uso un tag FIJO, que pondré aquí? IfNotPresent
- Si uso un tag VARIABLE...ojo!
    - Always:       Esta guay... Se descarga SIEMPRE ... y siempre tengo la última versión a la que apunte el TAG VARIABLE
                    Pero... tengo 2 potenciales problemas:
                        - El arranque de los pods tardará más tiempo
                            Es muy habitual conseguir la HA de un srvicio en Kubernetes Mediante Cluster Activo/Pasivo   :
                                2 copias... una funcionando y otra por si se cae la primera, pero sin dar servicio (TRADICIONAL)
                                En Kubernetes puedo tener 2 pods funcionando, para prestar un servicio (con balanceo)
                                O 7... Eso es Cluster Activo/Activo
                                Pero puede ser que tenga un servicio que no tiene una carga excesiva de trabajo...
                                Y no quiero tener 2 copias en marcha gastando innecesariamente recursos del cluster: CPU/RAM
                                Que aunque no se usen, se bloquean! 99.99% -> 52 minutos
                                Puedo tener 1 solo POD... y si se cae, levanto otro.
                                En Kubernetes el Activo / Pasivo es muy especial (GENIAL), ya que el pasivo ni siquiera está creado
                                Se crea bajo demanda. Kubernetes tarda decimas de segundo en arrancarlo...
                                    Siempre y cuando no tenga que descargar la imagen del contenedor... 1 minuto... 30 segundos.
                        - Los registries normalmente capan el número de desacargas por unidad de tiempo: DOCKER HUB
    - IfNotPresent  Tengo tiempos guays...
                    Pero... si ya he descargado la 1.21 (que internamente apunta a la 1.21.5)
                    Y sale una 1.21.6 ... y la nueva 1.21 apunta a la 1.21.6... KUBERNETES NO LA DESCARGA
                    El ya tiene una 1.21... no comprueba si hay una 1.21 "NUEVA" (que apunte a otra cosa)

## Qué tags usamos para las imágenes?

(porque no todos los tags son iguales en las imagenes de contenedor)

Hay 2 tipos de tags.
- Fijos         Los fijos siempre apuntan a la misma imagen
    1.21.5   
- Variables     Los variables apuntan a distntas imágenes a lo largo del tiempo
    latest
    1.21
    1

### Consideraciones con respecto a los tags de las imágenes:
- latest NO SE USA EN LA PUTA VIDA. PROHIBIDO ! Por qué?
  No tengo ni idea de lo que etsoy instalando en el cluster. NI IDEA.
  Y puede pasar que hoy funciones... y dentro de 15 días no.
- Fijos         Los fijos siempre apuntan a la misma imagen

    latest      NI DE COÑA SE USA
    1           NI DE COÑA SE USA... aunque es un poco mejor que el latest
                ¿A qué apunta? A la ultima versión 1.X.X
    1.21        ¿A qué apunta? A la ultima versión 1.21.X               *** ESTE ESTA GUAY PARA PRODUCCION ***
    1.21.5      ¿A qué apunta? A una versión concreta . ES FIJO !!!!    *** ESTE ES EL MAS CONSERVADOR ***

    1.21.5                  Se incrementa?
        MAJOR   1           Cuando hay un breaking change: Cambio que no respecta retrocompatibilidad
        MINOR   21          Cuando hay nueva funcionalidad en el producto       MARCA UN CONJUNTO DE FUNCIONALIDADES
                            Cuando algo se marca como obsoleto (deprecated)
        PATCH   5           Con arreglo de bugs
        