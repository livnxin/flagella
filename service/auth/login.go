package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

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
