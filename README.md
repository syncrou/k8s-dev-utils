## Steps to set up your own env on dev ocp (likely to change):

1) create namespace `oc new-project my-project`
2) import catalog-db secret `./copy_catalog_db_secret.sh`
3) create your build, speicifying the repo/branch `./create_build.rb --repo https://github.com/myuser/catalog-api --branch my-branch` (this defaults to insights catalog-api and master)
4) import the deployment `oc create -f ./dc.yml`

### At this point the application should be up and running after the build completes and the deployment picks it up and runs the pod

To get to the application, since there isn't a way to get to the pod (ie no 3scale forwarding) the best way is to forward traffic from your local into the pod:
`oc port-forward pod/catalog-api-#-adsfa 3000` which forward localhost:3000 -> pod:3000
After this, you can "attach" to the console and use `binding.irb` to debug in the application just like it was running locally:
`oc attach -it pod/catalog-api-#-adsfad`

It won't have byebug/pry by default, but if you check that into your branch it will build with all of the debugging utilities at your disposal. 

----

To make changes locally and have them automatically copied up to the pod, you can use the `dev_kube.rb` script. 
It requires 2 gems, install them with `gem install filewatcher kubeclient`

Then run it like so:
`SRC=/path/to/catalog-api DEST=/opt/catalog-api NAMESPACE=my-namespace POD=catalog ruby ./dev_kube.rb`
This copies the files from your local catalog-api into the remote pod, and since it is running in development it will hot-reload (unless it is an initializer of course)
