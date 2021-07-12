# Apply Ops Dashboard

Dashboard that shows the current deployment state of the [Apply for teacher training](https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training) service.

Publicly accessible at <https://apply-ops-dashboard.azurewebsites.net>

## Local development

Local development needs 3 environment variables defined in [.env.example](./.env.example)
- `GITHUB_TOKEN` is required for api calls to avoid being rate limited by GitHub
- `GITHUB_CLIENT_ID` & `GITHUB_CLIENT_SECRET` is required only for authenticating with GitHub SSO for triggering a deployment

Once the environment variables are set,
Run the app with either of these commands:

```bash
foreman start
# or
bundle exec rackup -p 5000
```

The app will be available on `http://localhost:5000`

## Deployment rota

If you populate the env var `DEPLOYERS` with a JSON array `[{"displayName":, "slackUserId":}]`,
one will be chosen each day to be the nominated deployer and displayed on the
dashboard, along with a couple of reserve deployers in case they're unavailable.

## Tests

You can run the tests, such as they are, with:

```bash
bundle exec rspec
```

You can run Rubocop with:

```bash
bundle exec rubocop
```

## Deployment

Auto-deploy is set up from master using Azure DevOps pipelines.
