package main

import (
	"crypto/rsa"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/golang-jwt/jwt/v5"
	"github.com/golang-jwt/jwt/v5/request"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type MyCustomClaims struct {
	username string
	jwt.RegisteredClaims
}

var (
	verifyKey *rsa.PublicKey
	signKey   *rsa.PrivateKey
)

func main() {
	fmt.Println("Reading signing key")

	signBytes, err := os.ReadFile("private.pem")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Signing key has been read")

	signKey, err = jwt.ParseRSAPrivateKeyFromPEM(signBytes)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Reading verifier key")

	verifyBytes, err := os.ReadFile("./public.pem")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Signing key has been read")

	verifyKey, err = jwt.ParseRSAPublicKeyFromPEM(verifyBytes)
	if err != nil {
		log.Fatal(err)
	}

	initProm()

	mux := http.NewServeMux()
	fmt.Println("starting http server")
	mux.Handle("/login", handlewithMetrics(http.HandlerFunc(handleLogin), "login"))
	mux.Handle("/metrics", promhttp.Handler())

	log.Fatal(http.ListenAndServe(":8080", mux))
}

func handleVerifyJWT(w http.ResponseWriter, r *http.Request) {
	token, err := request.ParseFromRequest(r, request.OAuth2Extractor, func(token *jwt.Token) (any, error) {

		return verifyKey, nil
	}, request.WithClaims(&MyCustomClaims{}))

	if err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		_, _ = fmt.Fprintln(w, "Invalid token:", err)
		return
	}

	_, _ = fmt.Fprintln(w, "Welcome,", token.Claims.(*MyCustomClaims).username)

}
