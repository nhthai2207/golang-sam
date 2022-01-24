OUTPUT = main # Referenced as Handler in template.yaml
PACKAGED_TEMPLATE = packaged.yaml
S3_BUCKET := $(S3_BUCKET)
STACK_NAME := $(STACK_NAME)
TEMPLATE = template.yaml

test:
	go test ./...

clean:
	rm -f $(OUTPUT) $(PACKAGED_TEMPLATE)

install:
	go get ./...

main: ./function/main.go
	go build -o $(OUTPUT) ./function/main.go

# compile the code to run in Lambda (local or real)
lambda:
	GOOS=linux GOARCH=amd64 $(MAKE) main

build: clean lambda

api: build
	sam local start-api

package: build
	sam package --template-file $(TEMPLATE) --s3-bucket $(S3_BUCKET) --output-template-file $(PACKAGED_TEMPLATE)

deploy: package
	sam deploy --stack-name $(STACK_NAME) --template-file $(PACKAGED_TEMPLATE) --capabilities CAPABILITY_IAM
