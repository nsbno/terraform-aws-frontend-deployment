# Example
This example requires:
1. An AWS account: a facilitating _service_ account.
2. An AWS account: an _environment_ account, e.g., _test_, _stage_ or _prod_.
3. A source S3 bucket in the _service_ account.
4. A zip file in the source s3 bucket.
5. A target S3 bucket in the _environment_ account.

The set up in `account_a/` creates a Lambda function in the _service_ account that can be used to unzip a ZIP file, and sets up permissions that allows it to be invoked from the _environment_ account.

The set up in `account_b/` invokes the Lambda function in the _service_ account.

Open up a terminal, log in to account A, your _service_ account, and run:
```
$ cd account_a \
  && terraform init \
  && terraform apply \
    -var service_account_id="<id-of-account-a> \
    -var trusted_account_id="<id-of-account-b>" \
    -var source_bucket="<s3-bucket-in-account-a>"
```

Open up a terminal, log in to account B, your _test_, _stage_ or _prod_ account, and run:
```
$ cd account_b \
  && terraform init \
  && terraform apply \
    -var service_account_id="<id-of-account-a>" \
    -var trusted_account_id="<id-of-account-b>" \
    -var source_bucket="<s3-bucket-in-account-a>" \
    -var source_key="<s3-key-of-zip-file>" \
    -var target_bucket="<s3-bucket-in-account-b>"
```
