# ERRORES EN EL DESPLIEGUE DEL WP A MANO:
- Se intenta abrir el puerto 80... y se usa una imagen de contenedor que requiere de usuario root
- Un pod se queda sin asignar a ninguna máquina
    0/8 nodes are available: 
        1 node(s) didn't match pod anti-affinity rules, 
        2 node(s) didn't find available persistent volumes to bind, 
        2 node(s) had untolerated taint {node-role.kubernetes.io/infra: }, 
        3 node(s) had untolerated taint {node-role.kubernetes.io/master: }. 
    preemption: 0/8 nodes are available: 
        1 No preemption victims found for incoming pod, 
        7 Preemption is not helpful for scheduling..

## Cómo lo resuelvo?

Malamente:
A) No poner la regla de afinidad... y que los 2 pods se desplieguen en el mismo host
   Problema: Si se cae el nodo, se me caen todos los pods (TIEMPO DE INDISPONIBILIDAD)
             Podré escalar como mucho hasta el límite del nodo.
B) Solicitar un volumen READ WRITE MANY (más natural!)
    Problema: En el cluster no tengo nadie que me permita provisionar volumenes read ????? "MANY"

Y es que no todos los tipos de volumenes admiten provisionado R?X.

Nuestro cluster viene de serie configurado con unos provisionadores que trabajan con: ebs.csi.aws.com
EBS: Eso es un servicio de AMAZON... que tenemos equivalente en otros clouds
     Elastic BLOCK Storage
    Un almacenamiento por bloques: Me monta un disco entero en el NODO... pero ya no se puede montar en otro nodo
    
    Puedo montar un disco iSCSI a la vez en 2 máquinas físicas? NO... igual que esto !!!

En amazon existe también el EFS: FILESYSTEM
    
    Puedo montar una carpeta nfs a la vez en 2 máquinas físicas? SI


---
# Toleraciones y Taints

Me permite como administrador del cluster establecer que pods pueden ejecutarse en un nodo.
- En este nodo solo pueden ejecuatrse pods que requieran de gpu

# Afinidades

Me permiten como desarrollador, elegir el tipo de máquinas en las que quiero mi pod.
Son instrucciones que le doy al scheduller.
- Necesito una maquina con GPU
- Necesito una máquina con ciertas configruaciones a nivel de HOST
- Quiero a ser posible una máquina donde no haya ya un pod desplegado como el mio.
- Quiero una máquina que no esté en una ubicacion geográfica donde ya tenga desplegado un pod como el mio.

Como desarrollador yo quiero que mi pod vaya a una máquina que requiera de gpu.
    Pero no evitaría que un pod que no requiera de gpu se monte en un nodo que tenga gpu. ESTO PUEDE NO SER DESEABLE
    Y ahí entra la toleracia y el tinte.
    TIÑO la máquina (le aplico un taint) que evite que en esa máquina se monten pod que no requieran de gpu
    Y al pod le aplico una tolerancia a ese tinte.


oc describe scc anyuid

---

POD
    Contenedores
        Procesos
            Se ejecutan con determinados usuarios
            Y querrán acceder o no a algunos recursos de host
                - A alguna carpeta del host
                - A la red del host
Al pod le asociamos un ServiceAccount
Y el service Account está asociado con algunas SCC (Security Context Constrains)
Los SCC limitan las actividades que pueden ejecutarse dentro de un pod... por parte de los procesos de sus contenedores:
    - Los usuarios que pueden usar
    - A lo que pueden acceder del host
    - También a nivel del cluster
        - Puedo permitir que un pod monte volumenes o no
        - Puedo permitir que montae volumenes de tipo secret o no
        
```yaml
kind: SecurityContextConstraints
apiVersion: security.openshift.io/v1

metadata:
  name: anyuid



allowHostDirVolumePlugin: false         # Si un pod con un ServiceAccount que tenga vinculada esta politica puede montar volumenes del host
allowHostIPC: false                     # Si puede abrir comunicaciones IPC con cprocesos que estén corriendo a nivel del host o no
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
defaultAddCapabilities: null
runAsUser:
  type: RunAsAny
  #uidRangeMin: 1000
  #uidRangeMax: 1000000
fsGroup:                                # Esto es el grupo que se puede asociar a los archivos/carpetas de los volumenes
  type: RunAsAny
priority: 10                            # Cuando un token tiene varios SCC asociados, cual tiene prioridad
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- csi
- downwardAPI
- emptyDir
- ephemeral                         # emptyDir
- persistentVolumeClaim
- projected
- secret


# Esto es qué grupos o usuarios (DE OPENSHIFT) tienen permitido usar esta politica SCC
groups:
- system:cluster-admins
users: []

```
^^^TODO ESTO LO ESTABLECEN LOS ADMINISTRADORES DEL CLUSTER
---
A nivel de cada POD, los desarrolladores pueden elegir un contexto de seguridad, para su pod.
Eso si... ese contexto de seguridad tiene que ser permitido por algún SCC que tenga vinculado el ServiceAccount que esté usando el POD
A nivel de SecurityContext del POD, el desarrollador puede seleccionar:
- Con que usuario se ejecutaq el contenedor del pod: RunAsUser 
- RunAsGroup
- FSGroup < Es el grupo que se asocia a los archivos y carpetas de un volumen al montarse (hace un chmod de los archivos al montarse el volumen. y ojo, que puede tardar un huevo!)
- seLinuxOptions
- Capabilities