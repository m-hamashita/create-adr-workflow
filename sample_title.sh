#!/bin/sh

TITLE=$1
ADRNUM=$(gh api graphql --jq '.data.repository.discussions.nodes[].title' -f query='query {
     repository(owner: "m-hamashita", name: "study-github-actions") {
       discussions(first: 10) {
         nodes {
           title
         }
       }
     }
 }'| grep "ADR" | sed -e 's/ADR \([0-9]*\).*/\1/' | awk '$0>x{x=$0};END{print x+1}')
echo "ADR "$ADRNUM". "$TITLE
