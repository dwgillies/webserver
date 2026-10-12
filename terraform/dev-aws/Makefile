include ../common.mk

.PHONY: nat-off nat-on

# plan only; set enable_nat in terraform.tfvars to make the choice stick
nat-off:
	$(MAKE) plan PLAN_ARGS="-var enable_nat=false"

nat-on:
	$(MAKE) plan PLAN_ARGS="-var enable_nat=true"
