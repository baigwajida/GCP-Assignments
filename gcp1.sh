
#Assignment 1

# #1 
#create vpc network with auto subnets
echo "Creating VPC network with auto subnets"

gcloud compute --project=pe-training networks create wajida-vpc --mode=auto

#configure firewall rules
echo "Configure firewall rules"

gcloud compute --project=pe-training firewall-rules create wajida-vpc-allow-ssh --description=Allows\ TCP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ port\ 22. --direction=INGRESS --priority=65534 --network=wajida-vpc --action=ALLOW --rules=tcp:22 --source-ranges=59.152.52.0/22


# #2
#create vpc with custom subnets
echo "Create VPC with custom subnets"

gcloud compute --project=pe-training networks create wajida-vpc-custom --mode=custom

gcloud compute --project=pe-training networks subnets create wajida-vpc-custom-1 --network=wajida-vpc-custom --region=us-east1 --range=10.142.0.0/20

gcloud compute --project=pe-training networks subnets create wajida-vpc-custom-2 --network=wajida-vpc-custom --region=us-central1 --range=10.128.0.0/20



# #3 
#Launch instance with only private ip and configure NAT so instance can access Internet
echo "Launch instance with only private ip and configure NAT so instance can access Internet"

gcloud beta compute --project=pe-training instances create new-vm-instance1 --no-address --zone=us-east1-b --machine-type=n1-standard-1 --subnet=wajida-vpc-custom-1 --can-ip-forward --network-tier=PREMIUM --metadata=startup-script=sudo\ sysctl\ -w\ net.ipv4.ip_forward=1$'\n'sudo\ iptables\ -t\ nat\ -A\ POSTROUTING\ -o\ eth0\ -j\ MASQUERADE --no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --service-account=912623308461-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=nat-gateway,http-server,https-server --image=debian-9-stretch-v20180716 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=new-vm-instance
