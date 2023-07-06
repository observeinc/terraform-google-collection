export OTEL_SERVICE_NAME=auto-instrument;
export OTEL_TRACES_EXPORTER=otlp_proto_http;
export OTEL_METRICS_EXPORTER=console;
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=146.148.79.73:4317;
export MYSQL_HOST=34.71.192.247;
export MYSQL_DBNAME=cloud_freak;
export MYSQL_USER=redfish;
export MYSQL_PASSWORD=G0ZKH8qI;
opentelemetry-instrument python3 main.py '{"method": "write"}'