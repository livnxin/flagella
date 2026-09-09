from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from keras import Sequential, layers
import mlflow
from .hyperparameters import epochs, optimizer, loss


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
    eval_data = Xtest.copy()
    eval_target = ytest
    model = Sequential(
        [
            layers.Dense(30, activation="relu", input_shape=Xtrain.shape[1:]),
            layers.Dense(20, activation="relu"),
            layers.Dense(1),
        ]
    )
    model.compile(loss=loss, optimizer=optimizer)
    model.fit(Xtrain, ytrain, validation_data=(Xval, yval), epochs=epochs)

    with mlflow.start_run():
        signature = mlflow.models.infer_signature(Xtrain, model.predict(Xtrain))
        model_info = mlflow.tensorflow.log_model(model, name="model", signature=signature)

        result = mlflow.models.evaluate(
            model_info.model_uri,
            eval_data,
            targets=eval_target,
            model_type="regressor",
        )

        print(f"MAE: {result.metrics['mean_absolute_error']:.3f}")
        print(f"RMSE: {result.metrics['root_mean_squared_error']:.3f}")
        print(f"R² Score: {result.metrics['r2_score']:.3f}")

    mse_test = model.evaluate(Xtest, ytest)
    print("The mean square error is ", mse_test)
