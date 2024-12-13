set shell := ["bash", "-uec"]

[group('maint')]
@default:
    just --list

[group('setup')]
setup: zip plan
    terraform apply tfplan

[group('setup')]
@_tf_init:
    terraform init -upgrade

[group('setup')]
@plan: _tf_init
    terraform plan -out=tfplan

[group('setup')]
[working-directory: 'src']
@zip:
    corepack enable
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 pnpm install
    zip --quiet -r ../lambda_function.zip .

[group('test')]
e2e: clean teardown setup test

[group('test')]
@test: setup
    #!/usr/bin/env bash
    lambda_function=$(terraform output -raw lambda_function_name)
    region=$(terraform output -raw aws_region)
    aws lambda invoke --region $region --function-name $lambda_function \
        --payload '{}' --cli-binary-format raw-in-base64-out response.json || true
    cat response.json || true
    rm -f response.json || true

[group('teardown')]
teardown: _tf_init
    terraform destroy -auto-approve

[group('teardown')]
@taint:
    terraform taint aws_lambda_function.sqs_processor

[group('teardown')]
@clean:
    rm -rf .terraform tfplan lambda_function.zip src/node_modules

[group('maint')]
@fmt:
    terraform fmt -recursive .
    prettier --ignore-path=.prettierignore --config=.prettierrc.json --write .
    just --unstable --fmt
