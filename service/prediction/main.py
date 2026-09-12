from fastapi import FastAPI
from pydantic import BaseModel
from keras.saving import load_model
from utils import predict
from prometheus_fastapi_instrumentator import Instrumentator

print("Initializing prediction service")
print("Loading model")
model = load_model("./artifact/model.keras")
print("Model loaded")
app = FastAPI()


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
def read_root():
    return {"Hello": "World"}


@app.post("/prediction")
def read_item(input: Input):
    output = predict(model, input)
    return {"price": output}
