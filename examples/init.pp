# Smoke test.

device_manager {'bigip.example.com':
  type         => 'f5',
  url          => 'https://admin:password@10.0.0.245/',
  run_interval => 30,
}
