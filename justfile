set shell := ["bash", "-uec"]

default:
    @just --list

e2e-test: e2e-test-destroy deploy test-event

e2e-test-destroy: clean destroy

[working-directory: 'src']
zip:
    corepack enable
    pnpm install
    zip --quiet -r ../lambda_function.zip .

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

test-event:
    #!/usr/bin/env bash
    set -x
    lambda_function=$(terraform output -raw lambda_function_name)
    region=$(terraform output -raw aws_region)
    aws lambda invoke \
        --region $region \
        --function-name $lambda_function \
        --payload '{}' \
        --cli-binary-format raw-in-base64-out \
        response.json || true
    cat response.json || true
    rm -f response.json || true

fmt:
    terraform fmt -recursive .
    prettier --ignore-path=.prettierignore --config=.prettierrc.json --write .
    just --unstable --fmt
