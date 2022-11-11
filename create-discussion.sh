#!/bin/sh

export title=$(sh sample_title.sh)
export body=$(cat sample_discussion_body)
gh api graphql -f "body=$body" -f "title=$title" -f query='mutation CreateDiscussion($title: String!, $body: String!){
      createDiscussion(input: {repositoryId: "R_kgDOIXQxIg", categoryId: "DIC_kwDOIXQxIs4CSWZz", body: $body, title: $title}) {

        # response type: CreateDiscussionPayload
        discussion {
          id
        }
      }
    }'
