package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	"github.com/comunifi/resilient-fi/relay/internal/config"
	"github.com/fiatjaf/eventstore/postgresql"
)

func main() {
	log.Default().Println("starting relay...")

	////////////////////
	// flags
	// port := flag.Int("port", 3334, "port to listen on")

	env := flag.String("env", ".env", "path to .env file")

	flag.Parse()
	////////////////////

	ctx := context.Background()

	////////////////////

	////////////////////
	// config
	conf, err := config.New(ctx, *env)
	if err != nil {
		log.Fatal(err)
	}
	////////////////////

	////////////////////
	// nostr-postgres
	log.Default().Println("starting internal db service...")

	ndb := postgresql.PostgresBackend{
		DatabaseURL: fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", conf.DBUser, conf.DBPassword, conf.DBHost, conf.DBPort, conf.DBName),
	}

	err = ndb.Init()
	if err != nil {
		log.Fatal(err)
	}
	defer ndb.Close()
	////////////////////
}
