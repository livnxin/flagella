from fastapi import FastAPI
from pydantic import BaseModel
from keras.saving import load_model
from utils import predict
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import make_asgi_app
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    ConsoleSpanExporter,
)
from opentelemetry.semconv.trace import SpanAttributes

print("Initializing prediction service")
print("Loading model")
model = load_model("./artifact/model.keras")
print("Model loaded")

app = FastAPI()
Instrumentator().instrument(app).expose(app)

metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

provider = TracerProvider()
processor = BatchSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(processor)

# Sets the global default tracer provider
trace.set_tracer_provider(provider)

# Creates a tracer from the global tracer provider
tracer = trace.get_tracer("my.tracer.name")


class Input(BaseModel):
    MedInc: float
    HouseAge: float
    AveRooms: float
    AveBedrms: float
    Population: float
    AveOccup: float
    Latitude: float
    Longitude: float


@app.get("/")
@tracer.start_as_current_span("hello_world")
def read_root():
    return {"Hello": "World"}


@app.post("/prediction")
@tracer.start_as_current_span("prediction_service")
def read_item(input: Input):
    current_span = trace.get_current_span()
    current_span.set_attribute(SpanAttributes.HTTP_METHOD, "POST")
    output = predict(model, input)
    return {"price": output}
