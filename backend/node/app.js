//
// export HFC_LOGGING='{"debug":"console","info":"console"}'
//

'use strict';
const fs = require('fs');
const http = require('http');
var express = require('express');
var app = express();
var engines = require('consolidate');
var assert = require('assert');
var router = express.Router();

const SDKroot = '/Volumes/SeaVM/Veri/Fabric/fabric-sdk-node/'

var Client = require(SDKroot + "fabric-client");
var Ca = require(SDKroot + "fabric-ca-client");

var client = Client.loadFromConfig('../network-config.yaml');
var cliCfg = client.getClientConfig();
client.loadFromConfig('../network-config.yaml');

var PrivateKeyDir  = '../../crypto/peerOrganizations/asena.fabric/users/Admin@asena.fabric/msp/keystore';
var CertificateFile = '../../crypto/peerOrganizations/asena.fabric/users/Admin@asena.fabric/msp/signcerts/Admin@asena.fabric-cert.pem';

var PrivateKeyFile = fs.readdirSync(PrivateKeyDir)[0]
var PrivateKey = fs.readFileSync(PrivateKeyDir + '/' + PrivateKeyFile);
var Certificate = fs.readFileSync(CertificateFile);

function GetState(Key, Callback) {
    client.initCredentialStores()
        .then((nothing) => {
            var peer0_org1 = client.getPeersForOrg('Org1')[0];
            var channel = client.getChannel('asena', true);
            client.setAdminSigningIdentity(PrivateKey, Certificate, client.getMspid());
            client.setUserContext({username: 'admin', password: 'adminpw'})
            client._setUserFromConfig({username: 'admin'})
                .then((nothing) => {
                    let tx_id = client.newTransactionID(true);
                    var request = {
                        chaincodeId : 'asenacc',
                        fcn: 'GetState',
                        args: [Key],
                        txId: tx_id
                    };
                    channel.sendTransactionProposal(request)
                        .then((Response, Proposal) => {
                            var Result = {
                                Status: Response[0][0].response.status,
                                Message: Response[0][0].response.message,
                                Payload: Response[0][0].response.payload.toString()
                            }
                            Callback(Result);
                            return Result;
                            console.log('\nStatus :', Response[0][0].response.status);
                            console.log('Message:', Response[0][0].response.message);
                            console.log('Payload:', Response[0][0].response.payload.toString());
                            /*
                            channel.sendTransaction(Proposal)
                                .then((BroadcastResponse) => {
                                    console.log(BroadcastResponse);
                                });
                                */
                    });
        });
        /*
        client.setUserContext({username: 'admin', password: 'adminpw'})
            .then((admin) => {
                var fabric_ca_client = client.getCertificateAuthority('ca-org1');
                fabric_ca_client.register({enrollmentID: 'admin', affiliation: 'org1'}, admin)
                    .then((secret) => {
                        client.setUserContext({username:'admin', password:secret});
                    fabric_ca_client.enroll({enrollmentID: 'admin', enrollmentSecret: secret})
                        .then((secret) => {
                            return client.setUserContext({username:'admin', password:secret});
                        }).then((user) => {
                            console.log(client);

                            let tx_id = client.newTransactionID();
                            var request = {
                                chaincodeId : 'mycc',
                                fcn: 'query',
                                args: ['a', 'b','100'],
                                txId: tx_id
                            };
                            return channel.sendTransactionProposal(request);
                        });
                });
        });
        */
    });
}

function GetCustomerData(Callback) {
    client.initCredentialStores()
        .then((nothing) => {
            var peer0_org1 = client.getPeersForOrg('Org1')[0];
            var channel = client.getChannel('asena', true);
            client.setAdminSigningIdentity(PrivateKey, Certificate, client.getMspid());
            client.setUserContext({username: 'admin', password: 'adminpw'})
            client._setUserFromConfig({username: 'admin'})
                .then((nothing) => {
                    let tx_id = client.newTransactionID(true);
                    var request = {
                        chaincodeId : 'asenacc',
                        fcn: 'GetQueryResult',
                        args: ['{"selector": { "DocType": { "$eq": "CustomerData" } }}'],
                        txId: tx_id
                    };
                    channel.sendTransactionProposal(request)
                        .then((Response, Proposal) => {
                            var Result = {
                                Status: Response[0][0].response.status,
                                Message: Response[0][0].response.message,
                                Payload: Response[0][0].response.payload.toString()
                            }
                            Callback(Result);
                            return Result;
                        });
            });
    });
}

app.engine('html', engines.nunjucks);
app.set('view engine', 'html');
app.set('views', __dirname + '/views');
app.use(router);

router.use(function(req, res, next) {
  console.log('method: %s url: %s path: %s', req.method, req.url, req.path);
  next();
});

router.get('/AsenaSmartContract', function(req, res, next) {

    GetState('AsenaSmartContract.Version', function(r) {
        var out = [{
            Key: 'AsenaSmartContract.Version',
            Value: r.Payload,
            Status: r.Status,
            Message: r.Message
        }]
        GetState('AsenaSmartContract.Status', function(r) {
            out[1] = {
                Key: 'AsenaSmartContract.State',
                Value: r.Payload,
                Status: r.Status,
                Message: r.Message
            }
            GetState('AsenaSmartContract.Config', function(r) {
                out[2] = {
                    Key: 'AsenaSmartContract.Config',
                    Value: r.Payload,
                    Status: r.Status,
                    Message: r.Message
                }
                res.render('AsenaSmartContract', {'result': out});
            });
        });
    });
});

router.get('/GetState/:Key', function(req, res, next) {

    GetState(req.params.Key, function(r) {
        var out = {
            Key: req.params.Key,
            Value: r.Payload,
            Status: r.Status,
            Message: r.Message
        }
        res.render('GetState', {'r': out});
    });
});

router.get('/GetCustomerData', function(req, res, next) {

    GetCustomerData(function(r) {
        var out = []
        var payload = JSON.parse(r.Payload)
        for (var k = 0; k < payload.length; k++) {
            var b = new Buffer(payload[k].Value, 'base64')
            out[k] = JSON.parse(b.toString('utf-8'))
        }
        res.render('GetCustomerData', {'result': out});
    });
});

var server = app.listen(3000, function() {
    var port = server.address().port;
    var addr = server.address();
    console.log('Express server is listenining at %s on port %s', addr, port);
  });