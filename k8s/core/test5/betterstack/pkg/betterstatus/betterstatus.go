package betterstatus

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

type BetterStackApiCaller struct {
	BaseUrl   string
	AuthToken string
	Client    *http.Client
}

func (bsapi *BetterStackApiCaller) marshalJson(payload interface{}) (jsonBody []byte, err error) {
	switch concretePayload := payload.(type) {
	case GnoMonitorPayload, CreateMonitorGroupPayload, CreateMonitorPayload:
		jsonBody, err = json.Marshal(concretePayload)
	default:
		jsonBody, err = json.Marshal(payload)
	}
	return
}

// General HTTP Client Handler
func (bsapi *BetterStackApiCaller) DoRequest(api BetterStackApiEndpoint, reqPayload interface{}) (respBody []byte, err error) {
	var req *http.Request
	endpoint := fmt.Sprintf("%s%s", bsapi.BaseUrl, api.Endpoint)
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
		return nil, err
	}

	// Set Atuhorization
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", bsapi.AuthToken))
	// Call Http Client
	// resp, err := bsapi.Client.Do(req)
	// if err != nil {
	// 	fmt.Printf("client: error making http request: %s\n", err)
	// 	return nil, err
	// }
	// defer resp.Body.Close()

	// // Handle Http Resp
	// if resp.StatusCode < 200 || resp.StatusCode > 299 {
	// 	return nil, fmt.Errorf("Error in HTTP call: %s", resp.Status)
	// }
	// respBody, err = io.ReadAll(resp.Body)
	// if err != nil {
	// 	return nil, err
	// }
	// if len(respBody) == 0 {
	// 	return nil, fmt.Errorf("Empty body from request %s", endpoint)
	// }
	// lines, _ := json.Marshal(reqPayload)
	fmt.Printf("Calling: %s with body %#v\n", endpoint, string(jsonBody))
	return []byte{}, nil
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
