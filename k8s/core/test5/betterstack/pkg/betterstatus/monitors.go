package betterstatus

import (
	"fmt"
	"net/http"

	"github.com/gnolang/gno-infrastructure/betterstatus/pkg/cmd"
)

// Collect gno services info
func collectGnoServices(fqdn string, additionalPath string) ([]GnoMonitorPayload, error) {
	gnoServices := gnoServices_
	// Fulfill Templates
	for index := range gnoServices {
		err := gnoServices[index].GetUrlFromTemplate(
			GnoServiceDomain{
				FQDN: fqdn,
			})
		if err != nil {
			return nil, err
		}
	}

	// Read additional services
	if additionalPath != "" {
		additionalServices, err := UmarshallServicesFromFile(additionalPath)
		if err != nil {
			return nil, err
		}

		for _, extraService := range additionalServices {
			gnoServices = append(gnoServices, GnoMonitorPayload(extraService))
		}
	}
	return gnoServices, nil
}

// create monitor group apis
func createMonitorsAndStatusPageEntries(
	apiCaller BetterStackApiCaller,
	cfg *cmd.ApiCallerCfg,
	monitorGroupId string,
	pageSectiondId string) error {
	// Collect services
	gnoServices, err := collectGnoServices(cfg.MonitorFqdn, cfg.AdditionalPath)
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
			&createMonitorResp,
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
			&CreateStatusPageSectionResponse{},
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
	var pageSectionObj CreateStatusPageSectionResponse = CreateStatusPageSectionResponse{}
	err = apiCaller.DoRequest(
		BetterStackApiSet[CreateStatusPageSection],
		CreateStatusPageSectionPayload{
			Name:     cfg.MonitorFqdn,
			Position: 2,
		},
		&pageSectionObj,
	)

	if err != nil {
		return err
	}

	return createMonitorsAndStatusPageEntries(
		apiCaller,
		cfg,
		monitorGroupObj.Data.ID,
		pageSectionObj.Data.ID,
	)
}
