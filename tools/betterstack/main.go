package main

import (
	"context"
	"flag"
	"fmt"
	"os"

	"github.com/gnolang/gno-infrastructure/betterstatus/pkg/betterstatus"
	"github.com/gnolang/gno-infrastructure/betterstatus/pkg/cmd"
)

const Test5_GroupName = "test5"
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

	err := betterstatus.HandleBetterStackApis(cfg)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	readCmline(os.Args[1:])
}
