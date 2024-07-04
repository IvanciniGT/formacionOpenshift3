    1  free
    2  whoami
    3  pwd
    4  wget https://github.com/okd-project/okd/releases/download/4.15.0-0.okd-2024-03-10-010116/openshift-client-linux-4.15.0-0.okd-2024-03-10-010116.tar.gz
    5  tar -xvf openshift-client-linux-4.15.0-0.okd-2024-03-10-010116.tar.gz 
    6  sudo mv oc kubectl /usr/local/bin
    7  oc version
    8  kubectl version
    9  oc login --token=sha256~7_vIEuV7ON0x5SX2WOUT51vXyOCqiwZ_outdyr11ksY --server=https://api.sandbox-m3.1530.p1.openshiftapps.com:6443
   10  oc new-project prueba
   11  oc get pods
   12  oc get all
   13  kubectl get all
   14  ls ~/.kube/
   15  cat  ~/.kube/config
   16  oc projects
   17  oc whoami
   18  clear
   19  oc get secret
   20  oc get secrets
   21  kubectl get secrets
   22  kubectl get services
   23  kubectl get svc
   24  kubectl describe svc mibd
   25  kubectl describe svc/mibd
   26  kubectl get ns
   27  kubectl get secret
   28  kubectl get secret mibd -o yaml
   29  echo -n "dXN1YXJpbw==" | base64 --decode
   30  oc create -f curso/conceptos/plantilla.yaml 
   31  oc create -f curso/conceptos/plantilla.yaml 
   32  oc create -f curso/conceptos/plantilla.yaml 
   33  clear
   34  oc get pods
   35  oc create -f curso/conceptos/plantilla.yaml clear
   36  clear
   37  oc get pod pod-ivan
   38  oc describe pod pod-ivan
   39  oc get pod pod-ivan -o yaml
   40  oc get pod pod-ivan -o yaml > curso/conceptos/resultado.yaml
   41  oc describe pod pod-ivan
   42  oc projects
   43  oc delete -f curso/conceptos/plantilla.yaml clear
   44  oc delete -f curso/conceptos/plantilla.yaml
   45  cd curso
   46  git init
   47  git add :/
   48  git commit -m 'alta'
   49  https://github.com/IvanciniGT/formacionOpenshift3.git
   50  git config --global credential.helper store
   51  git commit -m 'alta'
   52  git add :/
   53  git commit -m 'alta'
   54  git push --forced
   55  git push --force
   56  git push -u origin master --force
   57  git remote add origin https://github.com/IvanciniGT/formacionOpenshift3.git
   58  git push -u origin master --force
   59  cd ..
   60  clear
   61  oc apply -f curso/conceptos/plantilla.yaml 
   62  oc create -f curso/conceptos/plantilla.yaml 
   63  oc apply -f curso/conceptos/plantilla.yaml 
   64  oc apply -f curso/conceptos/plantilla.yaml 
   65  oc apply -f curso/conceptos/plantilla.yaml 
   66  oc scale deployment deployment-ivan --replicas 3
   67  clear
   68  oc get deployments
   69  oc get pods
   70  oc get replicasets
   71  clear
   72  kubectl get deployment deployment-ivan -o yaml > curso/conceptos/resultado-deployment.yaml 
   73  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   74  helm --version
   75  helm version
   76  clar
   77  clear
   78  helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
   79  helm repo update
   80  cd curso
   81  cd proyectos/
   82  mkdir sonar
   83  cd sonar/
   84  helm pull sonarqube/sonarqube
   85  helm pull -untar sonarqube/sonarqube
   86  helm pull --untar sonarqube/sonarqube
   87  clear
   88  free
   89  git add :/ && git commit -m 'dia3' && git push
   90  oc logout
   91  clear
   92  clear
   93  oc login --token=sha256~pUE5qaRRw42A6NZO-zVvvhjzSf9hLhRpfLuJ2jlHDOg --server=https://api.formacion.tkx5.p1.openshiftapps.com:6443
   94  oc projects
   95  oc get nodes
   96  oc new-project ivan
   97  oc project ivan
   98  cd curso
   99  git remote get-url origin
  100  oc apply -f conceptos/plantilla.yaml 
  101  oc get all
  102  oc delete -f conceptos/plantilla.yaml 
  103  oc project
  104  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  105  clear
  106  oc apply -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  107  oc apply -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  108  oc delete -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  109  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  110  oc get pods
  111  oc describe pd wp-8547854587-4kbgd
  112  oc describe pod wp-8547854587-4kbgd
  113  git add :/ && git commit -m 'wp' && git push
  114  oc get events
  115  oc delete -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  116  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  117  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  118  oc delete -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  119  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  120  oc delete -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  121  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  122  oc delete -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  123  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  124  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  125  oc create -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  126  git add :/ && git commit -m 'wp' && git push
  127  oc delete -f proyectos/wordpress/deployment/wordpress.deployment.yaml 
  128  helm install miwp oci://REGISTRY_NAME/REPOSITORY_NAME/wordpress
  129  helm install miwp oci://registry-1.docker.io/bitnamicharts/wordpress -f values.yaml
  130  helm install miwp oci://registry-1.docker.io/bitnamicharts/wordpress -f proyectos/wordpress-chart/values.yaml 
  131  echo Password: $(kubectl get secret --namespace ivan miwp-wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)
  132  helm uninstall miwp 
  133  helm install miwp oci://registry-1.docker.io/bitnamicharts/wordpress -f proyectos/wordpress-chart/values.yaml 
  134  helm uninstall miwp 
  135  git add :/ && git commit -m 'wp' && git push
  136  helm install miwp oci://registry-1.docker.io/bitnamicharts/wordpress -f proyectos/wordpress-chart/values.yaml 
  137  helm template oci://registry-1.docker.io/bitnamicharts/wordpress -f proyectos/wordpress-chart/values.yaml 
  138  helm template oci://registry-1.docker.io/bitnamicharts/wordpress -f proyectos/wordpress-chart/values.yaml > proyectos/wordpress-chart/salida-helm.yaml
  139  helm uninstall miwp 
  140  git add :/ && git commit -m 'wp' && git push
  141  history > comandos.sh
