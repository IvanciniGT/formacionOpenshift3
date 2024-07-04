
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

- Vamos a montar un despliegue de una app desde 0 ... después lo tiraremos a la basura
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