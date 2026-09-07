from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from sklearn.linear_model import LinearRegression
from sklearn.pipeline import Pipeline


def main() -> None:
    print("Initializing model training")
    train()
    print("Training is over")

def train() :
    housing = fetch_california_housing()
    X_train, X_test, y_train, y_test = train_test_split(housing.data, housing.target)
    quantile_transformer = preprocessing.QuantileTransformer(random_state=0)
    pipe = Pipeline(steps=[
        ('transform', preprocessing.QuantileTransformer(random_state=0)),
        ('regression', LinearRegression())])
    pipe.fit(X_train, y_train)
    score = pipe.score(X_test, y_test)
    print("THe score is ", score)
