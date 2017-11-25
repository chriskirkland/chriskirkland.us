+++
date = "2017-08-14T15:38:58-05:00"
description = ""
draft = true
tags = []
title = "cka"
topics = []

+++

## Notes
### Scheduling

* scheduling features (Beta 1.6)
  * node affinity & anti-affinity - scheduling rules that govern what nodes a pod can schedule to based on node labels (in PodSpec)
  * taints & tolerations - don't schedule/evict pods that don't explicitly tolerate a nodes taint (in PodSpec)
  * pod affinity & anti-affinity - scheduling rules that govern what nodes a pod can schedule to based on other pods on that node (in PodSpec)
  * customer schedulers -  `schedulerName` in PodSpec
* configuring multiple schedulers
* display scheduler events

```bash
### create a svc/deployment/pod
✘ ⎈ (dev-mex01-carrier5) cmkirkla@mymbp:~
(ins)> k create -f https://raw.githubusercontent.com/chriskirkland/kubernetes-configs/master/docktor-service.yaml
››› Running kubectl
service "docktor" created
deployment "docktor" created
✔ ⎈ (dev-mex01-carrier5) cmkirkla@mymbp:~
(ins)> kubectl delete -f https://raw.githubusercontent.com/chriskirkland/kubernetes-configs/master/docktor-service.yaml
service "docktor" deleted
deployment "docktor" deleted

### kubernetes events
✔ ⎈ (dev-mex01-carrier5) cmkirkla@mymbp:~
(ins)> kg events -w
››› Running kubectl get
LASTSEEN   FIRSTSEEN   COUNT     NAME      KIND      SUBOBJECT   TYPE      REASON    SOURCE    MESSAGE
2017-08-14 16:58:11 -0500 CDT   2017-08-14 16:58:11 -0500 CDT   1         docktor   Deployment               Normal    ScalingReplicaSet   {deployment-controller }   Scaled up replica set docktor-949005463 to 1
2017-08-14 16:58:11 -0500 CDT   2017-08-14 16:58:11 -0500 CDT   1         docktor-949005463   ReplicaSet             Normal    SuccessfulCreate   {replicaset-controller }   Created pod: docktor-949005463-sbg6j
2017-08-14 16:58:11 -0500 CDT   2017-08-14 16:58:11 -0500 CDT   1         docktor-949005463-sbg6j   Pod                 Normal    Scheduled   {default-scheduler }   Successfully assigned docktor-949005463-sbg6j to 10.130.231.162
2017-08-14 16:58:13 -0500 CDT   2017-08-14 16:58:13 -0500 CDT   1         docktor-949005463-sbg6j   Pod       spec.containers{docktor}   Normal    Pulling   {kubelet 10.130.231.162}   pulling image "chriskirkland/docktor:latest"
2017-08-14 16:58:30 -0500 CDT   2017-08-14 16:58:30 -0500 CDT   1         docktor   Deployment             Normal    ScalingReplicaSet   {deployment-controller }   Scaled down replica set docktor-949005463 to 0
2017-08-14 16:58:31 -0500 CDT   2017-08-14 16:58:31 -0500 CDT   1         docktor-949005463   ReplicaSet             Normal    SuccessfulDelete   {replicaset-controller }   Deleted pod: docktor-949005463-sbg6j
2017-08-14 16:58:46 -0500 CDT   2017-08-14 16:58:46 -0500 CDT   1         docktor-949005463-sbg6j   Pod       spec.containers{docktor}   Normal    Pulled    {kubelet 10.130.231.162}   Successfully pulled image "chriskirkland/docktor:latest"
2017-08-14 16:58:46 -0500 CDT   2017-08-14 16:58:46 -0500 CDT   1         docktor-949005463-sbg6j   Pod       spec.containers{docktor}   Normal    Created   {kubelet 10.130.231.162}   Created container with docker id 9bf3877feff8; Security:[seccomp=unconfined]
2017-08-14 16:58:46 -0500 CDT   2017-08-14 16:58:46 -0500 CDT   1         docktor-949005463-sbg6j   Pod       spec.containers{docktor}   Normal    Started   {kubelet 10.130.231.162}   Started container with docker id 9bf3877feff8
2017-08-14 16:59:17 -0500 CDT   2017-08-14 16:59:17 -0500 CDT   1         docktor-949005463-sbg6j   Pod       spec.containers{docktor}   Normal    Killing   {kubelet 10.130.231.162}   Killing container with docker id 9bf3877feff8: Need to kill pod.
```

### Resources

Scheduling

* http://blog.kubernetes.io/2017/03/advanced-scheduling-in-kubernetes.html
* https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#taints-and-tolerations-beta-feature
* https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
* https://kubernetes.io/docs/tasks/administer-cluster/static-pod/ (manually schedule pod ??)

API Ref

* https://kubernetes.io/docs/api-reference/v1.7/#affinity-v1-core
