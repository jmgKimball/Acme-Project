/**
@name       KHC_SyncReferralRecordsSchedule
@date       11 May 2021
@description Schedule class to update referral record when linked article is an old version
@author     NChandwani, Traction on Demand 
 */
public class KHC_SyncReferralRecordsSchedule implements System.Schedulable{
   
   public void execute( System.SchedulableContext sc ){
       
        KHC_SyncReferralRecordsBatch syncReferralBatch = new KHC_SyncReferralRecordsBatch();
        Database.executeBatch( syncReferralBatch );
   }
   
}
