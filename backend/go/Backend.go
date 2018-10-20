/*
MIT License

Copyright (c) 2018 Gökhan Koçak www.gokhankocak.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/
package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"time"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

// CustomerData holds the basic data about a customer
type CustomerData struct {
	DocType   string `json:"DocType"`
	ID        string `json:"ID"`
	FirstName string `json:"FirstName"`
	LastName  string `json:"LastName"`
	City      string `json:"City"`
	State     string `json:"State"`
	Country   string `json:"Country"`
}

// BlackList holds the basic data about customers at black list
type BlackList struct {
	DocType   string `json:"DocType"`
	ID        string `json:"ID"`
	FirstName string `json:"FirstName"`
	LastName  string `json:"LastName"`
	Country   string `json:"Country"`
}

// CreditScore holds the credit score of a person
type CreditScore struct {
	DocType   string  `json:"DocType"`
	ID        string  `json:"ID"`
	FirstName string  `json:"FirstName"`
	LastName  string  `json:"LastName"`
	Score     float64 `json:"Score"`
}

type CouchDbResponse struct {
	Namespace string `json:"Namespace"`
	Key       string `json:"Key"`
	Value     string `json:"Value"`
}

// KeyModification holds the modification history entries
type KeyModification struct {
	TxId      string `json:"TxId"`
	Value     []byte `json:"Value"`
	Timestamp int64  `json:"TimeStamp"`
	IsDelete  bool   `json:"IsDelete"`
}

// InsertCustomerData from CustomerData.json to Hyperledger Fabric blockchain
func InsertCustomerData(cli *channel.Client) {

	var DataList []CustomerData

	DataAsBytes, err := ioutil.ReadFile("CustomerData.json")
	if err != nil {
		fmt.Println("InsertCustomerData(): ioutil.ReadFile() failed:", err.Error())
		return
	}

	err = json.Unmarshal(DataAsBytes, &DataList)
	if err != nil {
		fmt.Println("InsertCustomerData(): json.Unmarshal() failed:", err.Error())
		return
	}

	for _, d := range DataList {
		ValueAsBytes, err := json.Marshal(d)
		if err != nil {
			fmt.Println("InsertCustomerData(): json.Marshal() failed:", err.Error())
			return
		}
		_, err = cli.Execute(channel.Request{ChaincodeID: "asenacc", Fcn: "PutState", Args: [][]byte{[]byte(d.ID), ValueAsBytes}})
		if err != nil {
			fmt.Println("InsertCustomerData(): client.Execute(PutState) failed:", err.Error())
			return
		}

		fmt.Println(d)
	}
}

func main() {

	var cli *channel.Client
	var err error
	var cdr []CouchDbResponse

	configProvider := config.FromFile("../network-config.yaml")
	sdk, err := fabsdk.New(configProvider)
	if err != nil {
		fmt.Println("fabsdk.New() failed:", err.Error())
		return
	}
	defer sdk.Close()

	org1AdminUser := "Admin"
	org1Name := "Org1"

	//prepare contexts
	org1AdminChannelContext := sdk.ChannelContext("asena", fabsdk.WithUser(org1AdminUser), fabsdk.WithOrg(org1Name))

	for r := 0; r < 3; r++ {
		// channel client
		cli, err = channel.New(org1AdminChannelContext)
		if err != nil {
			fmt.Println("channel.New() failed:", err.Error())
			time.Sleep(5 * time.Second)
		} else {
			break
		}
	}

	// GetVersion of the Asena Smart Contract
	Resp, err := cli.Query(channel.Request{ChaincodeID: "asenacc", Fcn: "GetVersion", Args: [][]byte{nil}})
	if err != nil {
		fmt.Println("client.Query(GetVersion) failed:", err.Error())
		return
	} else {
		fmt.Println("GetVersion", Resp.ChaincodeStatus, string(Resp.Payload))
	}

	// GetStats of the Asena Smart Contract
	Resp, err = cli.Query(channel.Request{ChaincodeID: "asenacc", Fcn: "GetStats", Args: [][]byte{nil}})
	if err != nil {
		fmt.Println("client.Query(GetStats) failed:", err.Error())
	} else {
		fmt.Println("GetStats", Resp.ChaincodeStatus, string(Resp.Payload))
	}

	// GetHistory of a key
	Resp, err = cli.Query(channel.Request{ChaincodeID: "asenacc", Fcn: "GetHistory", Args: [][]byte{[]byte("AsenaSmartContract.Version")}})
	if err != nil {
		fmt.Println("client.Query(GetHistory) failed:", err.Error())
	} else {
		fmt.Println("GetHistory", Resp.ChaincodeStatus, string(Resp.Payload))

		var ModificationList []KeyModification
		err = json.Unmarshal(Resp.Payload, &ModificationList)
		if err != nil {
			fmt.Println("json.Unmarshal() failed:", err.Error())
			return
		}
		for _, m := range ModificationList {
			fmt.Println(m.Timestamp, string(m.Value))
		}
	}

	InsertCustomerData(cli)

	// Make a rich query
	Resp, err = cli.Query(channel.Request{ChaincodeID: "asenacc", Fcn: "GetQueryResult", Args: [][]byte{[]byte(`{"selector": { "Country": { "$eq": "Turkey" } }}`)}})
	if err != nil {
		fmt.Println("client.Execute(GetQueryResult) failed:", err.Error())
		return
	}

	err = json.Unmarshal(Resp.Payload, &cdr)
	if err != nil {
		fmt.Println("json.Unmarshal() failed:", err.Error())
	} else {
		for _, r := range cdr {

			data, err := base64.StdEncoding.DecodeString(r.Value)
			if err != nil {
				fmt.Println("base64.StdEncoding.DecodeString() failed:", err.Error())
			} else {
				fmt.Println(string(data))
			}
		}
	}
}
