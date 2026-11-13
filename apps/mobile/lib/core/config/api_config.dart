/// Default base URL for the PECOX Vision FastAPI backend (`/api/v1`).
///
/// Override at build/run time via `--dart-define=PECOX_API_URL=http://<host>:8000/api/v1`.
/// Android emulator loops host loopback through `10.0.2.2`.
const String kDefaultApiBaseUrl = String.fromEnvironment(
  'PECOX_API_URL',
  defaultValue: 'http://10.0.2.2:8000/api/v1',
);
