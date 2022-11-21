#!/bin/sh
set -euo pipefail

REPOSITORY_OWNER="m-hamashita"
REPOSITORY_NAME="create-adr-workflow"
TEMPLATE_ID=57

# get repositoryId
repository_id=$(gh api graphql -f query='
    query {
        repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
            id
        }
    }' --jq '.data.repository.id')

# get categoryId
category_id=$(gh api graphql -f query='
    query {
        repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
            discussionCategory(slug: "ADR") {
                id
            }
        }
    }' --jq '.data.repository.discussionCategory.id')

# increment ADR number
adr_num=$(gh api graphql -f query='
    query {
        repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
            discussions(first: 10, orderBy:{field:CREATED_AT, direction: DESC}) {
                nodes {
                    title
                }
            }
        }
    }' --jq '.data.repository.discussions.nodes[].title' | grep ADR | sed -e 's/ADR \([0-9]*\).*/\1/' | awk '$0>x{x=$0};END{print x+1}')

title="ADR "$adr_num". "${1:-""}
body=$(gh api graphql -f query='
    query {
        repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
            discussion(number: '$TEMPLATE_ID') {
                body
            }
        }
    }' --jq ".data.repository.discussion.body")

# create ADR discussion and get discussionId
discussion_id=$(gh api graphql -f query='
    mutation CreateDiscussion($title: String!, $body: String!){
        createDiscussion(input: {repositoryId: "'$repository_id'", categoryId: "'$category_id'", body: $body, title: $title}) {
            discussion {
                id
            }
        }
    }' --jq ".data.createDiscussion.discussion.id" -f "body=$body" -f "title=$title")

# get draft labelId
draft_label_id=$(gh api graphql -f query='
    query {
        repository(owner: "'$REPOSITORY_OWNER'", name: "'$REPOSITORY_NAME'") {
            label(name: "ADR:draft") {
                id
            }
        }
    }' --jq '.data.repository.label.id')

# add draft label to discussion
gh api graphql -f query='
    mutation($labelableId:ID!, $labelIds:[ID!]!) {
        addLabelsToLabelable(input: {clientMutationId: "", labelableId: $labelableId, labelIds: $labelIds}) {
            clientMutationId
        }
    }' -f labelableId=$discussion_id -f labelIds=$draft_label_id
