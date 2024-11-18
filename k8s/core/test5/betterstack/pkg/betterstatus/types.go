package betterstatus

import "encoding/json"

const JSON_CONTENT_TYPE = "application/json"
const BetterStackApiBaseEndpoint = "https://uptime.betterstack.com/api/v2"

type BetterStackApiEndpoint struct {
	Endpoint      string
	Method        string
	EndpointParam string
}

// APIs

type BetterStackApi string

const CreateMonitor BetterStackApi = "createMonitor"
const CreateMonitorGroup BetterStackApi = "createMonitorGroup"
const CreateStatusPageSection BetterStackApi = "createStatusPageSection"
const CreateStatusPageResource BetterStackApi = "createStatusPageResource"

var BetterStackApiSet map[BetterStackApi]BetterStackApiEndpoint = map[BetterStackApi]BetterStackApiEndpoint{
	CreateMonitor: {
		Endpoint: "/monitors",
		Method:   "POST",
	},
	CreateMonitorGroup: {
		Endpoint: "/monitor-groups",
		Method:   "POST",
	},
	// section in status page
	CreateStatusPageSection: {
		Endpoint: "/status-pages/{.EndpointParam}}/sections",
		Method:   "POST",
	},
	// single resource in status page
	CreateStatusPageResource: {
		Endpoint: "/status-pages/{.EndpointParam}/resources",
		Method:   "POST",
	},
}

// Request Payloads

type CreateMonitorPayloadList struct {
	Monitors []CreateMonitorPayload `json:"monitors"`
}

type CreateMonitorPayload struct {
	Name               string `json:"pronounceable_name"`
	URL                string `json:"url"`
	MonitorType        string `json:"monitor_type" default:"status"`
	MonitorGroupID     string `json:"monitor_group_id,omitempty"`
	Email              bool   `json:"email" default:"true"`
	CheckFrequency     int    `json:"check_frequency" default:"180"`
	RecoveryPeriod     int    `json:"recovery_period" default:"60"`
	ConfirmationPeriod int    `json:"confirmation_period" default:"0"`
	Port               string `json:"port,omitempty"`
	Paused             bool   `json:"paused" default:"true"`
}

func (cmp CreateMonitorPayload) MarshalJSON() ([]byte, error) {
	// Define an alias type to avoid calling MarshalJSON recursively on Config
	type Alias CreateMonitorPayload

	// Set default values if fields are empty
	if cmp.MonitorType == "" {
		cmp.MonitorType = "status"
	}
	if cmp.CheckFrequency == 0 {
		cmp.CheckFrequency = 180
	}
	if cmp.RecoveryPeriod == 0 {
		cmp.RecoveryPeriod = 60
	}
	cmp.Email = true
	cmp.Paused = true

	// Marshal using the alias type to avoid recursion
	return json.Marshal((Alias)(cmp))
}

type CreateMonitorGroupPayload struct {
	Name      string `json:"name"`
	SortIndex int    `json:"sort_index" default:"1"`
	Paused    bool   `json:"paused" default:"true"`
}

func (cmgp CreateMonitorGroupPayload) MarshalJSON() ([]byte, error) {
	type AliasGroup CreateMonitorGroupPayload

	if cmgp.SortIndex == 0 {
		cmgp.SortIndex = 1
	}
	cmgp.Paused = true

	// Marshal using the alias type to avoid recursion
	return json.Marshal((AliasGroup)(cmgp))
}

type CreateStatusPageSectionPayload struct {
	Name     string `json:"name"`
	Position int    `json:"position"`
}

type CreateStatusPageResourcePayload struct {
	StatusPageSection string `json:"status_page_section_id"`
	PublicName        string `json:"public_name"`
	Explanation       string `json:"explanation"`
	ResourceID        string `json:"resource_id"`
	ResourceType      string `json:"resource_type" default:"monitor"`
	WidgetType        string `json:"widget_type" default:"history"`
}

func (csp CreateStatusPageResourcePayload) MarshalJSON() ([]byte, error) {
	type AliasStatusPage CreateStatusPageResourcePayload

	if csp.ResourceType == "" {
		csp.ResourceType = "monitor"
	}
	if csp.WidgetType == "" {
		csp.WidgetType = "history"
	}
	return json.Marshal((AliasStatusPage)(csp))
}

// Response Payload

type CreateMonitorGroupResponse struct {
	Data CreateMonitorGroupRespData `json:"data"`
}

type CreateMonitorGroupRespData struct {
	ID string `json:"id"`
}

// Create single monitor response as the same structure of group api
type CreateMonitorResponse CreateMonitorGroupResponse

type CreateStatusPageSectionResponse struct {
	ID string `json:"id"`
}
