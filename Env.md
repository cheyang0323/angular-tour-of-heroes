###### tags: `redhat`,`openshift`
# Environment variable with container image and OpenShift

## Application's environment variables
### NodeJS Application's environment variables

Assume I want to set the environment variable for the database connection string. I put 3 variables in the nodejs code.
1. DB_HOST: Database server name or ip address
2. DB_USER: Database user name
3. DB_PASSWORD: Database password
```
process.env.DB_HOST
process.env.DB_USER
process.env.DB_PASSWORD
```
Prepare a Dockerfile that includes those environment variables
```
FROM registry.access.redhat.com/ubi8/nodejs-14:1-72
...
ENV DB_HOST=192.168.1.100
ENV DB_USER=test
ENV DB_PASSWORD=password
...
CMD ["node", "server.js"]
```
Running the container like this
```
docker run -d --name app -e DB_HOST=10.1.2.3 \
-e DB_USER=user1 \
-e DB_PASSWORD=StrongPass \
app
```
### Deploy the application on OpenShift
```
oc new-app --docker-image=xxx/your-image:version
```
Create a ConfigMap to set the environment variables
```
oc create cm env-db --from-literal=DB_HOST=mssql-server \
--from-literal=DB_USER=user1
```
Create a secret for db's password
```
oc create secret generic db-secret \
--from-literal=DB_PASSWORD="MyPassword"
```
Add some configuration in deployment file
```
...
      envFrom:
      - configMapRef:
          name: your-env-config
...
```
Or you can use patch command instead
```
oc patch deployment app-name -p '{"spec": {"template": {"spec": {"containers": [{"name":"app-name", "envFrom": [{"configMapRef":{"name":"env-db"}}, {"secretRef":{"name":"db-secret"}}] }] }}}}'
```
