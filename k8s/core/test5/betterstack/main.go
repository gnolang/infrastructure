package main

import (
	"bytes"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"net/http"
	"os"

	"github.com/gnolang/gno-infrastructure/betterstatus/pkg/betterstatus"
	"github.com/gnolang/gno-infrastructure/betterstatus/pkg/cmd"
)

const Test5_GroupName = "test5bb"
const Test5_MonitorPrefixName = "Test 5"
const Test5_MonitorFqdn = "test5.gno.land"
const Test5_AdditionalPath = "extra-services.json"

// Reads cmd line args
func readCmline(args []string) {
	apiCallerCfg := &cmd.ApiCallerCfg{
		MonitorGroupName:  Test5_GroupName,
		MonitorPrefixName: Test5_MonitorPrefixName,
		MonitorFqdn:       Test5_MonitorFqdn,
	}

	apiCmd := cmd.NewApiCallerCmd(
		apiCallerCfg,
		func(ctx context.Context, _ []string) error {
			return execApiCallCms(ctx, apiCallerCfg)
		},
	)
	apiCmd.Execute(context.Background(), args)
}

// Executes main logic
func execApiCallCms(_ context.Context, cfg *cmd.ApiCallerCfg) error {
	if cfg.AuthToken == "" {
		fmt.Println("Error: Missing required argument: BetterStack Auth Token.")
		return flag.ErrHelp
	}

	if cfg.AdditionalPath == "" {
		cfg.AdditionalPath = Test5_AdditionalPath
	}

	err := handleMonitorsApis(cfg)
	if err != nil {
		return err
	}

	return nil
}

// Handles Monitor creations api calls
func handleMonitorsApis(cfg *cmd.ApiCallerCfg) error {
	apiCaller := betterstatus.BetterStackApiCaller{
		BaseUrl:   betterstatus.BetterStackApiBaseEndpoint,
		AuthToken: cfg.AuthToken,
		Client:    &http.Client{},
	}

	// Create Monitor Group
	monitorGroupApiResp, err := apiCaller.DoRequest(
		betterstatus.BetterStackApiSet[betterstatus.CreateMonitorGroup],
		betterstatus.CreateMonitorGroupPayload{
			Name: cfg.MonitorGroupName,
		})

	if err != nil {
		return err
	}

	// Unmarshal Monitor Group Resp
	var monitorGroupObj betterstatus.CreateMonitorGroupResponse = betterstatus.CreateMonitorGroupResponse{}
	decoder := json.NewDecoder(bytes.NewReader(monitorGroupApiResp))
	if err := decoder.Decode(&monitorGroupObj); err != nil {
		return fmt.Errorf("Unable to parse body: %w", err)
	}

	// Collect services
	gnoServices, err := betterstatus.CollectGnoServices(cfg.MonitorFqdn, cfg.AdditionalPath)

	// Create Monitors
	for _, gnoService := range gnoServices {
		// Add group
		gnoService.MonitorGroupID = monitorGroupObj.Data.ID
		// Create Monitor
		_, err := apiCaller.DoRequest(
			betterstatus.BetterStackApiSet[betterstatus.CreateMonitor],
			*gnoService.ApplyPrefix(cfg.MonitorPrefixName))

		if err != nil { // silently catch error
			fmt.Println("%w", err)
		}
	}
	return nil
}

func main() {
	readCmline(os.Args[1:])
}
