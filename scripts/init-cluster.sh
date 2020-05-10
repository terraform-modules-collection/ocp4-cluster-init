#!/usr/bin/env bash
source $HOME/ocp4-cluster-init.env

mkdir -p $WORKDIR/${CLUSTER_NAME}
rm -rf $WORKDIR/${CLUSTER_NAME}/*

printf "Init cluster-config.yaml, in directory %s/%s\n" $WORKDIR  ${CLUSTER_NAME}

cat > $WORKDIR/${CLUSTER_NAME}/install-config.yaml <<-EOF
apiVersion: v1
baseDomain: ${BASE_DOMAIN}
compute:
  - hyperthreading: Enabled
    name: worker
    replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: ${CLUSTER_NAME}
networking:
  clusterNetwork:
    - cidr: 10.128.0.0/14
      hostPrefix: 23
  networkType: OpenShiftSDN
  serviceNetwork:
    - 172.30.0.0/16
platform:
  none: {}
fips: false

pullSecret: '$(echo -n "${PULL_SECRET_B64}" | base64 -D)'
sshKey: '$(echo -n "${SSH_PUB_KEY_B64}" | base64 -D)'
EOF

openshift-install create ignition-configs --dir=$WORKDIR/${CLUSTER_NAME}

printf "Configure s3 client for save installer  assests\n"
mc config host add s3  http://$MINIO_SERVER   $MINIO_ACCESS_KEY $MINIO_SECRET_KEY --api S3v4

printf "Copy ignition configuration to public bucket: %s\n", $PUBLIC_BACKET_NAME
mc cp --recursive $WORKDIR/${CLUSTER_NAME}/*.ign  s3/$PUBLIC_BACKET_NAME/

printf "Copy bootstrap auth configuration to  private bucket: %s\n", $PRIVATE_BACKET_NAME
mc cp  $WORKDIR/${CLUSTER_NAME}/auth/*  s3/$PRIVATE_BACKET_NAME/

printf "Copy cluster metadata to  private bucket: %s\n", $PRIVATE_BACKET_NAME
mc cp  $WORKDIR/${CLUSTER_NAME}/metadata.json  s3/$PRIVATE_BACKET_NAME/

