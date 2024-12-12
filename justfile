set shell := ["bash", "-uec"]

default:
    @just --list

fmt:
    terraform fmt -recursive .
    prettier --ignore-path=.prettierignore --config=.prettierrc.json --write .
    just --unstable --fmt

zip:
    cd src && npm install
    cd src && zip --quiet -r ../lambda_function.zip .

_tf_init:
    terraform init

taint:
    terraform taint aws_lambda_function.sqs_processor

plan: zip
    terraform plan -out=tfplan

deploy: plan
    terraform apply tfplan

destroy: _tf_init
    terraform destroy -auto-approve

clean:
    rm -rf .terraform tfplan lambda_function.zip src/node_modules
