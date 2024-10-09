# CarePay Actions

This repository contains the actions for the CarePay GitHub repositories.

## `central-config-updater`

```yml
env:
  AWS_REGION: eu-west-1
  AWS_DEFAULT_REGION: eu-west-1
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  BITBUCKET_APP_PASSWORD: ${{ secrets.BITBUCKET_APP_PASSWORD }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          repository: team-carepay/carepay-actions
          ref: main
          token: ${{ secrets.CI_BOT_PAT }}
          path: .carepay-actions
      - name: Deploy
        uses: ./.carepay-actions/.github/actions/deploy
        with:
          APP: health-hub-web
          APP_PATH: frontend/health-hub-web
          COUNTRY: ae
          STAGE: test
          TAG: ${{ startsWith(github.ref,'refs/tags') && github.ref_name || github.sha }}
```
