# shared targets for every terraform project directory; each project's
# Makefile sets any overrides and then does: include ../common.mk
TF        ?= terraform
INIT_ARGS ?=
PLAN      ?= tfplan

.PHONY: init fmt validate plan apply destroy output graph clean shell

init:
	$(TF) init $(INIT_ARGS)

fmt:
	$(TF) fmt -recursive

validate: fmt
	$(TF) validate

plan: validate
	$(TF) plan -out=$(PLAN) $(PLAN_ARGS)

apply:
	$(TF) apply $(PLAN)
	rm -f $(PLAN)

destroy:
	$(TF) destroy

output:
	$(TF) output

graph:
	$(TF) graph | dot -Tsvg > graph.svg && wslview graph.svg

clean:
	rm -f $(PLAN) graph.svg

shell:
	$$($(TF) output -raw ssh_to_web)
