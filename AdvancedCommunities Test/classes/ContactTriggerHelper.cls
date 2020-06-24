public class ContactTriggerHelper {

    public static void handleCommunityUser (List<Contact> contacts) {
        
        Set<Id> customerContacts = new Set<Id>();        
        // Build Set of contacts IDs which is customers
        for (Contact con : contacts) {
            if (con.IsCustomer__c == true && con.Email != null) {
                customerContacts.add(con.Id);
            }
        }
        // List of contacts which is customers
        List<Contact> contactList = [
            SELECT Email, FirstName, LastName
            FROM Contact 
            WHERE Id IN : customerContacts
        ];

        List<User> userList = new List<User>();

        // Profile to Customer Community User
        Profile userProfile = [SELECT Id FROM Profile WHERE Name='Customer Community User' Limit 1];               
        // Create Customer Community User for each contact in list
        for (Contact contact : contactList) {
            String nickName = contact.Email.substring(0, contact.Email.indexOf('@')) + Datetime.now().getTime();
            String alias = contact.FirstName.left(1) + contact.LastName.toLowerCase().left(4);
            String userName = contact.Email;
            // Add new user to list
            userList.add(new User(
                UserName = userName,
                FirstName = contact.firstName,
                LastName = contact.lastName,
                Alias = alias,
                Email = contact.Email,
                EmailEncodingKey = 'UTF-8',
                ContactId = contact.Id,
                ProfileId = userProfile.Id,
                CommunityNickname = nickName,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(),
                LocaleSidKey = UserInfo.getLocale(),
                LanguageLocaleKey = UserInfo.getLanguage(),
                IsActive = true 
            ));            
        }
        insert userList;
    }

    public static void handleCommunityUser (List<Contact> contacts, Map<Id, Contact> oldMap) {
        Set<Id> customerContacts = new Set<Id>();
        Set<Id> notCustomerContacts = new Set<Id>();        
        // Build Sets of contacts IDs which became customer and are no longer customers
        for (Contact con: contacts) {
            if (con.IsCustomer__c == true && oldMap.get(con.Id).IsCustomer__c == false) {
                customerContacts.add(con.Id);
            } if (con.IsCustomer__c == false && oldMap.get(con.Id).IsCustomer__c == true) {
                notCustomerContacts.add(con.Id);
            }
        }
        // List of users for customer contact 
        List<User> existUsers = [
            SELECT Id, IsActive
            FROM User
            WHERE ContactId IN : customerContacts
        ];
        // List of contacts which is customers
        List<Contact> newUsers = [
            SELECT Id, Email, Account.Owner.UserRoleId, FirstName, LastName, IsCustomer__c
            FROM Contact
            WHERE Id IN : customerContacts
        ];
        // Activate user for customer contact if exist, else create new user
        if (!customerContacts.isEmpty() && !existUsers.isEmpty()) {
            activateUsers(customerContacts);
        } else {
            handleCommunityUser(newUsers);
        }
        // Deactivate user for contact which no longer customer       
        if (!notCustomerContacts.isEmpty()) {
            deactivateUsers(notCustomerContacts);
        }       
    }

    @future
    public static void activateUsers(Set<Id> users) {
        List<User> userList = new List<User>();
        // Activate all users for contact which became customer
        for (User u : [SELECT Id, IsActive FROM User WHERE ContactId IN : users]) {
            u.IsActive = true;
            userList.add(u);
        }
        update userList;
    }
    
    @future
    public static void deactivateUsers(Set<Id> users) {
        List<User> userList = new List<User>();
        // Deactivate all users for contact which no longer customer
        for (User u : [SELECT Id, IsActive FROM User WHERE ContactId IN : users]) {
            u.IsActive = false;
            userList.add(u);
        }
        update userList;
    } 
}