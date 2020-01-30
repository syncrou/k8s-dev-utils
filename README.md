### Prerequisites
- oc
- jq
- kubectl

## Steps to set up your own env on dev ocp (likely to change):

- create namespace `oc new-project my-project`
- import catalog-db secret `./copy_catalog_db_secret.sh`
- create the postgresql deployment and service, `oc create -f ./database.yml`
- prepare the catalog build files
  - create your build(s) for catalog and minion, specifying the repo/branch `./create_build.rb --repo https://github.com/myuser/catalog-api --branch my-branch` (this defaults to insights catalog-api and master)
  - Edit catalog.yml; set the image line to use your build (image line, line 97 replace `buildfactory` with your namespace)
  - Edit catalog.yml; set the `IMPORT_CI_DB` initContainer ENV var to false if you would like to run with a pristine container, otherwise it will import the database from CI.
- create the deployment and service for catalog `oc create -f ./catalog.yml`
- create the minions `oc create -f ./minions.yml`

### At this point the application should be up and running after the build completes and the deployment picks it up and runs the pod

To get to the application, since there isn't a way to get to the pod (ie no 3scale forwarding) the best way is to forward traffic from your local into the pod:
`oc port-forward pod/catalog-api-#-adsfa 3000` 
which forwards localhost:3000 -> pod:3000

If you need to port forward to another internal port 
`oc port-forward pod/catalog-api-#-adsfa 5000:3000` 
which forwards localhost:5000 -> pod:3000

After this, you can "attach" to the console and use `binding.irb` to debug in the application just like it was running locally:
`oc attach -it pod/catalog-api-#-adsfad`

It won't have byebug/pry by default, but if you check that into your branch it will build with all of the debugging utilities at your disposal.

----

To make changes locally and have them automatically copied up to the pod, you can use the `dev_kube.rb` script.
It requires 2 gems, install them with `gem install filewatcher kubeclient`

Then run it like so:
`SRC=/path/to/catalog-api DEST=/opt/catalog-api NAMESPACE=my-namespace POD=catalog ruby ./dev_kube.rb`
This copies the files from your local catalog-api into the remote pod, and since it is running in development it will hot-reload (unless it is an initializer of course)
