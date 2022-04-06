#!bin/sh

# Retrieve network interface, subnetwork, network security group and nsg rules of a given VM. It will take only the "main" one in case of multiple NIC, Snet or NSG.
# Edit it accordingly. Should work if included in a loop that feed it VMs as well, just be aware of the async responses
# Usage: sh getVmNetworkInfo.sh myvm-name myvm-resourcegroup

vmName=$1;
vmRg=$2;

if [ -z $vmName ] 
  then echo "VM name is required as first parameter"; exit;
fi

if [ -z $vmRg ] 
  then  echo "RG name is required as second paramenter"; exit;
fi


nicId=`az vm nic list -g $vmRg --vm-name $vmName --query "[0].id" -o tsv`;
echo "nicId: $nicId";
snetId=`az network nic show --ids $nicId --query "ipConfigurations[0].subnet.id" -o tsv`;
echo "snetId: $snetId";
nsgId=`az network nic show --ids $nicId --query "networkSecurityGroup.id" -o tsv`
echo "nsgId: $nsgId";
nsgRules=`az network nsg show --ids $nsgId --query 'securityRules[?priority<\`15000\`].{Name:name,Access:access,Protocol:protocol,Addresses:sourceAddressPrefixes,Ports:sourcePortRanges}' -o json`
echo $nsgRules;
echo "$vmName/$vmRg network info retrieved";
