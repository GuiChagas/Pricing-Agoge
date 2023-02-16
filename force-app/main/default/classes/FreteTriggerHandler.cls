public with sharing class FreteTriggerHandler {
    
    List<Frete__c> oldRecords {get; set;}
    List<Frete__c> newRecords {get; set;}
    Map<Id, Frete__c> oldMap {get; set;}
    Map<Id, Frete__c> newMap {get; set;}
    
    
    public FreteTriggerHandler(List<Frete__c> oldRecords, List<Frete__c> newRecords, Map<Id, Frete__c> oldMap, Map<Id, Frete__c> newMap ) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        FreteHelper.validateFreteCategory(this.newRecords);
        FreteHelper.calcScore(this.newRecords);
        FreteHelper.validateDuplicated(this.newRecords);
    }

    public void afterUpdate(){
    List<Frete__c> updatedOrderItemList = FreteHelper.checkOlderFreteInfos(this.oldMap, this.newMap);
           
       update updatedOrderItemList;

    } 
}