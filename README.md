# The Checkout.com developers guide to AWS ECS deployments

You're a developer and new to Checkout.com and/or to AWS but you'd like to deploy a service in no time? Then that's the place to readup all the necessary information, all gathered from a developer-centric point of view. Save travels!

- [Go here if you have to setup your accounts and tools](#general-accounts-setup-login)
- [Or jump straight in here if you just want to deploy a new service and you think you might have missed a detail](#deploying-a-service-to-aws-ecs)

## General accounts, setup, login

Write a mail to [itrequests@checkout.com](mailto:itrequests@checkout.com) and ask them for access to AWS London. In your mail, ask also for

- Access rights to access ECS
- Setting up MFA
- Creation and delivery of your permanent access key

Use the files in [aws-dot-folder](aws-dot-folder), replace the provided permanent access key and id and place them at `$HOME/.aws`

### AWS CLI

Install AWS CLI tool like described here: <http://docs.aws.amazon.com/cli/latest/userguide/installing.html>

### Temporary access key and MFA

In order to use AWS cli tools, you'll need to get a temporary access key with the help of your MFA device

- Basic [instructions](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli)
- Helpful little [script](https://github.com/EvidentSecurity/MFAonCLI/blob/master/aws-temp-token.sh)

  This prints some `export` statements you can easily copy & paste in your console

For both variants you'll need your `arn-of-the-mfa-device`. Finding the `arn` is a little odd, first login to <https://console.aws.amazon.com>.

- Then either go to <https://console.aws.amazon.com/iam/home?region=eu-west-2#/users/{mailAdress}> with your user-account replaced
- Or click yourself through
  - Once logged in, click on your mail adress
  - Choose *My Security Credentials*
  - In the left panel, choose *Users*
  - Find youself in the list of users
  - Choose Tab *Security Credentials*. `arn-of-the-mfa-device` is listed right to **Assigned MFA device**

You can now create your temporary access token by running

```bash
./aws-temp-token.sh default arn-of-the-mfa-device on-time-pass-code-from-mfa-device
```

### Docker

Before using the usual docker commands you have to login into the Docker ECR registry using the `aws` command. See [detailed instructions](
http://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html).

In a nutshell you have to run

```bash
aws ecr get-login
```

which will return you a the `docker login` command to execute.

If you're using cake there's also a cake script available, see for example in the [checkout-ap-sepa](https://github.com/CKOTech/checkout-ap-sepa/blob/master/build.cake) project.

## Deploying a service to AWS ECS

Once you have a Docker container running locally and want this container to be deployed and reachable from the internal or external network on AWS, follow these instructions.

### Creation of Registry, Task Defintion, Service and Load Balancer

1. Write a mail to [itrequests@checkout.com](mailto:itrequests@checkout.com) and ask them to create a Docker registry on ECR for your project and to assign you the corresponding rights.
2. Push your image to the registry assigned to it on ECR.
1. Edit the initial task definition. [task-definition.json](task-definition/task-definition.json) can get you started as a template.
2. Create the intial task definitions for the various environments on ECS.

   - dev
   - qa
   - sandbox
   - test
   - uat

   There's a small script at [create-task-defintions.sh](task-definition/create-task-definitions.sh) which automates this for you.

3. Write a mail to [itrequests@checkout.com](mailto:itrequests@checkout.com) and ask them to create the associated service and load balancers for you.

   IT will require you to provide the following information:
   - The name of the cluster the service is created on
   - A health endpoint. Usually this will be `/_system/health` if you use the health check middleware from [AppMetrics](https://github.com/AppMetrics/AppMetrics).
   - The base path for routing

   There's a catch, make sure that your service operates under a `BasePath` and that this path is stated as an environment variable in the task definition. From my understanding so far IT will use this information to appropriatly setup the routing of the load balancer.

### Re-deploy a service with another version of your Docker image

Say you have a new verson of your Docker image and want to update the existing services to use that new version. You're lucky, there's a neat little script doing all the work for you: 

<https://github.com/silinternational/ecs-deploy>

In a nutshell you...

- provide it the name of the cluster and the service you'd like to update 
- specify the name and tag of the docker image you'd like to update your service to

And the script will...

- Fetch the existing task definition
- Update it to use the docker image you specified
- Recreate a new revision of the task definition
- Recreate the service using the new revision of the task definition






