# #!/bin/bash
# set -e

# ######### Expected Inputs ############

# ### $1 = Action. Either "add" or "rm"
# ### $2 = Cluster Name
# ### $3 = Load Balancer IP
# ### $4 = Resource Group
# ### $5 = VNET Name
# ### $6 = Subnet Name
# ### $7 = Service Mesh

# ######################################

# if [ "$#" -ne 8 ]; then
#   echo "ERROR: Incorrect number of arguments, received $#, but 8 are required."
#   echo "Usage: $0 ACTION CLUSTER_NAME AUTO_LOAD_BALANCER_IP RESOURCE_GROUP VNET_NAME SUBNET_NAME SERVICE_MESH"
#   for param in "$@"; do
#     echo "Received: $param"
#   done
#   exit 1
# fi

# ACTION=$1
# CLUSTER_NAME=$2
# LOAD_BALANCER_IP=$3
# AUTO_LOAD_BALANCER_IP=$4
# RESOURCE_GROUP=$5
# VNET_NAME=$6
# SUBNET_NAME=$7
# SERVICE_MESH=$8

# if [ -n "$LOAD_BALANCER_IP" ]; then
#   USE_LOAD_BALANCER_IP=$LOAD_BALANCER_IP

# elif [ $AUTO_LOAD_BALANCER_IP = "true" ]; then
#   echo "Get an IP from the subnet"
#   USE_LOAD_BALANCER_IP=$(az network vnet subnet list-available-ips --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_NAME" --query [0])
#   echo "Assigned IP: $AUTO_LOAD_BALANCER_IP"

# else
#   USE_LOAD_BALANCER_IP=$AUTO_LOAD_BALANCER_IP
# fi

# export USE_LOAD_BALANCER_IP

# echo "Parameters in use:"
# echo "ACTION: $ACTION"
# echo "CLUSTER_NAME: $CLUSTER_NAME"
# echo "AUTO_LOAD_BALANCER_IP: $AUTO_LOAD_BALANCER_IP"
# echo "RESOURCE_GROUP: $RESOURCE_GROUP"
# echo "VNET_NAME: $VNET_NAME"
# echo "SUBNET_NAME: $SUBNET_NAME"

# echo "Current working directory:"
# pwd
# cd ../../../../
# echo "New working directory:"
# pwd
# echo "Checking for cluster yaml file..."
# if pwd | grep -q managed-environment; then
#   echo "In managed-environment repo"

#   if ls | grep -q "$CLUSTER_NAME.yaml"; then
#     BRANCH_NAME="loadBalancerIp-updated-in-$CLUSTER_NAME-$(date '+%s')"
#     git checkout main
#     git pull origin main
#     git checkout -b "$BRANCH_NAME"
    
#     echo "Found $CLUSTER_NAME.yaml file to update."
#     cat "$CLUSTER_NAME.yaml"

#     if [ "$ACTION" = "add" ]; then
#       if [ "$SERVICE_MESH" = "istio" ]; then
#         echo "Add loadBalancerIp flag with gateway:"
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | sed 's/^/  /' > values_part.yaml
#         awk '/values: \|/{print $0; exit} {print}' "$CLUSTER_NAME.yaml" values_part.yaml > header_part.yaml
#         cp header_part.yaml updated.yaml
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | yq 'del(.loadBalancerIp)' | yq ".gateway.service.loadBalancerIp = env(USE_LOAD_BALANCER_IP)" | sed 's/^/  /' >> updated.yaml
#         cat updated.yaml > "$CLUSTER_NAME.yaml"
#       else
#         echo "Add loadBalancerIp only flag:"
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | sed 's/^/  /' > values_part.yaml
#         awk '/values: \|/{print $0; exit} {print}' "$CLUSTER_NAME.yaml" values_part.yaml > header_part.yaml
#         cp header_part.yaml updated.yaml
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | yq 'del(.gateway)' | yq ".loadBalancerIp = env(USE_LOAD_BALANCER_IP)" | sed 's/^/  /' >> updated.yaml
#         cat updated.yaml > "$CLUSTER_NAME.yaml"
#       fi

#       echo "Result after adding loadBalancerIp flag:"
#       cat "$CLUSTER_NAME.yaml"

#     elif [ "$ACTION" = "rm" ]; then
#       if [ "$SERVICE_MESH" = "istio" ]; then
#         echo "Remove loadBalancerIp flag with gateway:"
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | sed 's/^/  /' > values_part.yaml
#         awk '/values: \|/{print $0; exit} {print}' "$CLUSTER_NAME.yaml" values_part.yaml > header_part.yaml
#         cp header_part.yaml updated.yaml
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | yq 'del(.gateway)' | sed 's/^/  /' >> updated.yaml
#         cat updated.yaml > "$CLUSTER_NAME.yaml"
#       else
#         echo "Remove loadBalancerIp flag:"
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | sed 's/^/  /' > values_part.yaml
#         awk '/values: \|/{print $0; exit} {print}' "$CLUSTER_NAME.yaml" values_part.yaml > header_part.yaml
#         cp header_part.yaml updated.yaml
#         cat "$CLUSTER_NAME.yaml" | yq '.values' | yq 'del(.loadBalancerIp)' | sed 's/^/  /' >> updated.yaml
#         cat updated.yaml > "$CLUSTER_NAME.yaml"
#       fi

#       echo "Result after removing loadBalancerIp flag:"
#       cat "$CLUSTER_NAME.yaml"
#     fi

#     git config user.name "FouadDevOps"
#     git config user.email "algahmif@aetna.com"
#     git add "$CLUSTER_NAME.yaml"
#     COMMIT_ACTION="add"
#     if [ "$ACTION" = "rm" ]; then
#       COMMIT_ACTION="remove"
#     fi
#     if git status | grep -q "Changes to be committed"; then
#       echo "Committing and pushing changes..."
#       git commit -m "$COMMIT_ACTION loadBalancerIp flag - $GITHUB_RUN_ID"
#       git push -u origin "$BRANCH_NAME"
#       gh pr create --fill
#       gh pr merge "$BRANCH_NAME" --admin --squash
#     fi
#   fi
# fi
