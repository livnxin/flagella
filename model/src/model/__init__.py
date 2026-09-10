from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from keras import Sequential, layers
import mlflow
from .hyperparameters import epochs, optimizer, loss
import pandas as pd
from kitops.modelkit.manager import ModelKitManager
from kitops.modelkit.user import UserCredentials
from kitops.cli import kit
from .variables import *


def main() -> None:
    print("Initializing model training")
    train()
    print("Training is over")


def prepare():
    housing = fetch_california_housing()
    Xtrain, Xtest, ytrain, ytest = train_test_split(
        housing.data, housing.target, test_size=0.1
    )
    Xtrain, Xval, ytrain, yval = train_test_split(Xtrain, ytrain, test_size=0.2)
    transformer = preprocessing.QuantileTransformer(random_state=0)
    Xtrain = transformer.fit_transform(Xtrain)
    Xtest = transformer.transform(Xtest)
    Xval = transformer.transform(Xval)
    return (Xtrain, Xtest, Xval, ytrain, ytest, yval)


def train():
    Xtrain, Xtest, Xval, ytrain, ytest, yval = prepare()
    mlflow.tensorflow.autolog(log_every_epoch=False)
    model = Sequential(
        [
            layers.Dense(30, activation="relu", input_shape=Xtrain.shape[1:]),
            layers.Dense(20, activation="relu"),
            layers.Dense(1),
        ]
    )
    model.compile(loss=loss, optimizer=optimizer)
    model.fit(Xtrain, ytrain, validation_data=(Xval, yval), epochs=epochs)

    with mlflow.start_run() as cur_run:
        signature = mlflow.models.infer_signature(Xtrain, model.predict(Xtrain))
        model_info = mlflow.tensorflow.log_model(
            model, name="model", signature=signature
        )
        artifact_location = mlflow.artifacts.download_artifacts(
            artifact_uri=model_info.model_uri
        )
        pack(artifact_location)


def pack(artifact_location):
    creds = UserCredentials(registry="jozu.ml")
    manager = ModelKitManager(
        working_directory=artifact_location,
        user_credentials=creds,
        modelkit_tag=modelkit_tag,
    )
    manager.login()
    kit.init(
        directory=artifact_location,
        name="acephale",
        description=JOZU_DESCRIPTION,
        author=JOZU_AUTHOR,
    )
    manager.pack_and_push_modelkit(with_login_and_logout=True)
