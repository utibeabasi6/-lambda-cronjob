up: 
	@terraform apply --auto-approve

down: 
	@terraform destroy --auto-approve

init:
	@terraform init