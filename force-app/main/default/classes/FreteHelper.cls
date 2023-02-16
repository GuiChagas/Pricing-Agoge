public with sharing class FreteHelper {
    public FreteHelper() {

    }
    public static void validateFreteCategory(List<Frete__c> PriceFreteList){
        for(Frete__c Frete : priceFreteList){
            if(!validateCategories(Frete)){
                Frete.addError(Label.FreteParametersError);
            }
        }
    }

    public static Boolean validateCategories(Frete__c Frete){
        if((String.isBlank(Frete.Product__c) && String.isBlank(Frete.ProductHierarchy__c)) || 
            (String.isBlank(Frete.City__c) && String.isBlank(Frete.State__c) && String.isBlank(Frete.Country__c)) ||
            (String.isNotBlank(Frete.Product__c) && String.isNotBlank(Frete.ProductHierarchy__c)) ||
            (String.isNotBlank(Frete.City__c) && String.isNotBlank(Frete.State__c)) ||
            (String.isNotBlank(Frete.City__c)  && String.isNotBlank(Frete.Country__c)) ||
            (String.isNotBlank(Frete.State__c) && String.isNotBlank(Frete.Country__c))){
                return false;
        }

        return true;
    }

    public static void calcScore(List<Frete__c> priceFreteList){
        for(Frete__c Frete : priceFreteList){
            Integer score = 0;              
                if(String.isNotEmpty(Frete.City__c)){
                    score += 30;
                }else if(String.isNotEmpty(Frete.State__c)){
                    score += 20;
                }else if(String.isNotEmpty(Frete.Country__c)){
                    score += 10;
                }

                if(String.isNotEmpty(Frete.Product__c)){
                    score += 2000;
                }else if(String.isNotEmpty(Frete.ProductHierarchy__c)){
                    score += 1000;
                }
            Frete.Score__c = score;
        }
    }

    public static void validateDuplicated(List<Frete__c> priceFreteList){
        Set<String> freteIdSet = new Set<String>();

        for(Frete__c frete : priceFreteList){
            // verificar se são todos os campos que podem ser validados --- caso sim, só adicionar os campos abaixo
            frete.UniqueKey__c = frete.Product__c +''+ frete.ProductHierarchy__c +frete.City__c +''+ frete.State__c +''+ frete.Country__c;
            
            freteIdSet.add(frete.UniqueKey__c);
        }

        Map<Id, Frete__c> freteMap = new Map<Id, Frete__c>([
            SELECT Id, UniqueKey__c, Name
            FROM Frete__c
            WHERE (UniqueKey__c IN: freteIdSet)
        ]);
        
        for(Frete__c frete : priceFreteList){                
            if(!freteMap.isEmpty()){
                frete.addError('O frete que está sendo cadastrado já existe na base de dados');
            }
        }
    }

    public static List<Frete__c> checkOlderFreteInfos(Map<Id,Frete__c> oldRecords, Map<Id,Frete__c> newRecords){
        Set<Id> freteId = new Set<Id>();
       
        for(Frete__c frete : newRecords.values()){
            Frete__c oldRecord = oldRecords.get(frete.Id);

            if(frete.Product__c != oldRecord.Product__c || frete.ProductHierarchy__c != oldRecord.ProductHierarchy__c){
                freteId.add(frete.Id);
            }else if(frete.Status__c != oldRecord.Status__c){
                freteId.add(frete.Id);
            }else if(frete.City__c != oldRecord.City__c || frete.State__c != oldRecord.State__c || frete.Country__c != oldRecord.Country__c){
                freteId.add(frete.Id);
            }
        }
    
        List<Frete__c> freteList = [
            SELECT Id, Product__c, ProductHierarchy__c, City__c,State__c, Country__c         
            FROM Frete__c
            WHERE Id IN: freteId
        ];

        validateFreteCategory(freteList);
        calcScore(freteList);

        return freteList;
    
    }
}