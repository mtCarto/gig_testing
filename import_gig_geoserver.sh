#!/bin/bash
printf "\n\nCreating workspace\n"
TIMEFORMAT=' --> Workspace created in %R seconds.'
time {
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<workspace><name>gig</name></workspace>" http://localhost:8080/geoserver/rest/workspaces
printf "\n\n"
}

for i in range {0..2}
  do
  printf "\n\nAdding the repo to geoserver\n"
  curl -X PUT -H "Content-Type: application/json" -d '{
          "dbHost": "localhost", 
          "dbPort": "5432",
          "dbName": "gigTest",
          "dbSchema": "public",
          "dbUser": "postgres",
          "dbPassword": "postgres",
          "authorName": "geogig",
          "authorEmail": "geogig@geogig.org"
  }' "http://localhost:8080/geoserver/geogig/repos/repo_$i/init"

  printf "\n\nAdding the repo as a data store\n"
  curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<dataStore><name>geogig_store_$i</name><connectionParameters><entry key=\"geogig_repository\">geoserver://repo_$i</entry></connectionParameters></dataStore>" http://localhost:8080/geoserver/rest/workspaces/gig/datastores
done