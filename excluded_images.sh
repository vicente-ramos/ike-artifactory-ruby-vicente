#!/bin/bash
IMAGES=()
echo "Proccessing application $1"
TEMP_NAMESPACES=$(kubectl get namespace)
NAMESPACES=$(echo "$TEMP_NAMESPACES" | sed 1d)
while read line; do
    NAMESPACE=$(echo $line | cut -f 1 -d' ')
    echo "Getting deployment for $1 in namespace $NAMESPACE"
    DEPLOYMENT=$(kubectl describe deployment/$1 -n $NAMESPACE)
    IMAGE_LINE=$(echo "$DEPLOYMENT" | awk "/Image:/")
    IMAGE=$(echo $IMAGE_LINE | cut -f 3 -d':')
    echo "The deployment: $IMAGE"
    if [ ! -z "$IMAGE" -a "$IMAGE" != " " ]; then
        IMAGES+=("$IMAGE")
    fi
done <<< "$NAMESPACES"

printf '%s\n' "${IMAGES[@]}"
