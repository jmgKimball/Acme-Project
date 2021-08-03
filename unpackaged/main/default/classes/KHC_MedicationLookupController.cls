/**
 * Medication Lookup Controller
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-09-07
 */
public with sharing class KHC_MedicationLookupController {

    private static string MEDICATION_API_ENDPOINT = Label.Medication_API_Endpoint;
    private static string MEDICATION_SERVICE_ERROR = Label.Medication_Service_Error;
    private static string MEDICATION_SERVICE_MESSAGE = Label.Medication_Service_Message;
    private static MedicationSelector medicationSelector = new MedicationSelector();

    @AuraEnabled
    public static string upsertMedication( Medication__c medication ){

        if( medication != null && String.isNotBlank( medication.Med_Name__c ) ){
            List<Medication__c> medications = medicationSelector.selectByName( medication.Med_Name__c );
            if( medications != null && !medications.isEmpty() ){
                return medications[0].Id;
            }else if( medication.Id == null ) {
                try{
                    INSERT medication;
                }catch( DmlException excep ){
                    System.debug( excep );
                }
            }
        }
        return medication.Id;
    }

    @AuraEnabled
    public static List<drugWrap> getAllMedications( String keyword ){
        if( String.isNotBlank( keyword ) ){
            try {
                String endpoint = MEDICATION_API_ENDPOINT;
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                String queryParameter = '/dailymed/services/v2/spls.json?drug_name=' + EncodingUtil.urlEncode(keyword, 'UTF-8');
                req.setEndpoint(endpoint + queryParameter);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug('** res.getStatusCode() '+res.getStatusCode());

                if (res.getStatusCode() == 200) {
                    Map<String, Object> drugDetailMap = (Map<String, Object>) Json.deserializeUntyped(res.getBody());
                    List<Object> drugResult = (List<Object>) drugDetailMap.get('data');
                    List<DrugWrap> drugNameList = new List<DrugWrap>();
                    for (Object drugname : drugResult) {
                        Map<String, Object> drugTitle = (Map<String, Object>) drugname;
                        DrugWrap dw = new DrugWrap();
                        dw.title = (String) drugTitle.get('title');
                        dw.setid = (String) drugTitle.get('setid');
                        drugNameList.add(dw);
                    }
                    return drugNameList;
                }
                else{
                    CustomException data = new CustomException(MEDICATION_SERVICE_ERROR, MEDICATION_SERVICE_MESSAGE, res.getStatusCode());
                    throw new AuraHandledException(JSON.serialize(data));
                }
            }catch (Exception e){
                CustomException data = new CustomException(MEDICATION_SERVICE_ERROR, e.getMessage() );
                throw new AuraHandledException(JSON.serialize(data));
            }
        }
        return null;
    }

   // Wrapper class for Drug Service Response data
    @TestVisible
    class DrugWrap{
        @AuraEnabled
        public String title{get; set;}
        @AuraEnabled
        public String setid{get; set;}
    }

    // Wrapper class for custom exception
    public class CustomException extends Exception{
        public String name;
        public String message;
        public Integer code;

        public CustomException(String name, String message, Integer code) {
            this.name = name;
            this.message = message;
            this.code = code;
        }

        public CustomException(String name, String message) {
            this.name = name;
            this.message = message;
            this.code = code;
        }
    }
}