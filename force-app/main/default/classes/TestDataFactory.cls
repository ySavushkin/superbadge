/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Test '+ Constants.INVENTORY_ANNOUNCEMENTS,  
            CollaborationType = 'Public'
        );
        return chatterGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> productList = new List<Product2>();
        
        for(Integer i = 0; i < cnt; i++){
            productList.add(new Product2(
            	Name = 'Test Product ' + i,
				IsActive = true,
                Initial_Inventory__c = 10,
                Family = Constants.PRODUCT_FAMILY.get(math.mod(i,4)).getValue()
            ));
        }
        
        return productList;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        
        for(Integer i = 0; i < prods.size(); i++){
            pricebookEntryList.add(new PricebookEntry(
            	Product2Id = prods[i].Id,
                UnitPrice = 10 + (i * 10),
                IsActive = true,
                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID
            ));
        }
        
        return pricebookEntryList;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        List<Account> accountList = new List<Account>();
        
        for(Integer i = 0; i < cnt; i++) {
        	accountList.add(new Account(
            	Name = 'Test Account ' + i
            ));
        }
        
        return accountList;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> contactList = new List<Contact>();
        
        for(Integer i = 0; i < cnt; i++) {
            contactList.add(new Contact(
            	FirstName = 'Test',
            	LastName = 'Contact ' + i,
            	AccountId = accts.get(Math.mod(i, accts.size())).Id
            ));            
        }
        
        return contactList;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
		List<Order> orderList = new List<Order>();
        
        for(Integer i = 0; i < cnt; i++) {
            orderList.add(new Order(
            	AccountId = accts.get(math.mod(i, accts.size())).Id,
                Name = 'Test order ' + i,
                Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
                Status='Draft',
                EffectiveDate = System.today()
            ));
        }
        
        return orderList;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(Integer cnt, List<PriceBookEntry> priceBookEntryList, List<Order> orderList){
        List<OrderItem> orderItemList = new List<OrderItem>();
        
        for(Integer i = 0; i < cnt; i++) {
            orderItemList.add(new OrderItem(
            	PricebookEntryId = priceBookEntryList.get(math.mod(i, priceBookEntryList.size())).Id,
                OrderId = orderList.get(math.mod(i, orderList.size())).Id,
                Quantity = 1,
                UnitPrice = 10 + (i * 10)
            ));
        }
        
        return orderItemList;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){

		CollaborationGroup collaborationGroup = TestDataFactory.ConstructCollaborationGroup();
        insert collaborationGroup;
        
        List<Product2> productList = TestDataFactory.ConstructProducts(cnt);
        insert productList;
        
        List<PriceBookEntry> pricebookEntryList = TestDataFactory.ConstructPricebookEntries(productList);
        insert pricebookEntryList;
        
        List<Account> accountList = TestDataFactory.ConstructAccounts(cnt);
        insert accountList;
        
        List<Contact> contactList = TestDataFactory.ConstructContacts(cnt, accountList);
        insert contactList;
        
        List<Order> orderList = TestDataFactory.ConstructOrders(cnt, accountList);
        insert orderList;
        
        List<OrderItem> orderItemList = TestDataFactory.ConstructOrderItems(cnt, pricebookEntryList, orderList);
        insert orderItemList;
    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer quantityOrdered) {
        Assert.areEqual((updatedProduct.Quantity_Ordered__c - originalProduct.Quantity_Ordered__c), quantityOrdered);
    }

}