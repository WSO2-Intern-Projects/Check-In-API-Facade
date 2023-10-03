import ballerina/http;
import ballerina/regex;


// configurable string BritishAirwaysCheckInServiceEndpoint = ?;
configurable string BritishAirwaysCheckInServiceClientId = ?;
configurable string BritishAirwaysCheckInServiceClientSecret = ?;
configurable string BritishAirwaysCheckInServiceTokenUrl = ?;

// configurable string QatarAirwaysCheckInServiceEndpoint = ?;
configurable string QatarAirwaysCheckInServiceClientId = ?;
configurable string QatarAirwaysCheckInServiceClientSecret = ?;
configurable string QatarAirwaysCheckInServiceTokenUrl = ?;

public type ServiceRequest record {
    string passengerName;
    string bookReference;
};

public type ServiceResponse record {
    string customerId;
    string flightNumber;
    string seatNumber;
    string passengerName;
    string fromWhere;
    string whereTo;
    int flightDistance;
};

service / on new http:Listener(9090) {
    // Define your resource functions here
    resource function post employees(@http:Payload ServiceRequest payload) returns json|error? {
        http:Client BritishAirwaysCheckInServiceEndpoint = check new ("https://b48cc93e-fa33-4420-a155-bc653b4d46be-dev.e1-us-east-azure.choreoapis.dev/hwqf/britishairwayscheckinservice/britishairwayscheckin-5c6/v1",
            auth = {
                tokenUrl: BritishAirwaysCheckInServiceTokenUrl,
                clientId: BritishAirwaysCheckInServiceClientId,
                clientSecret: BritishAirwaysCheckInServiceClientSecret
            }
        );

        http:Client QatarAirwaysCheckInServiceEndpoint = check new ("https://b48cc93e-fa33-4420-a155-bc653b4d46be-dev.e1-us-east-azure.choreoapis.dev/hwqf/qatarariwaysflightcheckinservice/customers-27f/v1",
            auth = {
                tokenUrl: QatarAirwaysCheckInServiceTokenUrl,
                clientId: QatarAirwaysCheckInServiceClientId,
                clientSecret: QatarAirwaysCheckInServiceClientSecret
            }
        );

        json[] responseList = [];

        ServiceResponse BritishAirwaysCheckInServiceResponse = check BritishAirwaysCheckInServiceEndpoint->/customers/checkIn.post(payload);
        string[] result1 = regex:split(BritishAirwaysCheckInServiceResponse.passengerName, " ");
        json BritishAirwaysCheckInServiceResponseJson = {
            "flightNumber": BritishAirwaysCheckInServiceResponse.flightNumber,
            "seatNumber": BritishAirwaysCheckInServiceResponse.seatNumber,
            "firsName": result1[0],
            "lastName": result1[1],
            "customerId": BritishAirwaysCheckInServiceResponse.customerId,
            "flightDistance": BritishAirwaysCheckInServiceResponse.flightDistance,
            "fromWhere": BritishAirwaysCheckInServiceResponse.fromWhere,
            "whereTo": BritishAirwaysCheckInServiceResponse.whereTo

        };
        responseList.push(BritishAirwaysCheckInServiceResponseJson);

        ServiceResponse QatarAirwaysCheckInServiceResponse = check QatarAirwaysCheckInServiceEndpoint->/checkIn.post(payload);
        string[] result2 = regex:split(QatarAirwaysCheckInServiceResponse.passengerName, " ");
        json QatarAirwaysCheckInServiceResponseJson = {
            "flightNumber": QatarAirwaysCheckInServiceResponse.flightNumber,
            "seatNumber": QatarAirwaysCheckInServiceResponse.seatNumber,
            "firsName": result2[0],
            "lastName": result2[1],
            "customerId": QatarAirwaysCheckInServiceResponse.customerId,
            "flightDistance": QatarAirwaysCheckInServiceResponse.flightDistance,
            "fromWhere": QatarAirwaysCheckInServiceResponse.fromWhere,
            "whereTo": QatarAirwaysCheckInServiceResponse.whereTo

        };
        responseList.push(QatarAirwaysCheckInServiceResponseJson);

        json aggregatedResponse = {"checkInInfo": responseList};
        return aggregatedResponse;
    }
}
