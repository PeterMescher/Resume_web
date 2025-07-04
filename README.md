# Peter Mescher's Implementation of the Cloud Resume Challenge (AWS Edition) - In Progress <!-- Omit in TOC -->

This is a basic 'portfolio project' that touches on many elements of implementing a basic project in a cloud provider. This implementation of it includes:

- A static HTML page with a stylesheet (It happens to be a very-basic clone of my Resume)
- A javascript file implementing an API call to a visit counter
- Making the content available via CloudFront
- Catching the API call with API Gateway
- An ACM Certificate so all this is served up via HTTPS
- Implementing the counter with a Python program run on Lambda
- Using a DynamoDB table to keep track of the counter(s)
- A public zone hosted in Route53 mapped to CloudFormation for the content, and a record mapped to API Gateway for the counter
- The NS entries for the public zone hosted in a separate account that owns the root domain
- IAM to glue it all together
- The use of Playwright to test the API's functionality
- Implementing the whole solution with an IaC tool. (I chose Terraform, because I had some training on it previously)
- Implementing source control for the IaC and Content. (This GitHub repo)

Future updates:

- A full CI/CD pipline via GitHub Actions or CodeDeploy
- Yes, I know it needs tags, since those are the core of AWS Resource and Cost management.
- Locking down the API so it can only be called from my authorized web pages. (vs. just the CORS I'm using now)
- User authentication, because why not?
- Through the UUID, set it up so the same solution could be implemented multiple times in a single AWS account.

# Overall Architecture

![Basic Architecture](CRC_basic_arch.drawio.svg)

The basic infrastructure components are not very extensive, but it does provide a simple 3-tier serverless implementation, with a presentation tier (the website served up by CloudFront), an application tier (the lambda function), and a data tier (the DDB table.)

The content consists of:

- The Resume file itself (HTML)
- The Visitor Counter API Call (JavaScript)
- A Style Sheet (CSS) (And I agree, it's not very stylish!)

This is stored in an S3 bucket, accessible only by CloudFront. In keeping with AWS Best Practices, the bucket itself is not directly accessible to users.

The JavaScript file calls on the API Endpoint, which exposes a single method, GET, which takes the filename of the page being counted, and receives back the current visitor count (incremented by 1, of course.) If there were to be other pages on the site, each could have its own visitor count with no changes to the code necessary. (The Javascript that calls it uses the filename of the calling page.)

The code to implement the counter is a small python script that is run via a Lambda function. The python reads the appropriate entry from DDB, increments it, and stores the result back in DDB. (If the entry for the page does not already exist because this is the first time it has been visited, it will be created.)

DNS for the site is provided by Route53. The account holding the site and infrastructure has a public DNS zone, with entries for crc.example.com, www.crc.example.com, and api.crc.example.com  (Obviously not hosted at example.com... the actual root domain and subdomain are variables in the Terraform)

The site is set up so the root domain can be in another AWS account (so you could, in theory, host as many different copies of this as you like, one per AWS account; I hope to change this in the future so multiple implementations can be put in the same AWS account.) The IaC code will handle creating the NS entries in the root domain's Route53 environment.

The traffic to/from the user is secured via an ACM Certificate. (The IaC code also handles the DNS-based certificate validation.)  Both CloudFront and the API Gateway will only pass HTTPS to the user.

# Deployment Notes

The code necessary to deploy the site (including the site content files) is in the terraform directory in this repo.
Also included is a template tfvars and tfbackend that will need to be customized for your deployment.

In the root directory for this repo is a JSON file with the IAM permissions necessary on the account that owns the root domain. This means that you do *not* need to give this deployment full Administrator access to what is likely a very important AWS account.  All the permissions allow it to do is list/add/remove RecordSets for your R53 configuration.

Prior to running a Terraform Plan, you will need to set up AWS CLI profiles on your local machine for the target account, and for the account that owns the root domain. On my local machine, the target account is an SSO login through an AWS organization, and the root domain account is accessed through an API key.  (Of note is that the credentials are all done with AWS CLI profiles, and *not* explicitly present in the providers.tf)  

In keeping with best practices, there is no sensitive information in the tfvars/tfbackend files, in case they are accidentally included in a Git repo. (Nor are environment variables referencing the credentials used anywhere in the code, as they would end up stored in .tfstate)

The TF backend is currently set up to use an S3 bucket, but of course any of the options available (local, Terraform Cloud, etc.) will work fine. The backend can be accessed via the AWS profile of your choice (so it could be an entirely separate account from the target account, or the root domain account.)

# Testing

This repo includes a simple PlayWright scaffold to test the api. To run, (assuming you have PlayWright installed) you'll need the dotenv npx package, and using the provided .env.template, fill it in with the api domain and the base domain (for CORS purposes.)  Then 'npx playwright test' will execute the necessary API calls.

(Yes, future plans involve a test fixture to make sure the actual web page is correctly accessible, and that the counter within it works.)