#!/bin/bash

gcloud --project=$1 container clusters get-credentials primary
gcloud --project=$1 container clusters get-credentials secondary
