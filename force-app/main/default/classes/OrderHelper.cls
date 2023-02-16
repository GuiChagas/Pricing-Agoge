public with sharing class OrderHelper {
    public OrderHelper() {

    }

    public static void checkChangedAccount(Map<Id,Order> oldRecords, Map<Id,Order> newRecords){

        for(Order order : newRecords.values()){
            Order oldRecord = oldRecords.get(order.Id);
            if(order.AccountId != oldRecord.AccountId){
                order.addError('Não é possível atualizar a conta do pedido');
            }
       }
    }

    public static List<OrderItem> checkOlderOrderInfos(Map<Id,Order> oldRecords, Map<Id,Order> newRecords){
        Set<Id> orderId = new Set<Id>();

        for(Order order : newRecords.values()){
            Order oldRecord = oldRecords.get(order.Id);
           
            if(oldRecord.Status == 'Activated'){
                if(order.AccountAddress__c != oldRecord.AccountAddress__c){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.EffectiveDate != oldRecord.EffectiveDate){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.DataEntrega__c != oldRecord.DataEntrega__c){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.DistributionCenter__c != oldRecord.DistributionCenter__c){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.CondicaoPagamento__c != oldRecord.CondicaoPagamento__c){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.CustomerAuthorizedById != oldRecord.CustomerAuthorizedById){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.CompanyAuthorizedById != oldRecord.CompanyAuthorizedById){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.BillingAddress != oldRecord.BillingAddress){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.ShippingAddress != oldRecord.ShippingAddress){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.TypeFrete__c != oldRecord.TypeFrete__c){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.ContractId != oldRecord.ContractId){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.Type != oldRecord.Type){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.Observacao__c != oldRecord.Observacao__c){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }else if(order.Description != oldRecord.Description){
                    order.addError('O pedido está ativado, desative para alterar o campo');
                }
            }else{
                if(order.AccountAddress__c != oldRecord.AccountAddress__c){
                    System.debug('ORDER ACCOUNT OLD ADDRESS =>' + order.AccountAddress__c);
                    System.debug('ORDER ACCOUNT NEW ADDRESS =>' + oldRecord.AccountAddress__c);
    
                    orderId.add(order.Id);
                }else if(order.DistributionCenter__c != oldRecord.DistributionCenter__c){
                    orderId.add(order.Id);
                }
            }
       }

        List<OrderItem> orderItemList = [
            SELECT Id, Product2Id, OrderId, ListPrice, UnitPrice
            FROM OrderItem
            WHERE OrderId IN: orderId
        ];

        List<OrderItem> updatedOrderItemList = OrderItemHelper.calcPrice(orderItemList);

        return updatedOrderItemList;
    
    }
}