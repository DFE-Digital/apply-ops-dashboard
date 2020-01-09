# Apply Ops Dashboard

Dashboard that shows the current deployment state of the [Apply for teacher training](https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training) service.

Publicly accessible at <https://apply-ops-dashboard.herokuapp.com>

## Local development

Local development needs 3 environment variables:

- `AZURE_ACCESS_TOKEN`: an [Azure Personal Access Token](https://dfe-ssp.visualstudio.com/_usersSettings/tokens). It only needs the "Read" permissions for "Build".
- `AZURE_USERNAME`: the email adress associated with the token (your DfE email address most likely)
- `GITHUB_TOKEN`: a [GitHub access token](https://github.com/settings/tokens/new) to avoid being rate limited. Does not need any permissions.

Run the app:

```
foreman start
```

The app will appear on <http://localhost:5000>.

## Deployment rota

If you populate the env var `DEPLOYERS` with a comma-separated list of names,
one will be chosen each day to be the nominated deployer and displayed on the
dashboard, along with a couple of reserve deployers in case they're ill or
away.

## Tests

You can run the tests, such as they are, with:

```
bundle exec rspec
```

## Deployment

Auto-deploy to Heroku is set up from master.
