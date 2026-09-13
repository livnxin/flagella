package main

import (
	"fmt"
)

func main() {
	fmt.Println("Hello World")
}

func makeJWTClaim() {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
}