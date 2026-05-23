package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

func parseFloat(value string) float64 {
	parsed, err := strconv.ParseFloat(value, 64)
	if err != nil {
		log.Fatalf("could not parse float %q: %v", value, err)
	}
	return parsed
}

func main() {
	file, err := os.Open("data/virtue_strengths_crosssectional.csv")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}

	justiceIndex := 3
	meaningIndex := 6
	var justiceTotal, meaningTotal float64

	for _, row := range records[1:] {
		justiceTotal += parseFloat(row[justiceIndex])
		meaningTotal += parseFloat(row[meaningIndex])
	}

	n := float64(len(records) - 1)
	fmt.Printf("Mean justice score: %.3f\n", justiceTotal/n)
	fmt.Printf("Mean meaning score: %.3f\n", meaningTotal/n)
}
