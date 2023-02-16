public with sharing class MarginHelper {
    public MarginHelper() {

    }

    public static void validateMarginCategory(List<Margem__c> PriceMarginList){
        for(Margem__c margin : priceMarginList){
            if(!validateCategories(margin)){
                margin.addError(Label.MarginParametersError);
            }
        }
    }

    public static Boolean validateCategories(Margem__c margin){
        if((String.isBlank(margin.Product__c) && String.isBlank(margin.ProductHierarchy__c)) || 
            (String.isBlank(margin.Account__c) && String.isBlank(margin.AccountGroup__c)) ||
            (String.isBlank(margin.City__c) && String.isBlank(margin.State__c) && String.isBlank(margin.Country__c)) ||
            (String.isNotBlank(margin.Product__c) && String.isNotBlank(margin.ProductHierarchy__c)) || 
            (String.isNotBlank(margin.Account__c) && String.isNotBlank(margin.AccountGroup__c)) ||
            (String.isNotBlank(margin.City__c) && String.isNotBlank(margin.State__c)) ||
            (String.isNotBlank(margin.City__c)  && String.isNotBlank(margin.Country__c)) ||
            (String.isNotBlank(margin.State__c) && String.isNotBlank(margin.Country__c))){
                return false;
        }

        return true;
    }

    public static void calcScore(List<Margem__c> priceMarginList){
        for(Margem__c margin : priceMarginList){
            Integer score = 0;
                if(String.isNotEmpty(margin.City__c)){
                    score += 30;
                }else if(String.isNotEmpty(margin.State__c)){
                    score += 20;
                }else if(String.isNotEmpty(margin.Country__c)){
                    score += 10;
                }

                if(String.isNotEmpty(margin.Account__c)){
                    score += 200;
                }else if(String.isNotEmpty(margin.AccountGroup__c)){
                    score += 100;
                }

                if(String.isNotEmpty(margin.Product__c)){
                    score += 2000;
                }else if(String.isNotEmpty(margin.ProductHierarchy__c)){
                    score += 1000;
                }
               margin.Score__c = score;
        }
    }

    public static void validateDuplicated(List<Margem__c> priceMarginList){
        Set<String> marginIdSet = new Set<String>();

        for(Margem__c margin : priceMarginList){
            margin.UniqueKey__c = '';
            // verificar se são todos os campos que podem ser validados --- caso sim, só adicionar os campos abaixo
            margin.UniqueKey__c = margin.Product__c +''+ margin.ProductHierarchy__c +''+margin.Account__c +''+margin.AccountGroup__c+''+margin.City__c +''+margin.State__c +''+margin.Country__c;
            
            marginIdSet.add(margin.UniqueKey__c);
        }

        Map<Id, Margem__c> marginMap = new Map<Id, Margem__c>([
            SELECT Id, UniqueKey__c, Name
            FROM Margem__c
            WHERE (UniqueKey__c IN: marginIdSet)
        ]);
        
        for(Margem__c margin : priceMarginList){                
            if(!marginMap.isEmpty()){
                margin.addError('A margem que está sendo cadastrada já existe na base de dados');
            }
        }
    }

    public static List<Margem__c> checkOlderMargemInfos(Map<Id,Margem__c> oldRecords, Map<Id,Margem__c> newRecords){
        Set<Id> margemId = new Set<Id>();
       
        for(Margem__c margem : newRecords.values()){
            Margem__c oldRecord = oldRecords.get(margem.Id);

            if(margem.Product__c != oldRecord.Product__c || margem.ProductHierarchy__c != oldRecord.ProductHierarchy__c){
                margemId.add(margem.Id);
            }else if(margem.Account__c != oldRecord.Account__c || margem.AccountGroup__c != oldRecord.AccountGroup__c){
                margemId.add(margem.Id);
            }else if(margem.Status__c != oldRecord.Status__c){
                margemId.add(margem.Id);
            }else if(margem.City__c != oldRecord.City__c || margem.State__c != oldRecord.State__c || margem.Country__c != oldRecord.Country__c){
                margemId.add(margem.Id);
            }
        }
    
        List<Margem__c> margemList = [
            SELECT Id, Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c        
            FROM Margem__c
            WHERE Id IN: margemId
        ];

        validateMarginCategory(margemList);
        validateDuplicated(margemList);
        calcScore(margemList);

        return margemList;
    
    }
}