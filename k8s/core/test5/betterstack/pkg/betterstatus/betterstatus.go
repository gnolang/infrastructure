package betterstatus

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"text/template"
)

type BetterStackApiCaller struct {
	BaseUrl   string
	AuthToken string
	Client    *http.Client
}

func (bsapi *BetterStackApiCaller) marshalJson(payload interface{}) (jsonBody []byte, err error) {
	switch concretePayload := payload.(type) {
	case GnoMonitorPayload, CreateMonitorGroupPayload, CreateMonitorPayload, CreateStatusPageSectionPayload, CreateStatusPageResourcePayload:
		jsonBody, err = json.Marshal(concretePayload)
	default:
		jsonBody, err = json.Marshal(payload)
	}
	return
}

func (bsapi *BetterStackApiCaller) unmarshalJson(respBody []byte, respReceviver interface{}) error {
	switch respReceviver.(type) {
	case *CreateMonitorGroupResponse, *CreateMonitorResponse, *CreateStatusPageSectionResponse:
		decoder := json.NewDecoder(bytes.NewReader(respBody))
		if err := decoder.Decode(&respReceviver); err != nil {
			return fmt.Errorf("Unable to parse body: %w", err)
		}
		return nil
	default:
		return fmt.Errorf("Unsupported decoder")
	}
}

func (bsapi *BetterStackApiCaller) handleHttpResp(endpoint string, resp *http.Response, respReceviver interface{}) error {
	// Handle Http Resp
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("Error in HTTP call: %s", resp.Status)
	}
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	if len(respBody) == 0 {
		return fmt.Errorf("Empty body from request %s", endpoint)
	}
	return bsapi.unmarshalJson(respBody, respReceviver)
}

// Resolve API endpoint template
func (bsapi *BetterStackApiCaller) resolveEndpointTemplate(api BetterStackApiEndpoint) (string, error) {
	var builder strings.Builder
	t, err := template.New("Full Endpoint Name").Parse(api.Endpoint)
	if err != nil {
		return "", fmt.Errorf("Error parsing template: %w", err)
	}
	err = t.Execute(&builder, api)
	if err != nil {
		return "", fmt.Errorf("Error executing template: %w", err)
	}
	return builder.String(), nil
}

// General HTTP Client Handler
func (bsapi *BetterStackApiCaller) DoRequest(api BetterStackApiEndpoint, reqPayload interface{}, respReceiver interface{}) (err error) {
	var req *http.Request
	var endpointPart string = api.Endpoint
	if api.EndpointParam != "" {
		endpointPart, err = bsapi.resolveEndpointTemplate(api)
		if err != nil {
			return err
		}
	}

	endpoint := fmt.Sprintf("%s%s", bsapi.BaseUrl, endpointPart)
	var jsonBody []byte
	switch api.Method {
	case "POST":
		jsonBody, err = bsapi.marshalJson(reqPayload)
		if err != nil {
			err = fmt.Errorf("Unable to Marshal JSON, %w", err)
		}
		req, err = bsapi.DoPostRequest(endpoint, jsonBody)
	case "GET":
		req, err = bsapi.DoGetRequest(endpoint)
	default:
		err = fmt.Errorf("Method %s not supported", api.Method)
	}
	if err != nil {
		fmt.Printf("client: could not create request: %s\n", err)
		return err
	}

	// Set Authorization
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", bsapi.AuthToken))
	// Call Http Client
	resp, err := bsapi.Client.Do(req)
	if err != nil {
		fmt.Printf("client: error making http request: %s\n", err)
		return err
	}
	defer resp.Body.Close()
	fmt.Printf("Calling: %s with body %#v\n", endpoint, string(jsonBody))
	return bsapi.handleHttpResp(endpoint, resp, respReceiver)
}

// Send a POST method
func (bsapi *BetterStackApiCaller) DoPostRequest(requestUrl string, jsonBody []byte) (*http.Request, error) {
	body := bytes.NewReader(jsonBody)
	req, err := http.NewRequest(http.MethodPost, requestUrl, body)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", JSON_CONTENT_TYPE)
	return req, nil
}

// Send a GET method
func (bsapi *BetterStackApiCaller) DoGetRequest(requestUrl string) (*http.Request, error) {
	req, err := http.NewRequest(http.MethodGet, requestUrl, nil)
	if err != nil {
		return nil, err
	}
	return req, nil
}
