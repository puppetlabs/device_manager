# Smoke test.

puppet_device {'bigip.example.com':
  type => 'f5',
  url  => 'https://admin:fffff55555@10.0.0.245/',
}
