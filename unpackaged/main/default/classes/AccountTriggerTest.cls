@isTest
public class AccountTriggerTest {
    public static TestMethod void testAccountTrigger(){
        Account account = new Account(FirstName='john',LastName='Smith',Race__pc='Asian',Preferred_Language__c ='English',
                                      Gender__pc='Male',Ethnicity__pc='Hispanic/LatinX',PersonEmail='abc@gmail.com',PersonBirthDate=system.today());
        insert account;
        
        Account accounts = [Select Id,Name,Applicant_Birth_Date__c from Account Where Id =:account.Id];
        system.assertEquals(account.PersonBirthDate,date.valueOf(accounts.Applicant_Birth_Date__c));
        
        
        careProgram careProgram = new careProgram(Name='Oklahoma Affiliate Fund',Care_Program_Type__c='Treatment Assistance Program',Status='Active');
        insert careProgram;
  
        Application__c application = new Application__c(Patient__c =account.id,Care_Program__c=careProgram.Id, Application_Status__c='New',Total_annual_Household_Income__c =40000,No_of_People_in_the_Household__c=3);
        insert application;
        
        application.Total_annual_Household_Income__c=10000;
        application.No_of_People_in_the_Household__c =2;
        update application;
        account.PersonMailingStateCode = 'NY';
        update account; 
        system.debug('@@account'+account);

        Application__c applications =[Select Id,Poverty_Level__c from Application__c where Id=:application.Id];
        system.debug('@@Application'+integer.valueOf(applications.Poverty_Level__c));
        //system.assert(applications.Poverty_Level__c>0);
    }
}