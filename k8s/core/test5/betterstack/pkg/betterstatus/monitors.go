package betterstatus

import (
	"fmt"
	"net/http"

	"github.com/gnolang/gno-infrastructure/betterstatus/pkg/cmd"
)

// create monitor group apis
func createMonitorsAndStatusPageEntries(
	apiCaller BetterStackApiCaller,
	cfg *cmd.ApiCallerCfg,
	monitorGroupId string,
	pageSectiondId string) error {
	// Collect services
	gnoServices, err := CollectGnoServices(cfg.MonitorFqdn, cfg.AdditionalPath)
	if err != nil {
		return err
	}

	var createMonitorResp CreateMonitorResponse
	for _, gnoService := range gnoServices {
		createMonitorResp = CreateMonitorResponse{}
		// Add group
		gnoService.MonitorGroupID = monitorGroupId
		// Create Monitor
		err := apiCaller.DoRequest(
			BetterStackApiSet[CreateMonitor],
			*gnoService.ApplyPrefix(cfg.MonitorPrefixName),
			createMonitorResp,
		)

		if err != nil { // silently catch error
			fmt.Println("%w", err)
			continue
		}
		err = apiCaller.DoRequest(
			BetterStackApiSet[CreateStatusPageResource],
			CreateStatusPageResourcePayload{
				PublicName:        gnoService.Name,
				ResourceID:        createMonitorResp.Data.ID,
				StatusPageSection: pageSectiondId,
			},
			// useless response
			CreateStatusPageSectionResponse{},
		)

		if err != nil { // silently catch error
			fmt.Println("%w", err)
			continue
		}
	}
	return nil
}

// Handles Monitor creations api calls
func HandleBetterStackApis(cfg *cmd.ApiCallerCfg) error {
	apiCaller := BetterStackApiCaller{
		BaseUrl:   BetterStackApiBaseEndpoint,
		AuthToken: cfg.AuthToken,
		Client:    &http.Client{},
	}

	// Create Monitor Group
	var monitorGroupObj CreateMonitorGroupResponse = CreateMonitorGroupResponse{}
	err := apiCaller.DoRequest(
		BetterStackApiSet[CreateMonitorGroup],
		CreateMonitorGroupPayload{
			Name: cfg.MonitorGroupName,
		},
		&monitorGroupObj,
	)

	if err != nil {
		return err
	}

	// Create Section
	var pageSectiondObj CreateStatusPageSectionResponse = CreateStatusPageSectionResponse{}
	err = apiCaller.DoRequest(
		BetterStackApiSet[CreateStatusPageSection],
		CreateStatusPageSectionPayload{
			Name:     cfg.MonitorFqdn,
			Position: 1,
		},
		&pageSectiondObj,
	)

	if err != nil {
		return err
	}

	return createMonitorsAndStatusPageEntries(
		apiCaller,
		cfg,
		monitorGroupObj.Data.ID,
		pageSectiondObj.ID,
	)
}
