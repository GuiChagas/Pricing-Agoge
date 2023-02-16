trigger ImpostoTrigger on Imposto__c (before insert, after update) {
    ImpostoTriggerHandler handler = new ImpostoTriggerHandler(
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