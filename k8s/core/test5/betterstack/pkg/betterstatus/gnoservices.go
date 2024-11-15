package betterstatus

import (
	"encoding/json"
	"fmt"
	"strings"
	"text/template"
)

type GnoServiceDomain struct {
	FQDN string
}

type GnoMonitorPayload CreateMonitorPayload

func (cmp GnoMonitorPayload) MarshalJSON() ([]byte, error) {
	return json.Marshal(CreateMonitorPayload(cmp))
}

func (gp *GnoMonitorPayload) ApplyPrefix(prefix string) *GnoMonitorPayload {
	gp.Name = fmt.Sprintf("%s %s", prefix, gp.Name)
	return gp
}

func (gp *GnoMonitorPayload) GetUrlFromTemplate(domain GnoServiceDomain) error {
	t, err := template.New("Monitor Name").Parse(gp.URL)
	if err != nil {
		return fmt.Errorf("Error parsing template: %w", err)
	}
	// Use strings.Builder to capture the output of the template
	var builder strings.Builder
	err = t.Execute(&builder, domain)
	if err != nil {
		return fmt.Errorf("Error executing template: %w", err)
	}

	// The output of the template is now in builder
	gp.URL = builder.String()
	return nil
}

var Gnoservices []GnoMonitorPayload = []GnoMonitorPayload{
	{
		Name: "Gnoweb",
		URL:  "https://{{.FQDN}}/status.json",
	},
	{
		Name: "Faucet",
		URL:  "https://faucet-api.{{.FQDN}}/health",
	},
	{
		Name: "Indexer",
		URL:  "https://faucet-api.{{.FQDN}}/health",
	},
	{
		Name: "RPC Node HTTP",
		URL:  "https://rpc.{{.FQDN}}/",
	},
}
