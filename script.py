#!/bin/bash

#Create a pub/sub topic
gcloud pubsub topics create wajida-topic

#Create and deploy a cloud function
gcloud beta functions deploy wajida-pe-cloud-function --region us-central1 --runtime python37 --trigger-resource wajida-topic --trigger-event google.pubsub.topic.publish --source gs://wajida-pe-bucket/function-source.zip
