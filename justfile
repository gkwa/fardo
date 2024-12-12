set shell := ["bash", "-uec"]

default:
    @just --list

fmt:
    terraform fmt -recursive .
    prettier --ignore-path=.prettierignore --config=.prettierrc.json --write .
    just --unstable --fmt

zip:
    cd src && pnpm install
    cd src && zip --quiet -r ../lambda_function.zip .

init: zip
    terraform init

taint:
    terraform taint aws_lambda_function.sqs_processor

plan: init
    terraform plan -out=tfplan

deploy: plan
    terraform apply tfplan

destroy: init
    terraform destroy -auto-approve

clean:
    rm -rf .terraform tfplan lambda_function.zip src/node_modules
