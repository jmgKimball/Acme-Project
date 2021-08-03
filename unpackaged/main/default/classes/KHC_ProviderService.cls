/**
 * Service methods user for NPI clinical trial
 * 
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-08-19
 */
public without sharing class KHC_ProviderService {

    private static final String NPI_API_ENDPOINT = Label.NPI_Registry_Endpoint;
    private static ContactSelector contactSelector = new ContactSelector();
    //Get Contact by NPI Id
    public static Contact getContactByNpiId( String npiId ){
        if( String.isNotBlank( npiId ) ){
            List<Contact> contacts = contactSelector.selectByNpiIds( new Set<String>{npiId} );
            if( contacts != null && !contacts.isEmpty() ){
                return contacts[0];
            }
        }
        return null;
    }

    //Method to search NPI registery providers.
    public static String getNpiRegistery( NpiSearchWrapper filterValues ){
        if( filterValues != null ){
            HttpRequest req = new HttpRequest();
            req.setMethod( 'GET' );
            String queryParameter = '/api/?version=2.1';
            queryParameter += getQueryParameters( filterValues );
            req.setEndpoint( NPI_API_ENDPOINT + queryParameter );
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug( res.getBody() );
            return res.getBody();
        }
        return null;
    }

    //Method to get query parameters according to filter values
    private static String getQueryParameters( NpiSearchWrapper filterValues ){
        String queryParameter = '';
        if( String.isNotBlank( filterValues.city ) ){
            queryParameter += '&city=' + filterValues.city;
        }
        if( String.isNotBlank( filterValues.state ) ){
            queryParameter += '&state=' + filterValues.state;
        }
        if( String.isNotBlank( filterValues.zipCode ) ){
            queryParameter += '&postal_code=' + filterValues.zipCode;
        }
        if( String.isNotBlank( filterValues.providerfirstName ) ){
            queryParameter += '&first_name=' + filterValues.providerfirstName;
        }
        if( String.isNotBlank( filterValues.providerLastName ) ){
            queryParameter += '&last_name=' + filterValues.providerLastName;
        }
        if( String.isNotBlank( filterValues.skip ) ){
            queryParameter += '&skip=' + filterValues.skip;
        }
        queryParameter += '&address_purpose=LOCATION';
        queryParameter += '&use_first_name_alias=true';
        queryParameter += '&limit=20';
        return queryParameter;
    }
    
    //Method to check whether request is valid or not. 
    public static boolean validateRequest( NpiSearchWrapper filterValues ){
        if( filterValues != null ){
            //Atleast one parameter is required
            if( String.isBlank( filterValues.city ) && 
                String.isBlank( filterValues.state ) && 
                String.isBlank( filterValues.zipCode ) &&
                String.isBlank( filterValues.providerLastName ) &&
                String.isBlank( filterValues.providerfirstName )){
                    return false;
            }
            return true;
        }
        return false;
    }

    //NPI Search Wrapper class to search provider in NPI registery 
    public class NpiSearchWrapper{
        public String city;
        public String state;
        public String zipCode;
        public String providerLastName;
        public String providerfirstName;
        public String skip;
    }
}