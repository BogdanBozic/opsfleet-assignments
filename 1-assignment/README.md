# Automate AWS EKS cluster setup with Karpenter, while utilizing Graviton and Spot instances.
## Description
You've joined a new and growing startup.

The company wants to build its initial Kubernetes infrastructure on AWS. The team wants to leverage the latest autoscaling capabilities by Karpenter, as well as utilize Graviton and Spot instances for better price/performance.

They have asked you if you can help create the following:

Terraform code that deploys an EKS cluster (whatever latest version is currently available) into a new dedicated VPC

The terraform code should also deploy Karpenter with node pool(s) that can deploy both x86 and arm64 instances

Include a short readme that explains how to use the Terraform repo and that also demonstrates how an end-user (a developer from the company) can run a pod/deployment on x86 or Graviton instance inside the cluster.

---

Deliverable: A git repository containing all the necessary infrastructure as code needed in order to recreate a working POC of the above architecture. Your repository may be either public or private. If private please ensure to share it with the relevant reviewer.

## HOW-TO

Inside the Terraform directory, I've placed a Makefile file with functions created for this particular use case: someone is to test what I've written here with minimal manual interference. I guess all the variables are ok for anyone, just pay attention to the network CIDR so that it doesn't overlap with an existing one.

I've included the "default" variables inside terraform.tfvars file. That one is usually ignored and never used by default but for this particular use-case I'm leveraging it being automatically read by Terraform.

Statefile is one and is stored locally against all the best practices for the sake of simplicity.

Oh, and yes, I've used Terraform, not OpenTofu for the sake of simplicity.

### Actual setup

I assume you're using a Linux or a Mac machine to test this, I have no idea how this would work on Windows.
I've used Terraform ```v1.14.0``` here.

```cd terraform/envs/dev```

To spin up the infrastructure just run ```make apply```.

To test pod placement run ```kubectl apply -f deploy_to_amd.yaml``` or ```kubectl apply -f deploy_to_arm.yaml```. Observe the placement and once done do ```kubectl delete -f deploy_to_arm.yaml``` and ```kubectl delete -f deploy_to_amd.yaml```.

To finally tear all this down run ```make destroy```.

I've tried to make it as easy for use as possible with clear distinction of the two architecture types for pods placement.
To avoid specifying a var file I've placed everything in the "dev" directory, but in real-life situation I would have kept all the configuration in a separate directory with all this code in a general "stack" dir or something of sorts.

## Notes about the code

I wrote this code with this in mind:

- I have to keep it short and simple
- I have to stick to the requirements
- I will not be solving problems that haven't been introduced
- I will take the context in which this code is being written into consideration when structuring and writing it

What this means in practice is:
- Modules don't have any flags or heavy configuration as input
- There aren't any load balancers introduced
- DNS doesn't exist in any form
- Nor does encryption so I could freely create and destroy with less time consumed and no deletion timeframes to interfere
- Security groups or anything else, probably, aren't expandable or configurable outside the place they are being defined at
- Outputs are minimal to suit this particular use-case