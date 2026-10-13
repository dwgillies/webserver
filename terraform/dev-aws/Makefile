include ../common.mk

.PHONY: nat-off nat-on

# plan only; set enable_nat in terraform.tfvars to make the choice stick
nat-off:
	$(MAKE) plan PLAN_ARGS="-var enable_nat=false"

nat-on:
	$(MAKE) plan PLAN_ARGS="-var enable_nat=true"

# steps to replace the running docker image
#  cd ~/repo/webserver/terraform/dev-aws
#  make nat-on && make apply        # ~2 min; adds the NAT gateway, EIP, route
#  make shell
#  Then on the web instance:
#  sudo docker pull systembuilder22/nicetry:latest
#  sudo docker rm -f webserver
#  sudo docker run -d --restart unless-stopped --name webserver -p 80:80 --log-driver awslogs --log-opt awslogs-region=us-east-2 --log-opt awslogs-group=/nicetry/web systembuilder22/nicetry:latest
#  curl -s localhost/health; echo; curl -s localhost/foo; echo; sudo docker exec webserver id

#   --log-opt awslogs-region=us-east-2 --log-opt awslogs-group=/nicetry/web systembuilder22/nicetry:latest
#  curl -s localhost/health                         # → {"status":"ok"}
#  curl -s localhost/foo                            # → {"error":"api endpoint undefined: /foo"}
#  sudo docker exec webserver id                    # → uid=1000(node) ...
#  exit
#  Then turn the NAT back off. enable_nat = false is in your terraform.tfvars, so a plain plan does it:
#  make plan && make apply
