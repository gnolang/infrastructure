package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gnolang/gno-infrastructure/betterstatus/pkg/betterstatus"
)

const Test5_GroupName = "test5"
const Test5_MonitorPrefixName = "Test 5"
const Test5_MonitorFqdn = "test5.gno.land"

func main() {
	// Check if an argument is provided
	if len(os.Args) < 2 {
		fmt.Println("Error: Missing required argument: BetterStack Auth Token.")
		fmt.Println("Usage: go run main.go <BetterStack Auth Token>")
		os.Exit(1)
	}

	var groupName string = Test5_GroupName
	if len(os.Args) == 3 {
		groupName = os.Args[2]
	}
	authToken := os.Args[1]
	apiCaller := betterstatus.BetterStackApiCaller{
		BaseUrl:   betterstatus.BetterStackApiBaseEndpoint,
		AuthToken: authToken,
		Client:    &http.Client{},
	}

	// Create Monitor Group
	_, err := apiCaller.DoRequest(
		betterstatus.BetterStackApiSet[betterstatus.CreateMonitorGroup],
		betterstatus.CreateMonitorGroupPayload{
			Name: groupName,
		})

	if err != nil {
		log.Fatal(err)
	}

	// Unmarshal Monitor Group Resp
	// var monitorGroupRespDecoder betterstatus.CreateMonitorGroupResponse = betterstatus.CreateMonitorGroupResponse{}
	// decoder := json.NewDecoder(bytes.NewReader(monitorGroupApiResp))
	// decoder.DisallowUnknownFields()
	// if err := decoder.Decode(&monitorGroupRespDecoder); err != nil {
	// 	log.Fatal("Unable to parse body: %w", err)
	// }

	// Create Monitors
	gnoServices := betterstatus.Gnoservices
	// Fulfill Templates
	for _, gnoService := range gnoServices {
		err := gnoService.GetUrlFromTemplate(
			betterstatus.GnoServiceDomain{
				FQDN: Test5_MonitorFqdn,
			})
		if err != nil {
			log.Fatal(err)
		}
	}
	if len(os.Args) == 4 {
		jsonPath := os.Args[3]
		additionalMonitors, err := betterstatus.UmarshallMonitorsFromFile(jsonPath)
		if err != nil {
			log.Fatal(err)
		}

		for _, addMonitor := range additionalMonitors {
			gnoServices = append(gnoServices, betterstatus.GnoMonitorPayload(addMonitor))
		}
	}

	for _, gnoService := range gnoServices {
		// Create Monitor
		_, err := apiCaller.DoRequest(
			betterstatus.BetterStackApiSet[betterstatus.CreateMonitor],
			*gnoService.ApplyPrefix(Test5_MonitorPrefixName))

		if err != nil {
			fmt.Println("%w", err)
		}
	}
}
