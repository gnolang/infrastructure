package betterstatus

import (
	"encoding/json"
	"os"
)

func UmarshallMonitorsFromFile(jsonPath string) ([]CreateMonitorPayload, error) {
	// Open the JSON jsonData
	jsonData, err := os.Open(jsonPath)
	if err != nil {
		return nil, err
	}
	defer jsonData.Close()

	// Decode the JSON data into the struct
	var data CreateMonitorPayloadList
	decoder := json.NewDecoder(jsonData)
	err = decoder.Decode(&data)
	if err != nil {
		return nil, err
	}
	return data.Monitors, nil
}
