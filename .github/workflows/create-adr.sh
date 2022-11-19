#!/bin/sh

REPOSITORY_OWNER="m-hamashita"
REPOSITORY_NAME="create-adr-workflow"
TEMPLATE_ID=57

repository_id=$(gh api graphql --jq '.data.repository.id' -f query='{
    repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
        id
    }
  }'
)
category_id=$(gh api graphql --jq '.data.repository.discussionCategory.id' -f query='{
    repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
      discussionCategory(slug: "ADR") {
        id
      }
    }
  }'
)

adr_num=$(gh api graphql --jq '.data.repository.discussions.nodes[].title' -f query='{
    repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
      discussions(first: 10, orderBy:{field:CREATED_AT, direction: DESC}) {
        nodes {
          title
        }
      }
    }
  }'| grep ADR | sed -e 's/ADR \([0-9]*\).*/\1/' | awk '$0>x{x=$0};END{print x+1}')

title="ADR "$adr_num". "$1
body=$(gh api graphql --jq '.data.repository.discussion.body' -f query='{
    repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
      discussion(number: '$TEMPLATE_ID') {
          body
      }
    }
  }'
)

discussion_id=$(gh api graphql --jq ".data.createDiscussion.discussion.id" -f "body=$body" -f "title=$title" -f query='mutation CreateDiscussion($title: String!, $body: String!){
    createDiscussion(input: {repositoryId: "'$repository_id'", categoryId: "'$category_id'", body: $body, title: $title}) {
      discussion {
          id
      }
    }
}')

draft_label_id=$(gh api graphql --jq '.data.repository.label.id' -f query='{
        repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
          label(name: "ADR:draft") {
            id
          }
        }
    }')

gh api graphql -f query='
  mutation($user:String!, $labelableId:ID!, $labelIds:[ID!]!) {
    addLabelsToLabelable(input: {clientMutationId: $user, labelableId: $labelableId, labelIds: $labelIds}) {
      clientMutationId
    }
  }' -f labelableId=$discussion_id -f labelIds=$draft_label_id -f user=$user
