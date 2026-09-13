package main

import (
	"crypto/rsa"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/golang-jwt/jwt/v5/request"
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

	mux := http.NewServeMux()
	fmt.Println("starting http server")
	mux.HandleFunc("/login", handleLogin)

	log.Fatal(http.ListenAndServe(":8080", mux))
}

func handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = fmt.Fprintln(w, "No POST", r.Method)
		return
	}
	var u User
	err := json.NewDecoder(r.Body).Decode(&u)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	if u.Username != "test" || u.Password != "foobar" {
		w.WriteHeader(http.StatusForbidden)
		fmt.Fprintln(w, "Wrong info")
		log.Printf("Unauthorized login attempt")
		return
	}
	tokenstring, err := createToken(u.Username)

	w.Header().Set("Content-Type", "application/jwt")
	w.WriteHeader(http.StatusOK)
	_, _ = fmt.Fprintln(w, tokenstring)
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

func createToken(user string) (string, error) {

	t := jwt.New(jwt.GetSigningMethod("RS256"))

	t.Claims = &MyCustomClaims{
		user,
		jwt.RegisteredClaims{

			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Minute * 30)),
		},
	}
	return t.SignedString(signKey)
}
