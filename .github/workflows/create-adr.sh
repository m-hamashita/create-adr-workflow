#!/bin/sh

ADRNUM=$(gh api graphql --jq '.data.repository.discussions.nodes[].title' -f query='query {
     repository(owner: "m-hamashita", name: "study-github-actions") {
       discussions(first: 10) {
         nodes {
           title
         }
       }
     }
 }'| grep ADR | sed -e 's/ADR \([0-9]*\).*/\1/' | awk '$0>x{x=$0};END{print x+1}')

title="ADR "$ADRNUM". "$1
body=$(gh api graphql --jq '.data.repository.discussion.body' -f query='query {
      repository(owner: "m-hamashita", name: "study-github-actions") {
        discussion(number: 57) {
          body
        }
      }
    }'
)
gh api graphql -f "body=$body" -f "title=$title" -f query='mutation CreateDiscussion($title: String!, $body: String!){
      createDiscussion(input: {repositoryId: "R_kgDOIXQxIg", categoryId: "DIC_kwDOIXQxIs4CSjG2", body: $body, title: $title}) {
        discussion {
          id
        }
      }
    }'
