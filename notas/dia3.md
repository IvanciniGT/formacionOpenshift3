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
    Da de alta en la BBDD de kubernetes las configuraciones que le sumistre en el fichero
kubectl apply  -f FICHERO # ORDEN A KUBERNETES (Lenguaje imperativo)
    Da de alta en la BBDD de kubernetes las configuraciones que le sumistre en el fichero si no existen previamente...
    Si ya existen INTENTA modificarlos

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

--- 

# Actualizacion de versiones de deployments

- Rolling update: Va reemplazando los pods que están en servicio gradualmente
    Pod1 v1.2.1 ->  Pod1 v1.2.1 -> Pod1 v1.2.1 -> Pod6 v1.2.2*
    Pod2 v1.2.1     Pod2 v1.2.1    Pod5 v1.2.2*   Pod5 v1.2.2 
    Pod3 v1.2.1     Pod4 v1.2.2*   Pod4 v1.2.2    Pod4 v1.2.2 

    No va a haber tiempo de inactividad
    PERO: En un momento dado del tiempo puedo tener pods corriendo en distintas versiones de la app
    
    Pod1 v1.2.1 ->  Pod1 v1.2.1         < -  Las peticiones que reciban estos de aquí podrían fallar
    Pod2 v1.2.1     Pod2 v1.2.1 
    Pod3 v1.2.1     Pod4 v2.0.0* (al arrancar, este microservicio podría modificar la BBDD, para ajustarla a las nuevas funcionalidades)

- Recreate: Se cruje todos y los recrea: Va a haber un tiempo de indisponibilidad
                                         Me asegura que solo tengo una versión en funcionamiento de la app en un instante de tiempo

Hacer una buena configuración requiere tener conocimiento MUY PROFUNDO de la app y de los cambios que incorpora.
Lo más conservador: RECREATE (ahí no hay que configurar nada... en el strategy)

En los entornos de producción... luego se complica más aún.
Y aquí entra el concepto de que cada vez más, esto se deja a desarrollo... 
No vale ya que la instalación la hagan como se hacía antes los de systemas.

# Microservicios.

En los entornos de producción, si tengo una versión del microservicio 1.2.3... y quiero pasar a la 1.2.4 o a la 1.3.0
    Actualizo el deployment.
Pero si quiero pasar a la 2.0.0 dejo ese deployment como está y creo uno nuevo.

Y tengo las 2 versiones en paralelo del microservicio en producción.
Puede ser que desde desarrollo me den en la misma imagen de contenedor las 2 versiones del microservicio:
- 1.3.0 y la 2.0.0.... No nos gusta mucho... Al hacer despliegue de una nueva v2.1.0... me quedo entre tanto sin la 1.3.0 (NO TIENE SENTIDO)
- Si quiero pasar la 1.3.0 -> v1.3.1... tengo que parar la v2.X.X (NO TIENE SENTIDO)
  Esto suele ser más fácil para desarrollo... 

Hoy en día, hacemos locuras mayores!
Por ejemplo:
    Dejo la v1.2.3 del microservicio... y en paralelo pongo la 1.3.0... (solo para el 1% de las peticiones)
    Y si va bien, subo el % a un 10
    Y si va bien, subo el % a un 25
    Y si va bien, subo el % a un 100
        Y entonces me cargo el otro: V1.2.3
        
    Esto para un pase a producción es maravilloso... Si la riego, solo afecto a un % muy pequeño de los usuarios.
    Esto ni lo hace kubernetes per se... ni lo hace Openshift per se.
    Aqui es donde entran otras herramientas: ISTIO
    
# ISTIO

