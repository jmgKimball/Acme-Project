/**
 * Http Mock Class
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-08-19
 */
@isTest
public class KHC_HttpCalloutMock implements HttpCalloutMock{
    public static final String NPI_ID = '12345';
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if( req.getEndpoint().contains( Label.NPI_Registry_Endpoint ) ){
            res.setHeader('Content-Type', 'application/json');
            res.setBody( getNpiRegistryBody() );
            res.setStatusCode(200);
        }
        if( req.getEndpoint().contains( Label.Medication_API_Endpoint ) ){
            res.setHeader('Content-Type', 'getNpiRegistryBody/json');
            res.setBody( getMedicationResponse() );
            res.setStatusCode(200);
        }
        return res;
    }

    private String  getNpiRegistryBody(){
        String body = '{' +
                            '"enumeration_type": "NPI-1",'+
                            '"number": '+ NPI_ID + ','+
                            '"last_updated_epoch": 1567094348,'+
                            '"created_epoch": 1459382400,'+
                            '"basic": {'+
                                '"first_name": "TEST",'+
                                '"last_name": "TEST",'+
                                '"credential": "M.D.",'+
                                '"sole_proprietor": "YES",'+
                                '"gender": "M",'+
                                '"enumeration_date": "2016-03-31",'+
                                '"last_updated": "2019-08-29",'+
                                '"status": "A",'+
                                '"name": "TEST TEST"'+
                            '},'+
                            '"other_names": [],'+
                            '"addresses": ['+
                                '{'+
                                    '"country_code": "US",'+
                                    '"country_name": "United States",'+
                                    '"address_purpose": "LOCATION",'+
                                    '"address_type": "DOM",'+
                                    '"address_1": "1638 OWEN DR",'+
                                    '"address_2": "",'+
                                    '"city": "FAYETTEVILLE",'+
                                    '"state": "NC",'+
                                    '"postal_code": "283043424",'+
                                    '"telephone_number": "110-615-1610",'+
                                    '"fax_number": "110-615-1080"'+
                                '},'+
                                '{'+
                                    '"country_code": "NP",'+
                                    '"country_name": "Nepal",'+
                                    '"address_purpose": "MAILING",'+
                                    '"address_type": "FGN",'+
                                    '"address_1": "6861 QUEENS FERRY RD",'+
                                    '"address_2": "APT B",'+
                                    '"city": "BALTIMORE",'+
                                    '"state": "MD",'+
                                    '"postal_code": "212391246",'+
                                    '"telephone_number": "#9779841376448"'+
                                '}'+
                            '],'+
                            '"taxonomies": ['+
                                '{'+
                                    '"code": "107R00000X",'+
                                    '"desc": "Internal Medicine",'+
                                    '"primary": true,'+
                                    '"state": "NC",'+
                                    '"license": "2019-01881"'+
                                '},'+
                                '{'+
                                    '"code": "190200000X",'+
                                    '"desc": "Student in an Organized Health Care Education/Training Program",'+
                                    '"primary": false,'+
                                    '"state": "",'+
                                    '"license": ""'+
                                '}'+
                            '],'+
                            '"identifiers": [],'+
                            '"practiceLocations": ['+
                                '{'+
                                    '"address_type": "DOM",'+
                                    '"address_1": "6915 DONACHIE RD APT C",'+
                                    '"address_2": "",'+
                                    '"city": "BALTIMORE",'+
                                    '"state": "MD",'+
                                    '"postal_code": "212391110",'+
                                    '"country_code": "US",'+
                                    '"country_name": "United States",'+
                                    '"telephone_number": "143-982-9180",'+
                                    '"update_date": "2019-08-29 15:08"'+
                                '}'+
                            ']'+
                        '}';
        return body;
    }

    private String getMedicationResponse(){
        String body = '{' +
                        '"meta": {'+
                            '"disclaimer": "Do not rely on openFDA to make decisions regarding medical care. ",'+
                            '"terms": "https://open.fda.gov/terms/",'+
                            '"license": "https://open.fda.gov/license/",'+
                            '"last_updated": "2020-09-15",'+
                            '"results": {'+
                                '"skip": 0,'+
                                '"limit": 1,'+
                                '"total": 653'+
                            '}'+
                        '},'+
                        '"data": ['+
                            '{'+
                                '"effective_time": "20191011",'+
                                '"inactive_ingredient": ['+
                                    '"Inactive ingredients"'+
                                '],'+
                                '"version": "10",'+
                                '"dosage_and_administration": ['+
                                    '"Directions do not take more than directed the smallest effective dose should be used "'+
                                '],'+
                                '"set_id": "00653b7c-7099-487e-9a01-e89781c21323",'+
                                '"id": "bc5de75b-6ad6-4c55-8ba2-b6fc4c38f288",'+
                                '"ask_doctor_or_pharmacist": ['+
                                    '"Ask a doctor or pharmacist before use "'+
                                '],'+
                                '"active_ingredient": ['+
                                    '"Active ingredient (in each white tablet) Ibuprofen USP, 200 mg (NSAID)* *nonsteroidal anti-inflammatory drug"'+
                                ']'+
                            '}'+
                        ']'+
                    '}';
        return body;
    }
}