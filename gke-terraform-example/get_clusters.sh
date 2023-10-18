#!/bin/bash

gcloud --project=arnold-f6q-kong container clusters get-credentials primary
gcloud --project=arnold-f6q-kong container clusters get-credentials secondary
