public with sharing class ImpostoTriggerHandler {
    List<Imposto__c> oldRecords {get; set;}
    List<Imposto__c> newRecords {get; set;}
    Map<Id, Imposto__c> oldMap {get; set;}
    Map<Id, Imposto__c> newMap {get; set;}
    
    
    public ImpostoTriggerHandler(List<Imposto__c> oldRecords, List<Imposto__c> newRecords, Map<Id, Imposto__c> oldMap, Map<Id, Imposto__c> newMap ) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        ImpostoHelper.validateDuplicated(this.newRecords);
    }

    public void afterUpdate(){
        List<Imposto__c> updatedImpostoList = ImpostoHelper.checkOlderImpostoInfos(this.oldMap, this.newMap);
        update updatedImpostoList;

    } 
}
