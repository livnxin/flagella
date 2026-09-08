from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from keras import Sequential, layers
from .hyperparameters import epochs, optimizer, loss


def main() -> None:
    print("Initializing model training")
    train()
    print("Training is over")

def train() :
    housing = fetch_california_housing()
    Xtrain, Xtest, ytrain, ytest = train_test_split(housing.data, housing.target, test_size=0.1)
    Xtrain, Xval, ytrain, yval = train_test_split(Xtrain, ytrain, test_size=.2)
    transformer = preprocessing.QuantileTransformer(random_state=0)
    Xtrain = transformer.fit_transform(Xtrain)
    Xtest = transformer.transform(Xtest)
    Xval = transformer.transform(Xval)
    model = Sequential([
        layers.Dense(30, activation = 'relu', input_shape= Xtrain.shape[1:]),
        layers.Dense(20, activation = 'relu'),
        layers.Dense(1)
    ])
    model.compile(loss=loss, optimizer=optimizer)
    model.fit(Xtrain, ytrain, validation_data=(Xval, yval), epochs=epochs)
    mse_test = model.evaluate(Xtest, ytest)
    print("The mean square error is ", mse_test)