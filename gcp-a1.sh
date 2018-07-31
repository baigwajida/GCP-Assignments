
#Assignment 1

PROJECT_NAME=pe-training
echo "Enter VPC with auto subnets' name: "
read vpcnetwork
echo "Enter firewall-rule name: "
read firewall-rule
echo "Enter VPC with custom subnets' name: "
read vpccustom
echo "Enter VPC's custom subnet 1 name:  "
read custom1
echo "Enter VPC's custom subnet 2 name:  "
read custom2
echo "Enter VM instance name: "
read vminstance
echo "Enter NAT name: "
read natname
echo "Enter private instance name: "
read private_instance_name

# #1 
#create vpc network with auto subnets
echo "Creating VPC network with auto subnets"

gcloud compute --project=PROJECT_NAME networks create $vpcnetwork --mode=auto

#configure firewall rules
echo "Configure firewall rules"

gcloud compute --project=PROJECT_NAME firewall-rules create $firewall-rule --description=Allows\ TCP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ port\ 22. --direction=INGRESS --priority=65534 --network=$vpcnetwork --action=ALLOW --rules=tcp:22 --source-ranges=59.152.52.0/22


# #2
#create vpc with custom subnets
echo "Create VPC with custom subnets"

gcloud compute --project=PROJECT_NAME networks create $vpccustom --mode=custom

gcloud compute --project=PROJECT_NAME networks subnets create $custom1 --network=$vpccustom --region=us-east1 --range=10.142.0.0/20

gcloud compute --project=PROJECT_NAME networks subnets create $custom2 --network=$vpccustom --region=us-central1 --range=10.128.0.0/20



# #3 

#allow internal communication rule
gcloud compute --project=PROJECT_NAME firewall-rules create wajida-pe-allow-internal --direction=INGRESS --priority=1000 --network=wajida-vpc --action=ALLOW --rules=tcp:1-65535,udp:1-65535,icmp --source-ranges=59.152.52.0/22

#Launch instance with only private ip and configure NAT so instance can access Internet

echo "Launch instance with only private ip and configure NAT so instance can access Internet"

#creating nat instance
gcloud compute instances create $natname --network $vpcnetwork --can-ip-forward --zone $us-east1-b --image-family debian-8 --subnet $custom1 --image-project debian-cloud --tags nat-int --metadata=startup-script="sudo sysctl -w net.ipv4.ip_forward=1\nsudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

#creating private instances
gcloud compute instances create $private_instance_name --network $vpcnetwork --no-address --zone $us-central1-a  --image-family debian-8 --subnet $custom2 --image-project debian-cloud --tags private-int

#creating route from private to nat
gcloud compute routes create private-access-route --network $vpcnetwork --destination-range 0.0.0.0/0 --next-hop-instance nat-gateway --next-hop-instance-zone us-east1 --tags private-int --priority 800