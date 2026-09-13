package main

import (
	"fmt"
	"net/http"
	"log"
)

func main() {
	fmt.Println("starting http server")
	http.HandleFunc("/foo", foo)

	log.Fatal(http.ListenAndServe(":8080", nil))
}

func foo(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello world")
}
