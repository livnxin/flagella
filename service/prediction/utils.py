import numpy as np
import tensorflow as tf

from tracing import tracer

FEATURE_ORDER = [
    "MedInc",
    "HouseAge",
    "AveRooms",
    "AveBedrms",
    "Population",
    "AveOccup",
    "Latitude",
    "Longitude",
]


@tracer.start_as_current_span("prediction_service")
def to_tensor(payload) -> tf.Tensor:
    d = payload.model_dump()
    x = np.array([[d[k] for k in FEATURE_ORDER]], dtype=np.float64)
    return tf.constant(x, dtype=tf.float64)


def predict(model, payload):
    x = to_tensor(payload)
    y = model.predict(x)
    return float(y[0][0])
