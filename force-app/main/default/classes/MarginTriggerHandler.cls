public with sharing class MarginTriggerHandler {

    List<Margem__c> oldRecords {get; set;}
    List<Margem__c> newRecords {get; set;}
    Map<Id, Margem__c> oldMap {get; set;}
    Map<Id, Margem__c> newMap {get; set;}
    
    
    public MarginTriggerHandler(List<Margem__c> oldRecords, List<Margem__c> newRecords, Map<Id, Margem__c> oldMap, Map<Id, Margem__c> newMap ) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        MarginHelper.validateDuplicated(this.newRecords);
        MarginHelper.validateMarginCategory(this.newRecords);
        MarginHelper.calcScore(this.newRecords);
        
    }

    public void afterUpdate(){
        List<Margem__c> updatedMargemList = MarginHelper.checkOlderMargemInfos(this.oldMap, this.newMap);
           
        update updatedMargemList;
    }
}