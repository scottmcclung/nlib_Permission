# Custom Permission Checker Apex Action for Flows

An Apex Action for Lightning Flow that determines if a given user has been assigned a custom permission.

Flows can use the native global $Permission variable to determine whether the *current* user has a custom permission.
This Action allows the flow to determine if *any* user has a custom permission. 

## Installation

There are multiple ways to install the action into one of your environments.

#### Scratch org

Click here to install this into a scratch org and try it out.

[![Deploy to SFDX](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com?template=https://github.com/scottmcclung/nlib_Permission.git)


#### Sandbox

Click here to install the component to your sandbox.

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=scottmcclung&repo=nlib_Permission)


#### Any environment

Use one of these links to install the component as an unlocked package.

  * Production or Developer orgs: [https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1U000007cCZgQAM](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1U000007cBXfQAM)
  * Sandbox orgs: [https://test.salesforce.com/packaging/installPackage.apexp?p0=04t1U000007cCZgQAM](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t1U000007cBXfQAM)


#### Using SFDX

Installation using the [sfdx cli](https://developer.salesforce.com/tools/sfdxcli) and [Shane McLaughlin's sfdx plugin](https://github.com/mshanemc/shane-sfdx-plugins)
~~~~
sfdx plugins:install shane-sfdx-plugins
sfdx shane:github:package:install -g scottmcclung -r nlib_Permission
~~~~

## Configuration

Add an Apex Action element to your flow and choose 'User Has Permission?' in the Apex Action lookup field.

![Action Configuration](/images/ActionConfiguration.png)

Provide the user id and the developer name (api name) of the custom permission to be checked for in the inputs tab.

![Action Input Configuration](/images/ActionInputConfiguration.png)

Add a boolean variable that will receive the result of the check in the output tab.

![Action Output Configuration](/images/ActionOutputConfiguration.png)
