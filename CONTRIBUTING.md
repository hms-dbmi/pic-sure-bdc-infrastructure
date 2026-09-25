# Contributing to pic-sure-bdc-infrastructure

Please read the [PIC-SURE contributing guide](https://github.com/hms-dbmi/pic-sure/blob/main/CONTRIBUTING.md)
first. It covers the code of conduct, filing issues, and how pull requests are reviewed across
every PIC-SURE repository.

## Building and testing this repo

This repository holds the Terraform that deploys PIC-SURE for BioData Catalyst. Applying it
needs Avillach Lab AWS credentials, which we cannot share, so an outside contributor cannot
plan or apply these configurations.

If you find a problem here, please open an issue. We would rather read a clear bug report than
a pull request nobody outside the lab can verify.

Each Terraform configuration lives in its own directory and is run from inside that directory:

```bash
terraform init
terraform plan
```
