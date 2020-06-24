trigger ContactTrigger on Contact (before insert, after insert, 
  before update, after update, 
  before delete, after delete) {
    
    if (Trigger.isBefore) {
        //Call class logic here!        
    } 
    if (Trigger.isUpdate) {
      // Call class logic here!
        
    }
    if (Trigger.isDelete) {
      // Call class logic here!
    }
  

  if (Trigger.IsAfter) {
    if (Trigger.isInsert) {
      ContactTriggerHelper.handleCommunityUser(Trigger.new);
    } 
    if (Trigger.isUpdate) {
      ContactTriggerHelper.handleCommunityUser(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isDelete) {
      // Call class logic here!
    }
  }

}