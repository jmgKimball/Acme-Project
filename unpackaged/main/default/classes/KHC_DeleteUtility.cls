/**
 * KHC_DeleteUtility
 * Class to allow delete record from community User
 * @author Nitin Chandwani, Traction on Demand
 * @date 2020-12-29
 */
public without sharing class KHC_DeleteUtility {
    
    @AuraEnabled
    public static void deleteRecord( Sobject rec ){
        if( rec != null ){
            try{
                DELETE rec;
            } catch( Exception excep ){
                throw new AuraHandledException( excep.getMessage() );
            }
        }
    }
}
