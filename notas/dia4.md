
Y a un namespace le doy 64Gbs de RAM:
- Servidores de app: Tomcat x n 4-8Gbs                  18Gbs
- BBDD: Maestro/Replica (PostgreSQL) 8Gbs x 2           16
- REDIS: Cache x 3: 4Gbs                                12
- RABBITMQ/KAFKA: x 3 : 6 Gbs                           18
                                                    ----------
                                                        64
                                                        
Otro tema es que:
Tengo máquinas con 32 Gbs de RAM
El tio se vuelve loco y crea un pod 28Gbs de RAM... Le acabo de dejar a la máquina 4Gbs de RAM
Me limita un huevo la máquina!
Para provisionar ese pod me las veo y me las deseo... Necesito una máquina que prácticamente esté libre.
---

# Tareas

- Vamos a montar un despliegue de una app desde 0 ... después lo tiraremos a la basura (TODO: SC)
- Vamos a usar un chart de helm para el despliegue de esa app
- SonarQube mediante HELM, pero dejandolo guay!

Wordpress
    
    
    MariaDB1 <-
    v^  1 2                    <-       WP1 <-
    MariaDB2 <-     BALANCEO                     BALANCEO   <-     PROXYREVERSO    <-        CLIENTE
    v^  1 3                    <-       WP2 <-
    MariaDB3 <-
        2 3
    
    BBDD las puedo configurar de 3 formas:
    - Standalone
    - Replicacion           HA + ESCALABILIDAD EN LECTURA
    - Activo - Activo       HA + ESCALABILIDAD EN LECTURA + ESCALIBILIDAD EN ESCRITURA
        Al poner 3 máquinas con factor de replicación de 2, obtengo una mejora POTENCIAL (TEORICA)
        máxima de un 50%.. En 2 ud de tiempo, puedo guardar 3 datos
        Mientras que si tengo 1 sola máquina, en 1 ud de tiempo puedo guardar 1 dato-> 2 uds de tiempo = 2 datos
        
    Cada instancia de la BBDD necesita tener sus propios ficheros de Datos -> Cada una necesita un volumen independiente!
    
    Los 2 WP deben compartir un volumen de almacenamiento... Necesitan acceder a los mismos ficheros.
    
---

# Servicios y nombres de servicios... y su uso como fqdns

Si tengo un servicio llamado "servicio"
en mi cluster que se llama "cluster-local"
, y lo tengo creado en un namespace que se llama "namespace"

Puedo usar como fqdn:
    - servicio                  Se buscaría el servicio que exista en el mismo ns desde el que uso el fqdn
    - servicio.namespace
    - servicio.namespace.cluster-local (NO LO USAMOS NUNCA)
    
Si estoy en un WP creado en el ns: wp
    Si en el WP uso como ruta de la BBDD "servicio", se busca el servicio llamado "servicio" en el mismo ns del WP
    Si no existe ERROR
Cuando quiero acceder a servicios de otro NS, entonces si uso:
    - servicio.namespace


---

# Probes

Por defecto, cómo monitoriza kubernetes/Openshift un pod? O No hay monitorización?
Lo que kubernetes monitoriza es el proceso a nivel de SO. Si está corriendo o no!
Si no esta corriendo el proceso principal que debe eecutarse en un contenedor de un pod, KUBERNETES REINICIA EL POD

Esto es suficiente? NO
Puede ser que el proceso esté corriendo, pero que no esté funcionando como debe. Por ejemplo:
- Por estar mal configurado
- OutOufMemory (con el uso... no inicialmente)
- Que tenga hilos bloqueados en el proceso... y el proceso no esté ejecutando trabajo.
    Weblogic / Websphere (ThreadStuck)

- Startup
- Lifeness
- Readiness

En cada una lo que pongo es un comando que si se ejecuta sin problemas se considera que la prueba SE HA PASADO!
    curl
    mysql < "SELECT 1"
Esas pruebas se ejecutan en distintos momentos del tiempo:
- Lo primero las de startup... El sistema puede tardar un rato en iniciar... Y le doy tiempo
  Si no se supera: REINICIO por parte de Kubernetes
  Si se supera.. ya no se ejecuta nunca más (a no ser que haya un reinicio)
 - Y pasamos a ejecutar las pruebas de Lifeness para ver si el sistema está arrancado.
  Para ver si se mantiene arrancado.
    Esa prueba la haremos cada X tiempo 
  Si el sistema no se mantiene arrancado, kubernetes LO REINICIA DE NUEVO¡
  Si el sistema se mantiene arrancado:
 - Paso a hacer pruebas de readyness... para ver si el sistema está listo para prestar servicio
  Si la prueba de readyness falla:        kubernetes lo saca de balanceo del servicio asociado... PERO NO SE REINICIA!
                                          continua haciendole pruebas de readyness y de lifeness
  Si la prueba de readyness funciona:     kubernetes lo mete en balanceo.
                                          continua haciendole pruebas de readyness.
                                          
Por qué pruebas de readyness y lifeness:
- Por ejemplo, el WP, NECTCLOUD puede entrar en modo de mantenimiento
  (después de una actualización...o porque le instale unos plugins)
  En ese momento no permite a la gente hacer login... No lo meto en balanceo... 
  Pero quiero reiniciarlo? NO
- Por ejemplo, pongo una BBDD en mnto para hacerle un backup/restore
  La BBDD no va a estar lista para prestar servicio. No contesta a nadie.
  Pero no quiero reiniciarla... está haciendo su trabajo.
  Otra cosa es que no esté lista para prestar servicio