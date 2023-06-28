import os

from opentelemetry import trace
from opentelemetry.sdk import trace as sdktrace
from opentelemetry.sdk.trace import export

from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.instrumentation.redis import RedisInstrumentor

resource = Resource(attributes={SERVICE_NAME: "write_terraform"})

disable_logging = os.getenv("DISABLE_LOGGING")
console_logging = os.getenv("CONSOLE_LOGGING", False)
collector_logging = os.getenv("COLLECTOR_LOGGING", True)

provider = sdktrace.TracerProvider(resource=resource)

if disable_logging is None:
    if console_logging == True:
        print("Console Logging Enabled")
        _processor2 = export.BatchSpanProcessor(
            # Set indent to none to avoid multi-line logs
            export.ConsoleSpanExporter(
                formatter=lambda s: s.to_json(indent=None) + "\n"
            )
        )
        provider.add_span_processor(_processor2)

    if collector_logging == True:
        print("Collector Logging Enabled")
        _processor = BatchSpanProcessor(
            OTLPSpanExporter(endpoint="http://146.148.79.73:4317")
        )
        provider.add_span_processor(_processor)
        trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

RedisInstrumentor().instrument(tracer=tracer)
