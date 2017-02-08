#!/bin/bash
#END should be the total number of tables in src db MINUS one
#NUM_LAYERS should be number of desired tables per Gig repo, ie. I should have 2 repos with 5 layers
START=0
END=1999
NUM_LAYERS=2
NUM_ITER=$((($END+1)/$NUM_LAYERS))
echo $NUM_ITER

tablenum=0
for (( numrepos=0; numrepos<$NUM_ITER; numrepos++))
  do

  for (( i=0; i<$NUM_LAYERS; i++ ))
    do
      export table="test_table2_$tablenum"
      export reponame="repo_$numrepos"
      export repo="postgresql://127.0.0.1:5432/gigRepos/$reponame?user=postgres&password=postgres"
       
      echo "Creating repo"
      geogig init --repo $repo
      geogig config user.name tester --repo $repo
      geogig config user.email tester@test.com --repo $repo
      
      geogig --repo $repo pg import  -D gigTest -t $table -d $table
      geogig --repo $repo add $table
      geogig --repo $repo commit -m "initial commit of data from $table" 
      
      tablenum=$(($tablenum + 1))
    done
  done
  
echo "Done"
