from fastapi import FastAPI
from pydantic import BaseModel
from keras.saving import load_model
from service.prediction.app.utils import predict
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import make_asgi_app
from service.prediction.app.tracing import tracer

print("Initializing prediction service")
print("Loading model")
model = load_model("./modelkit/data/model.keras")
print("Model loaded")

app = FastAPI()
Instrumentator().instrument(app).expose(app)

metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)


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
