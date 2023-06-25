import os

from opentelemetry import trace
from opentelemetry.sdk import trace as sdktrace
from opentelemetry.sdk.trace import export

from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource

resource = Resource(attributes={SERVICE_NAME: "cloud_function_bigquery"})

disable_logging = os.getenv("DISABLE_LOGGING")
console_logging = os.getenv("CONSOLE_LOGGING", "FALSE")
collector_logging = os.getenv("COLLECTOR_LOGGING", "TRUE")
collector_endpoint = os.getenv("COLLECTOR_ENDPOINT", "http://localhost:4317")

provider = sdktrace.TracerProvider(resource=resource)

print(f"console_logging = {console_logging}")

print(f"collector_logging = {collector_logging}")

if disable_logging is None:
    if console_logging.upper() == "TRUE":
        print("Console Logging Enabled")
        _processor2 = export.BatchSpanProcessor(
            # Set indent to none to avoid multi-line logs
            export.ConsoleSpanExporter(
                formatter=lambda s: s.to_json(indent=None) + "\n"
            )
        )
        provider.add_span_processor(_processor2)

    if collector_logging.upper() == "TRUE":
        print("Collector Logging Enabled")
        _processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=collector_endpoint))
        provider.add_span_processor(_processor)

    trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)
