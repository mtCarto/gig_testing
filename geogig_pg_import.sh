#!/bin/bash
# export repo="postgresql://127.0.0.1:5432/gigRepos/10Mrows_1table?user=postgres&password=postgres" 
#big table import
# geogig init --repo $repo
# geogig config user.name tester --repo $repo
# geogig config user.email tester@test.com --repo $repo
# 
# echo $repo
# geogig --repo $repo pg import  -D gigTest -t manyfeatures -d 10Mrows_1table
# 
# geogig --repo $repo add 10Mrows_1table 
# 
# geogig --repo $repo commit -m "initial commit" 