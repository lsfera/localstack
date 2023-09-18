provider "aws" {
    region = "eu-west-1"
    access_key = "anaccesskey"
    secret_key = "asecretkey"
    skip_credentials_validation = true
    skip_requesting_account_id = true 
    skip_metadata_api_check = true
#   s3_use_path_style = true
    
    endpoints {
        s3  = "s3.eu-west-1.localhost.localstack.cloud"
        sns = "http://localstack:4566"
        sqs = "http://localstack:4566"
  }
}

resource "aws_sqs_queue" "queue" {
  name      =   "s3-event-notification-queue"
  policy    =   <<POLICY
  {
      "Version":"2012-10-17",
      "Statement":[
          {
              "Effect" : "Allow",
              "Principal":"*",
              "Action":"sqs:SendMessage",
              "Resource":"arn:aws:sqs:*:*:s3-event-notification-queue",
              "Condition":{
                  "ArnEquals":{"aws:SourceArn":"${aws_s3_bucket.bucket.arn}"}
              }
          }
      ]      
  }
  POLICY
}

resource "random_string" "id" {
  length    =   "5"
  special   =   false
  upper     =   false
}

resource "aws_s3_bucket" "bucket" {
  bucket    =   "mybucket-s3-g2-${random_string.id.result}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  #count     =   "${var.event ? 1 :  0}"
  bucket    =   "${aws_s3_bucket.bucket.id}"

  queue {
      queue_arn =   "${aws_sqs_queue.queue.arn}"
      events    =   ["s3:ObjectCreated:Put"]
  }
}