Toma control de todas las comunicaciones que se realizan en un cluster de kubernetes.
Para eso, lo que hacemos es hackearnos a nosotros mismos: MAN-IN-THE-MIDDLE a nivel de cada POD.
    
    POD 3                   POD1                         POD2            
    IngressController       Tomcat                       BBDD
     v ^ localhost           v ^ localhost                v ^ localhost (http... u otros no securizados)
    PROXY Envoy ----------> PROXY Envoy -----https---->  PROXY Envoy
    (actuaria de proxy)     (actuaria de proxy reverso)  (actuaria de proxy reverso)
                            (actuaria de proxy)
    
(ISTIO trae su propio INGRESS CONTROLLER... y de paso, otro concepto llamado EGRESS CONTROLLER)

Una vez que tengo esa arquitectura... las opciones son ILIMITADAS. Tengo control total de las comunicaciones de mi cluster:
1. Monitorizar las comunicaciones
2. Configurar comunicaciones seguras
    Si quiero securizar las comunicaciones a nivel de backend... es igual que a nivel de frontal?
        http(s) -> http + TLS
        TLS nos ofrece 3 cosas:
            - Frustrar ataques man-in-the-middle (ENCRIPTADO)
            - Frustrar ataques de Suplantación de identidad (PRESENTACION DE UN CERTIFICADO FIRMADO POR UNA CA DE CONFIANZA)
            - No repudio
        En los frontales, cuando un cliente desde su navegador se conecta con un servidor, el navegador 
            verifica la identidad del servidor para (Frustrar ataques de Suplantación de identidad) 
            La app (el servidor) por su lado valida la identidad del usuario (AUTENTICA): Contraseña, característica biométrica, Doble factor (quiero un dato que solo tu tengas.. y yo)... además quiero algo que solo tu poseas (telefono)
            Solo en casos muy excepcionales el servidor solicita CERTIFICADO al cliente (No repudio: HACIENDA)
        En un backend, donde quiero 2 servidores hablando entre si, Ambos se autentica mutuamente.
            Cada uno de ellos rpesenta SU CERTIFICADO al otro.
        Eso requiere que cada proceso en backend tiene que tener su CERTIFICADO UNICO.
        Quizás tengo 1000 pods en mi cluster... = 1000 certificados... a generar, a mantener (caducan), y a configurar en cada servicio
        Y en los serviciones a los que accede = INMANTENIBLE e IRREALIZABLE de forma manual.
   Esto me lo regala (con 0 esfuerzo y tiempo) ISTIO.
    Genera una CA propia, certificados para todos los ENVOYS, los configura y los mantiene).
3. Funcionalidades extra: Poder hacer despliegues incrementales.

---
                federico
helm repo add NOMBRE_LOCAL_PARA_EL_REPO https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
                        Namespace donde queremos instalar
                            v       pancracio
helm upgrade --install -n sonarqube sonarqube NOMBRE_LOCAL_PARA_EL_REPO/sonarqube
                                        ^                                   ^ Nombre del chart. Lo da el fabricante
                                    NOMBRE_DE_RELEASE    
                                    Esto es un nombre ARBITRARIO que yo pongo para identificar la instalación que voy a hacer
                                    Ese nombre me permite luego:
                                    - Desinstalar: helm uninstall pancracio -n mi-namespace
                                    - Actualizacion: helm upgrade pancracion -n mi-namespace NOMBRE_LOCAL_PARA_EL_REPO/sonarqube
                                    
---

Afinidades: Para dar indicaciones al Scheduler que le ayuden a tomar una decisión acerca de dónde desplegar los pods
o qué estrategias debe seguir los despliegues.
    Afinidad a nivel de nodo: 
        Intenta ponerme en nodos con unas características
    Afinidad a nivel de pod: 
        Intenta ponerme en nodos que compartan caractarísticas con nodos que tengan pods con unas caracteristicas
    Antiafinidad a nivel de pod ****
        Intenta ponerme en nodos que compartan caractarísticas con nodos que no tengan pods con unas caracteristicas
        Siempre querremos generar antiafinidad preferida (no requerida) con nosotros mismos.
            Si despliego 2 pods de sonar... no le los ponga en la máquina... o al menos intentalo