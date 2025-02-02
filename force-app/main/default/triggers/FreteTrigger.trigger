trigger FreteTrigger on Frete__c (before insert, after update) {
    FreteTriggerHandler handler = new FreteTriggerHandler(
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
