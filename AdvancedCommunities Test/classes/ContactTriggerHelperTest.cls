@IsTest
public class ContactTriggerHelperTest {

     @testSetup static void createTestData() {
        // Create user which owne account and have role
        UserRole role = new UserRole(DeveloperName = 'Test', Name = 'My Role');
        insert role;
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user = new User (LastName = 'Test',
                              Alias = 'test',
                              Email = 'user@mail.com',
                              UserName = 'test.user36@mail.com',
                              CommunityNickname = 'testuser',
                              UserRoleId = role.Id,
                              ProfileId = profile.Id,
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US',
                              TimeZoneSidKey = 'America/Los_Angeles');
        insert user;        
    } 

    @isTest static void testCreationUsersForCustomerContacts() {
        User user = [SELECT UserRoleId FROM User WHERE LastName Like 'Test%'];
        // Create account for contacts
        Account acc = new Account(Name = 'Test Account',
                                  OwnerId = user.Id);
        insert acc;
    
        List<Contact> customers = new List<Contact>();
        // Create 20 customer contacts
        for (Integer i=0;i<20;i++) {
            Contact c = new Contact(AccountId = acc.Id,
                                    FirstName = 'CustomerFirstName '+i,
                                    LastName = 'CustomerLastName '+i,
                                    Email = i+'customer@mail.com',
                                    IsCustomer__c = true);
            customers.add(c);            
        } 
        // Inserting contacts fires the trigger which create community users
        Test.startTest();
            insert customers;
        Test.stopTest();
        // Find users which created by trigger
        List<User> users = [SELECT Id FROM User WHERE LastName Like 'CustomerLastName%'];
        // Compare number of created users with expected number
        System.assertEquals(20, users.size());
    }

    @isTest static void testCreationUsersForNonCustomerContacts() {
        User user = [SELECT UserRoleId FROM User WHERE LastName Like 'Test%'];
        // Create account for contacts
        Account acc = new Account(Name = 'Test Account',
                                  OwnerId = user.Id);
        insert acc;
    
        List<Contact> contacts = new List<Contact>();
        // Create 20 non-customer contacts
        for (Integer i=0;i<20;i++) {
            Contact c = new Contact(AccountId = acc.Id,
                                    FirstName = 'ContactFirstName '+i,
                                    LastName = 'ContactLastName '+i,
                                    Email = i+'contactr@mail.com',
                                    IsCustomer__c = false);
            contacts.add(c);            
        } 
        // Inserting contacts fires the trigger which don`t create community users because they are not customers
        Test.startTest();
            insert contacts;
        Test.stopTest();
        // Find users which created by trigger
        List<User> users = [SELECT Id FROM User WHERE LastName Like 'ContactLastName%'];
        // Compare number of created users with expected number
        System.assertEquals(0, users.size());
    }

    @isTest static void testUpdateContactToCustomer() {
        User user = [SELECT UserRoleId FROM User WHERE LastName Like 'Test%'];
        // Create account for contacts
        Account acc = new Account(Name = 'Test Account',
                                  OwnerId = user.Id);
        insert acc;
    
        List<Contact> customers = new List<Contact>();
        // Create 20 non-customer contacts
        for (Integer i=0;i<20;i++) {
            Contact c = new Contact(AccountId=acc.Id,
                                    FirstName = 'CustomerFirstName '+i,
                                    LastName = 'CustomerLastName '+i,
                                    Email = i+'customer@mail.com',
                                    IsCustomer__c = false);
            customers.add(c);            
        } 
        // Inserting contacts fires trigger but community users don`t created because contact isn`t customers
        insert customers;
        // Update contacts to customers create community users
        for (Contact c : customers) {
            c.IsCustomer__c = true;
        }
        
        Test.startTest();
            update customers;
        Test.stopTest();
        // Find users which created by trigger
        List<User> users = [SELECT IsActive FROM User WHERE LastName Like 'CustomerLastName%'];
        // Compare number of created users with expected number
        System.assertEquals(20, users.size());
    }

    @isTest static void testDeactivateComunityUsers() {
        User user = [SELECT UserRoleId FROM User WHERE LastName Like 'Test%'];
        // Create account for contacts
        Account acc = new Account(Name = 'Test Account',
                                  OwnerId = user.Id);
        insert acc;
    
        List<Contact> contacts = new List<Contact>();
        // Create 20 customer contacts
        for (Integer i=0;i<20;i++) {
            Contact c = new Contact(AccountId=acc.Id,
                                    FirstName = 'ContactFirstName '+i,
                                    LastName = 'ContactLastName '+i,
                                    Email = i+'contactr@mail.com',
                                    IsCustomer__c = true);
            contacts.add(c);            
        } 
        // Inserting contacts fires trigger which create community users
        insert contacts;

        // Update contacts to non-customers
        for (Contact c : contacts) {
            c.IsCustomer__c = false;
        }

        Test.startTest();
            update contacts;
        Test.stopTest();
        // Find users which created by trigger
        List<User> users = [SELECT IsActive FROM User WHERE LastName Like 'ContactLastName%'];
        // Check whether users where deactivated 
        for (User u: users) {
            System.assertEquals(false, u.IsActive);
        }        
    }

    @isTest static void testActivateComunityUsers() {
        User user = [SELECT UserRoleId FROM User WHERE LastName Like 'Test%'];
        // Create account for contacts
        Account acc = new Account(Name = 'Test Account',
                                  OwnerId = user.Id);
        insert acc;
    
        List<Contact> contacts = new List<Contact>();
        // Create 20 customer contacts
        for (Integer i=0;i<20;i++) {
            Contact c = new Contact(AccountId=acc.Id,
                                    FirstName = 'ContactFirstName '+i,
                                    LastName = 'ContactLastName '+i,
                                    Email = i+'contact@mail.com',
                                    IsCustomer__c = true);
                                    contacts.add(c);            
        } 
        // Inserting contacts fires trigger which create community users
        insert contacts;

        // Update contacts to non-customers deactivate community users
        for (Contact c : contacts) {
            c.IsCustomer__c = false;
        }
        update contacts;

        // Update contacts to customers activate community users
        for (Contact c : contacts) {
            c.IsCustomer__c = true;
        }

        Test.startTest();
            update contacts;
        Test.stopTest();
        // Find users which created by trigger
        List<User> users = [SELECT IsActive FROM User WHERE LastName Like 'ContactLastName%'];
        // Check whether users where deactivated 
        for (User u: users) {
            System.assertEquals(true, u.IsActive);
        }        
    }
}
