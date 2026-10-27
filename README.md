# Ecosystem

[![Slovensko.Digital CI](https://github.com/slovensko-digital/www.ecosystem/workflows/Slovensko.Digital%20CI/badge.svg)](https://github.com/slovensko-digital/www.ecosystem/actions/workflows/slovensko_digital_ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/f8b7baa527f6f5647c8d/maintainability)](https://codeclimate.com/github/slovensko-digital/www.ecosystem)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f8b7baa527f6f5647c8d/test_coverage)](https://codeclimate.com/github/slovensko-digital/www.ecosystem)

Ecosystem is user facing web app for [ekosystem.slovensko.digital](https://ekosystem.slovensko.digital), contains mainly  documentation for datasets and APIs from various data sources. App for pushing data to ecosystem is [harvester](https://github.com/slovensko-digital/harvester.ecosystem).

## Registrations through CAP

The registration forms of Autoform and Datahub send the registration with the billing data to CAP
(the CRM of the ecosystem), which e-mails the client a link to confirm it at `/registracia/potvrdenie`.
Set `CAP_URL` (e.g. `https://cap.dev.slovensko.digital`) and `CAP_REGISTRATION_SECRET` (the
`REGISTRATION_SECRET` of CAP); without them the pages keep the Google Forms. The page of the
link only shows a button, the button confirms the registration (mail scanners open links too).

A staging of the web with CAP runs on the server of the CAP staging at
https://ekosystem.dev.slovensko.digital, deployed by Kamal (`config/deploy.cap.yml`, secrets in
`.kamal/secrets` from the git-ignored `.env.kamal`).

## Contributing

Feel free to contribute other datasets / scrapers or improvements. See [issues](https://github.com/slovensko-digital/www.ecosystem/issues) if you want to help, request a feature or file a bug. Join us on our [public slack channel](http://slack.slovensko.digital/) if you want to talk live.
