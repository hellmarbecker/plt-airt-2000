## Show the currently selected environment ID and cluster ID

```bash
export CC_ENV=$(ccloud environment list -o human | awk '/\*/ { print $2; }')
export CC_CLUSTER=$(ccloud kafka cluster list -o human | awk '/\*/ { print $2; }')
```
## List all the ksqldb apps, by name
```bash
ccloud ksql app list -o json | jq ".[].name"
```
## Dismantle all apps
```bash
ccloud ksql app list -o json | jq ".[].id" | xargs ccloud ksql app delete
```
## Create a KSQL app on the current cluster
```bash
export CC_KSQLAPP=$(ccloud ksql app create my_app -o json | jq .id)
```
## Check app status, looping until it is up (or failed)
```bash
while
    app_status=$(ccloud ksql app list -o json | jq ".[] | select(.id=${CC_KSQLAPP}) | .status")
    echo $app_status
    [[ $app_status =~ "PROVISIONING" ]]
do
    sleep 5
done
```
