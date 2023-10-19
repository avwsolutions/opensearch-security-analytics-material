kubectl cp logs-template.json sandbox-security-analytics-nodes-0:/tmp
curl -XPUT -ku admin -H 'Content-Type: application/json' https://localhost:9200/_index_template/logs-fluentd -d@logs-template.json
