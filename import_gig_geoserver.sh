# !/bin/bash
printf "\n\nCreating workspace\n"
TIMEFORMAT=' --> Workspace created in %R seconds.'
time {
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<workspace><name>gig</name></workspace>" http://localhost:8080/geoserver/rest/workspaces
printf "\n\n"
}

NUM_LAYERS=2
TOTAL_REPOS=1000
tablenum=0
for (( n=0; n<$TOTAL_REPOS; n++))
  do
  printf "\n\nAdding the repo to geoserver\n"
  curl -X PUT -H "Content-Type: application/json" -d '{
          "dbHost": "localhost", 
          "dbPort": "5432",
          "dbName": "gigRepos2",
          "dbSchema": "public",
          "dbUser": "postgres",
          "dbPassword": "postgres",
          "authorName": "geogig",
          "authorEmail": "geogig@geogig.org"
  }' "http://localhost:8080/geoserver/geogig/repos/repos_$n/init"
  
  printf "\n\nAdding the repo as a data store\n"
  curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<dataStore><name>geogig_store_$n</name><connectionParameters><entry key=\"geogig_repository\">geoserver://repos_$n</entry></connectionParameters></dataStore>" http://localhost:8080/geoserver/rest/workspaces/gig/datastores
  
  for (( i=0; i<$NUM_LAYERS; i++))
    do
      export table="test_table2_$tablenum"
      export reponame="repo_$n"
      export repo="postgresql://127.0.0.1:5432/gigRepos/$reponame?user=postgres&password=postgres"
      
      #export from geogig repo
      geogig --repo $repo shp export test_table2_$tablenum test_table_$tablenum.shp
      zip test_table_$tablenum.zip test_table_$tablenum.shp test_table_$tablenum.dbf test_table_$tablenum.prj test_table_$tablenum.shx test_table_$tablenum.fix
       
      #import data to gs_gig datastore
      curl -v -u admin:geoserver -XPUT -H "Content-type: application/zip" --data-binary @test_table_$tablenum.zip http://localhost:8080/geoserver/rest/workspaces/gig/datastores/geogig_store_$n/file.shp
      
      # printf "\n\nAdding the gig store as a layer\n"
      # curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<featureType><name>test_table_$tablenum</name></featureType>" http://localhost:8080/geoserver/rest/workspaces/gig/datastores/geogig_store_$i/featuretypes
      rm test_table_*
      tablenum=$(($tablenum + 1))
    done
done