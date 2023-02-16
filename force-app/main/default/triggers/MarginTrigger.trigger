trigger MarginTrigger on Margem__c (before insert, after update) {
    MarginTriggerHandler handler = new MarginTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap    
    );

    switch on Trigger.operationType {
        when BEFORE_INSERT{
            handler.beforeInsert();
        }when AFTER_UPDATE{
            handler.afterUpdate();
        }
    }
}