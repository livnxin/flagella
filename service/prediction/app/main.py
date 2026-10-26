from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from keras.saving import load_model
from utils import predict
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import make_asgi_app
from tracing import tracer
from opentelemetry import trace
from opentelemetry.semconv.trace import SpanAttributes
from typing import Annotated

print("Initializing prediction service")
print("Loading model")
model = load_model("./modelkit/data/model.keras")
print("Model loaded")

app = FastAPI(
    openapi_url = "/prediction/openapi.json"
)
templates = Jinja2Templates(directory="templates")
app.mount("/static", StaticFiles(directory="static"), name="static")
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
@tracer.start_as_current_span("index")
async def index(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="predict.html",
        context={"prediction": None},
    )


@app.post("/prediction")
@tracer.start_as_current_span("prediction_service")
def read_item(input: Annotated[Input, Form()]):
    current_span = trace.get_current_span()
    current_span.set_attribute(SpanAttributes.HTTP_METHOD, "POST")
    output = predict(model, input)
    return {"price": output}
