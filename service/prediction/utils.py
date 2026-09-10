import numpy as np
import tensorflow as tf

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


def to_tensor(payload) -> tf.Tensor:
    d = payload.model_dump()
    x = np.array([[d[k] for k in FEATURE_ORDER]], dtype=np.float64)
    return tf.constant(x, dtype=tf.float64)


def predict(model, payload):
    x = to_tensor(payload)
    y = model.predict(x)
    return float(y[0][0])
