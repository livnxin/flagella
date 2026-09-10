from fastapi import FastAPI
from pydantic import BaseModel

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


@app.post("prediction")
def read_item(input: Input):
    output = predict(input)
    return {"price": output}
