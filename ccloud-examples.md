## List all the ksqldb apps, by name

    ccloud ksql app list -o json | jq ".[].name"
    
## Dismantle all apps

    ccloud ksql app list -o json | jq ".[].id" | xargs ccloud ksql app delete
