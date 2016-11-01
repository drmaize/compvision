# Bisque Resource Manager

The Bisque Resource Manager is a collection of modules for integrating local image workflows with Bisque. The system is built to maintain data coherence on both the local and remote servers.

## Installation

Pull the repository. Dependencies are included in the Includes folder. Some dependencies are modified, and some are unused with the newest version of the Bisque Resource Manager.

## Usage

1) After installation, create a file called .ConfigOptions in the BRM root directory. A sample file looks like the following:
```
########################################
# Configuration file to adjust options #
########################################

[credentials]
username = 
password = 

[urls]
bisque_root = http://bisque.iplantcollaborative.org/

[mysql]
username = 
password = 
host = 
database = 

[twitter]
username = 
password = 
access_token = 	
access_token_secret = 
api_key = 
api_secret = 
```

Note: Credentials are for a BisQue account. Twitter is optional.

2) Setup a MySQL database for image to metadata mapping. This is important for maintaining consistency between local resources and bisque resources.

3) Create an upload script. An example script is included as "UploadToBisque.py".

4) Call this script any time during your image processing pipeline.

## TODO

Generic database structure would improve other users' experience. 
Remove old packages that are no longer used.

## History

V 0.10 - Finalized Upload on 11/1/2016

## Contact

Wayne Treible
Computer and Information Science
University of Delaware
wtreible@udel.edu


