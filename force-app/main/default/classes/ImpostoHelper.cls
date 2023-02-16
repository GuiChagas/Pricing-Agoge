public with sharing class ImpostoHelper {
    public ImpostoHelper() {

    }

    public static void validateDuplicated(List<Imposto__c> priceImpostoList){
        Set<String> impostoIdSet = new Set<String>();

        for(Imposto__c imposto : priceImpostoList){
            // verificar se são todos os campos que podem ser validados --- caso sim, só adicionar os campos abaixo
            imposto.UniqueKey__c = imposto.Product__c +''+ imposto.DistributionCenter__c +''+imposto.State__c +''+imposto.Valor__c;            
            impostoIdSet.add(imposto.UniqueKey__c);
        }

        Map<Id, Imposto__c> impostoMap = new Map<Id, Imposto__c>([
            SELECT Id, UniqueKey__c, Name
            FROM Imposto__c
            WHERE (UniqueKey__c IN: impostoIdSet)
        ]);
        
        for(Imposto__c imposto : priceImpostoList){                
            if(!impostoMap.isEmpty()){
                imposto.addError('O imposto que está sendo cadastrado já existe na base de dados');
            }
        }
    }


    public static List<Imposto__c> checkOlderImpostoInfos(Map<Id,Imposto__c> oldRecords, Map<Id,Imposto__c> newRecords){
        Set<Id> impostoId = new Set<Id>();
       
        for(Imposto__c imposto : newRecords.values()){
            Imposto__c oldRecord = oldRecords.get(imposto.Id);

            if(imposto.Product__c != oldRecord.Product__c){
                impostoId.add(imposto.Id);
            }else if(imposto.DistributionCenter__c != oldRecord.DistributionCenter__c){
                impostoId.add(imposto.Id);
            }else if(imposto.State__c != oldRecord.State__c){
                impostoId.add(imposto.Id);
            }else if(imposto.Status__c != oldRecord.Status__c){
                impostoId.add(imposto.Id);
            }else if(imposto.Valor__c != oldRecord.Valor__c){
                impostoId.add(imposto.Id);
            }
        }
    
        List<Imposto__c> impostoList = [
            SELECT Id, UniqueKey__c, Product__c, DistributionCenter__c, State__c, Valor__c            
            FROM Imposto__c
            WHERE Id IN: impostoId
        ];

        validateDuplicated(impostoList);

        return impostoList;
    
    }
}
