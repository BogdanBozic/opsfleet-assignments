.PHONY: init plan apply apply-core apply-crds apply-karpenter destroy

TERRAFORM ?= terraform

init:
	$(TERRAFORM) init

plan:
	$(TERRAFORM) plan

apply: apply-core apply-crds apply-karpenter

apply-core:
	$(TERRAFORM) apply \
		-target=module.network \
		-target=module.eks \
		-auto-approve

apply-crds:
	$(TERRAFORM) apply \
		-target=module.crds \
		-auto-approve

apply-karpenter:
	$(TERRAFORM) apply \
		-target=module.karpenter \
		-auto-approve

destroy:
	$(TERRAFORM) destroy -auto-approve
