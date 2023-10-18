# Following bug can occur

```{"statusCode":500,"error":"Internal Server Error","message":"An internal server error occurred."}```

## Fix

Delete the *.kibana* index, et voila. Seems to be a migration issue. 

```
kubectl exec sts/sandbox-security-analytics-nodes -it -- bash
curl https://localhost:9200/_cat/indices -k -u admin
curl -XDELETE https://localhost:9200/.kibana_1 -k -u admin
```