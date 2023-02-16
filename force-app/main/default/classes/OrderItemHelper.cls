public with sharing class OrderItemHelper {
    public OrderItemHelper() {

    }

    public static List<OrderItem> checkOlderOrderItemInfos(Map<Id,OrderItem> oldRecords, Map<Id,OrderItem> newRecords){
        Set<Id> orderItemId = new Set<Id>();

        for(OrderItem orderItem : newRecords.values()){
            OrderItem oldRecord = oldRecords.get(orderItem.Id);

            if(orderItem.Quantity != oldRecord.Quantity){
                orderItemId.add(orderItem.Id);
            }
       }

        List<OrderItem> orderItemList = [
            SELECT Id, Product2Id, OrderId            
            FROM OrderItem
            WHERE Id IN: orderItemId
        ];

        List<OrderItem> updatedOrderItemList = OrderItemHelper.calcPrice(orderItemList);

        return updatedOrderItemList;
    
    }

    public static void validateMainParameters (List<OrderItem> orderItemList){
        for(OrderItem orderItem : orderItemList){
            if(!validateCategories(orderItem)){
                orderItem.addError('Não está autorizada a venda deste produto devido a falta de parâmetros, contactar o time de Pricing.');
            }
        }
    }

    public static Boolean validateCategories(OrderItem orderItem){
        if((orderItem.ListPrice == null || orderItem.ValorFrete__c == null|| orderItem.PorcentagemImposto__c == null || orderItem.PorcentagemMargem__c == null)){
            return false;
        }
    
        return true;
    }


    //-------------- MARGEM -------------
    public static Map<OrderItem, Margem__c> searchMargin(List<OrderItem> orderItemList, Map<Id, Order> orderMap, Map<Id, Product2> productMap){

        Set<Id> productsIds = new Set<Id>();
        Set<Id> hierarchyIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> groupsIds = new Set<Id>();
        Set<Id> distributionIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();

        for(Order order : orderMap.values()){
            accountIds.add(order.AccountId);
            groupsIds.add(order.Account.AccountGroup__c);
            cityIds.add(order.AccountAddress__r.City__c);
            stateIds.add(order.AccountAddress__r.City__r.State__c);
            countryIds.add(order.AccountAddress__r.City__r.State__r.Country__c);
        }

        for(Product2 product : productMap.values()){
            productsIds.add(product.Id);
            hierarchyIds.add(product.ProductHierarchy__c);
        }

        List<Margem__c> priceMarginList = [
            SELECT Id, Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c, Valor__c, Score__c
            FROM Margem__c
            WHERE (Product__c IN: productsIds OR Product__c = null) AND
            (ProductHierarchy__c IN: hierarchyIds OR ProductHierarchy__c = null) AND
            (Account__c IN: accountIds OR Account__c = null) AND
            (AccountGroup__c IN: groupsIds OR AccountGroup__c = null) AND
            (City__c IN: cityIds OR City__c = null) AND
            (State__c IN: stateIds OR State__c = null) AND
            (Country__c IN: countryIds OR Country__c = null) AND
            (Status__c = 'Aprovado')
            ORDER BY Score__c DESC
        ];

        System.debug('LIST PRICE => ' + priceMarginList);

        Map<OrderItem, Margem__c> orderItemToMargin = new Map<OrderItem, Margem__c>();

        for(OrderItem orderItem : orderItemList){
            orderItemToMargin.put(orderItem, null);


            for(Margem__c margin : priceMarginList){
                if(matchMargin(margin, orderItem, orderMap, productMap)){
                    orderItemToMargin.put(orderItem, margin);
                    break;
                }
            }
        }

        return orderItemToMargin;
    }

   
    public static Boolean matchMargin(Margem__c margin, OrderItem orderItem, Map<Id, Order> orderMap, Map<Id, Product2> productMap){
        return (String.isBlank(margin.Product__c) || margin.Product__c == orderItem.Product2Id) ||
        (String.isBlank(margin.ProductHierarchy__c) || margin.ProductHierarchy__c == productMap.get(orderItem.Product2Id).ProductHierarchy__c) &&
        (String.isBlank(margin.Account__c) || margin.Account__c == orderMap.get(orderItem.OrderId).AccountId) ||
        (String.isBlank(margin.AccountGroup__c) || margin.AccountGroup__c == orderMap.get(orderItem.OrderId).Account.AccountGroup__c) &&
        (String.isBlank(margin.State__c) || margin.State__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__c) ||
        (String.isBlank(margin.City__c) || margin.City__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__c)||
        (String.isBlank(margin.Country__c) || margin.Country__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c);

    }
    //-------------- FRETE -------------
    public static Map<OrderItem, Frete__c> searchFrete(List<OrderItem> orderItemList, Map<Id, Order> orderMap, Map<Id, Product2> productMap){

        Set<Id> productsIds = new Set<Id>();
        Set<Id> hierarchyIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();

        for(Order order : orderMap.values()){
            cityIds.add(order.AccountAddress__r.City__c);
            stateIds.add(order.AccountAddress__r.City__r.State__c);
            countryIds.add(order.AccountAddress__r.City__r.State__r.Country__c);
        }

        for(Product2 product : productMap.values()){
            productsIds.add(product.Id);
            hierarchyIds.add(product.ProductHierarchy__c);
        }

        List<Frete__c> priceFreteList = [
            SELECT Id, Product__c, ProductHierarchy__c, City__c, State__c, Country__c, Valor__c, Score__c
            FROM Frete__c
            WHERE (Product__c IN: productsIds OR Product__c = null) AND
            (ProductHierarchy__c IN: hierarchyIds OR ProductHierarchy__c = null) AND
            (City__c IN: cityIds OR City__c = null) AND
            (State__c IN: stateIds OR State__c = null) AND
            (Country__c IN: countryIds OR Country__c = null)  AND
            (Status__c = 'Aprovado')
            ORDER BY Score__c DESC
        ];

        System.debug('FRETE => ' + priceFreteList);

        Map<OrderItem, Frete__c> orderItemToFrete = new Map<OrderItem, Frete__c>();

        for(OrderItem orderItem : orderItemList){
            orderItemToFrete.put(orderItem, null);

            for(Frete__c frete : priceFreteList){
                if(matchFrete(frete, orderItem, orderMap, productMap)){
                    orderItemToFrete.put(orderItem, frete);
                    break;
                }
            }
        }

        return orderItemToFrete;
    }

    public static Boolean matchFrete(Frete__c frete, OrderItem orderItem, Map<Id, Order> orderMap, Map<Id, Product2> productMap){
        return (String.isBlank(frete.Product__c) || frete.Product__c == orderItem.Product2Id) &&
        (String.isBlank(frete.ProductHierarchy__c) || frete.ProductHierarchy__c == productMap.get(orderItem.Product2Id).ProductHierarchy__c) &&
        (String.isBlank(frete.State__c) || frete.State__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__c) &&
        (String.isBlank(frete.City__c) || frete.City__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__c) &&
        (String.isBlank(frete.Country__c) || frete.Country__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c);



    }

    //-------------- IMPOSTO -------------

    public static Map<OrderItem, Imposto__c> searchImposto(List<OrderItem> orderItemList, Map<Id, Order> orderMap, Map<Id, Product2> productMap){

        Set<Id> productsIds = new Set<Id>();
        Set<Id> distrCenterIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();

        for(Order order : orderMap.values()){
            stateIds.add(order.AccountAddress__r.City__r.State__c);
            distrCenterIds.add(order.DistributionCenter__c);

        }

        for(Product2 product : productMap.values()){
            productsIds.add(product.Id);
        }

        List<Imposto__c> priceImpostoList = [
            SELECT Id, Product__c, DistributionCenter__c, State__c, Valor__c
            FROM Imposto__c
            WHERE (Product__c IN: productsIds OR Product__c = null) AND
            (State__c IN: stateIds OR State__c = null) AND
            (DistributionCenter__c IN: distrCenterIds OR DistributionCenter__c = null)  AND
            (Status__c = 'Aprovado')
        ];

        Map<OrderItem, Imposto__c> orderItemToImposto = new Map<OrderItem, Imposto__c>();

        for(OrderItem orderItem : orderItemList){
            orderItemToImposto.put(orderItem, null);

            for(Imposto__c imposto : priceImpostoList){
                if(matchImposto(imposto, orderItem, orderMap, productMap)){
                    orderItemToImposto.put(orderItem, imposto);
                    break;
                }
            }
        }

        return orderItemToImposto;
    }

    public static Boolean matchImposto(Imposto__c imposto, OrderItem orderItem, Map<Id, Order> orderMap, Map<Id, Product2> productMap){
        return (String.isBlank(imposto.Product__c) || imposto.Product__c == orderItem.Product2Id) &&
        (String.isBlank(imposto.State__c) || imposto.State__c == orderMap.get(orderItem.OrderId).AccountAddress__r.City__r.State__c) &&
        (String.isBlank(imposto.DistributionCenter__c) || imposto.DistributionCenter__c == orderMap.get(orderItem.OrderId).DistributionCenter__c);
    }
    
 //-------------- CALC PRICING -------------
    public static List<OrderItem> calcPrice(List<OrderItem> orderItemList){

        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();

        for(OrderItem orderItem : orderItemList){
            orderIdSet.add(orderItem.OrderId);
            productIdSet.add(orderItem.Product2Id);
        }

        
        Map<Id, Order> orderMap = new Map<Id, Order>([
            SELECT Id, AccountId, Account.AccountGroup__c, AccountAddress__r.City__c, AccountAddress__r.City__r.State__c, AccountAddress__r.City__r.State__r.Country__c, DistributionCenter__c
            FROM Order
            WHERE Id IN: orderIdSet
        ]);

        System.debug(orderMap);

        Map<Id, Product2> productMap = new Map<Id, Product2>([
            SELECT Id, ProductHierarchy__c
            FROM Product2
            WHERE Id IN: ProductIdSet
        ]);

        System.debug(productMap);

        Map<OrderItem, Imposto__c> orderItemToImposto = searchImposto(orderItemList, orderMap, productMap);
        Map<OrderItem, Frete__c> orderItemToFrete = searchFrete(orderItemList, orderMap, productMap);
        Map<OrderItem, Margem__c> orderItemToMargin = searchMargin(orderItemList, orderMap, productMap);


        for(OrderItem orderItem : orderItemList){
            Imposto__c priceImposto = orderItemToImposto.get(orderItem);
            Frete__c priceFrete = orderItemToFrete.get(orderItem);
            Margem__c priceMargem = orderItemToMargin.get(orderItem);

            if(priceImposto != null){

                System.debug(priceImposto);
                System.debug(priceFrete);
                System.debug(priceMargem);

                orderItem.PorcentagemImposto__c = priceImposto.Valor__c;
                orderItem.ValorFrete__c = priceFrete.Valor__c; 
                orderItem.PorcentagemMargem__c = priceMargem.Valor__c;
    
                orderItem.PrecoSemMargem__c = (orderItem.ListPrice + orderItem.ValorFrete__c) * (1+(priceImposto.Valor__c/100)) ;
                orderItem.PrecoFinal__c = (((orderItem.ListPrice + orderItem.ValorFrete__c) * (1+((priceImposto.Valor__c/100)))) * (1+((orderItem.PorcentagemMargem__c/ 100))));
                orderItem.Discount__c = ((orderItem.PrecoFinal__c - orderItem.UnitPrice) / orderItem.PrecoFinal__c) * 100;    
            }
        }

        return new List<OrderItem>(orderItemList);

    }
}

