
#Assignment 2

PROJECT_NAME="pe-training"
echo "Enter instance template's name: "
read inst_temp
echo "Enter health check's name: "
read health_check
echo "Enter instance group's name: "
read inst_grp
echo "Enter bucket's name:  "
read wajida-bucket
echo "Enter storage class:  "
read storage_class
echo "Enter location: "
read location
echo "Enter JSON file name"
read json_file

# #1
#Create instance template

echo "Creating instance template"  

gcloud beta compute --project="$PROJECT_NAME" instance-templates create $inst_temp --machine-type=n1-standard-1 --subnet=$vpc_subnet --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=912623308461-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --region=us-central1 --tags=http-server,https-server --image=debian-9-stretch-v20180716 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$inst_temp

#Create Health Check

echo "Creating Health Check"

gcloud compute --project "$PROJECT_NAME" http-health-checks create "$health_check" --port "80" --request-path "/" --check-interval "5" --timeout "5" --unhealthy-threshold "2" --healthy-threshold "2"

#Create intance group

echo "Creating instance group"

gcloud compute --project "$PROJECT_NAME" instance-groups managed create "$inst_grp" --base-instance-name "$inst_grp" --template "$inst_temp" --size "1" --zone "us-east1-b"

gcloud compute --project "$PROJECT_NAME" instance-groups managed set-autoscaling "$inst_grp" --zone "us-east1-b" --cool-down-period "60" --max-num-replicas "10" --min-num-replicas "1" --target-cpu-utilization "0.6"


# #2
#Configure load balancer and set instance group as back-end

echo "Configure load balancer and set instance group as back-end"

#Create a named port for backend service
gcloud compute instance-groups set-named-ports wajida-instance-group --named-ports http-port:80

#Create a backend service
gcloud compute backend-services create wajida-http-backend-service --http-health-checks wajida-hc --port-name http-port --protocol HTTP --global

#Attach backend service to the instance group
gcloud compute backend-services add-backend wajida-http-backend-service --instance-group wajida-instance-group --balancing-mode RATE --max-rate-per-instance 10 --instance-group-zone us-east1-b --global

#Create a static IP address
gcloud compute addresses create wajida-pe-address --global --ip-version IPV4

#Creating a URL Map/Load Balancer
gcloud compute url-maps create wajida-pe-lb --default-service "wajida-http-backend-service"

#Creating target proxies
gcloud compute target-http-proxies create wajida-http-proxy --url-map wajida-pe-lb

#Now we need to attach an external IP to our load balancer
gcloud compute forwarding-rules create cdm-http-cr-rule --address wajida-pe-address --ports 80 --target-http-proxy wajida-http-proxy --global


# #3
#Create bucket and configure lifecycle rule to delete objects after 60 days

echo "Create bucket and configure lifecycle rule to delete objects after 60 days"

gsutil mb -p $PROJECT_NAME -c $storage_class -l $location gs://bucket_name/

gsutil lifecycle set json_file gs://bucket_name

gsutil lifecycle get gs://bucket_name