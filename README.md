# S3-LifeCycle-RoleAcces
Terraform template to create 2 S3 bucket with access to role and 1 IAM user including life cycle policy

Pre-Requisites

•	Make sure the EKS role is already created. This template does not create that role

•	Make sure the particular IAM user who want access to 2nd Bucket is already there and have policy attached to access S3 buckets. No any policy will be attached to this user, because this is not requested. Anyway, this user cannot access 1st bucket because of S3 Bucket policy in place

•	In order to make "Terraform Destroy" to work, a particular user account (The user account which is used in Terraform provider) must be also given access to the 2 S3 buckets. That user name is captured as “Terraformuser” in variable section

A) What are the Resources created using this Terraform template?

•	2 S3 Buckets

•	2 Bucket policies

•	1 IAM policy

B) Resources Explanation

•	First S3 Bucket
1.	Have life cycle policy of expiring items with prefix "bulk-submissions/*" after 365 days
2.	Have S3 Bucket policy which will allow only the mentioned role and Terraform super user to have access
3.	Version enabled

•	Second S3 Bucket
1.	Have life cycle policy of moving all items to Glacier after 30 days and expiring items after 365 days
2.	Have S3 Bucket policy which will allow only the mentioned role, IAM user and Terraform super user to have access
3.	Version enabled

•	IAM policy
1.	An IAM policy will be created and attached to mentioned role allowing access to only 2 of above S3 bucket. Meaning the EKS role cannot access any other S3 buckets

