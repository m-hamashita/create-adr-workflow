# create-adr-workflow

## How to use

1. Copy the files under .github/workflows to your repository.
2. Create ADR template discussion
    e.g: https://github.com/m-hamashita/create-adr-workflow/discussions/57
3. Fill `$REPOSITORY_OWNER`, `$REPOSITORY_NAME`, `$TEMPLATE_ID` in [craete-adr.sh](https://github.com/m-hamashita/create-adr-workflow/blob/main/.github/workflows/create-adr.sh) with the number from the ADR template discussion and your repository name.
4. Run `prepare-adr-labels` workflow
5. Create category ADR
6. Run `create-adr` workflow
