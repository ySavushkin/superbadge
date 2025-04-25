/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
    		orderRecord = queryOrderRecord(orderRecord.Id);
        }
        
        loadStandardController();
        total = 0;
    	for (OrderItem orderItem : orderRecord.OrderItems) {
        	orderItemMap.put(orderItem.Product2Id, orderItem);
        	total += orderItem.UnitPrice * orderItem.Quantity;
                
        	if(orderItem.Quantity > 0) {
                if(pieData == null){
                    pieData = new List<ChartHelper.ChartData>();
                }
            	pieData.add(new ChartHelper.ChartData(orderItem.Product2.Name, (orderItem.Quantity * orderItem.UnitPrice)));
        	}
    	}
		
		PopulateOrderItems();
    }

    public void loadStandardController() {
        String query = 'SELECT Name, Id, Product2Id, UnitPrice, Product2.Name,Product2.Quantity_Remaining__c, Product2.Family FROM PricebookEntry WHERE isActive= TRUE';
        if (selectedFamily != null && selectedFamily != Constants.SELECT_ONE ) {
            query += ' AND Product2.Family = \''+ selectedFamily + '\'';
        }
        
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }

    public void PopulateOrderItems() {
        orderItemList = new List<OrderItem>();
        
        for(SObject sObj : standardSetController.getRecords()) {
            PricebookEntry pricebookEntryInstance = (PricebookEntry) sObj;
            
            if(orderItemMap.containsKey(pricebookEntryInstance.Product2Id)) {
                orderItemList.add(orderItemMap.get(pricebookEntryInstance.Product2Id));
            } else {
                OrderItem orderItem = new OrderItem(
                	PricebookEntryId = pricebookEntryInstance.Id,
                    Product2Id = pricebookEntryInstance.Product2Id,
                    UnitPrice = pricebookEntryInstance.UnitPrice,
                    Quantity = 0,
                    Product2 = pricebookEntryInstance.Product2
                );
                orderItemList.add(orderItem);
                orderItemMap.put(pricebookEntryInstance.Product2Id, orderItem);
            } 
        }
    }
    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){ 
        for(OrderItem orderItem : orderItemList) {
            orderItemMap.put(orderItem.Product2Id, orderItem);
        }
        pieData = null;
    	total = 0;
        
        for (OrderItem orderItem : orderItemList) {
        	orderItemMap.put(orderItem.Product2Id, orderItem);
        	total += orderItem.UnitPrice * orderItem.Quantity;
            
            if(orderItem.Quantity > 0) {
                if(pieData == null) {
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new ChartHelper.ChartData(orderItem.Product2.Name, (orderItem.Quantity * orderItem.UnitPrice)));
            }
    	}

    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        loadStandardController();
        PopulateOrderItems();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        System.Savepoint sp = Database.setSavepoint();
        
        try {
            if (orderRecord.Pricebook2Id == null) {
            	orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
        	}
        	upsert orderRecord;
        	List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
        	List<OrderItem> orderItemsToDelete = new List<OrderItem>();
        	for (OrderItem orderItem : orderItemList) {
        		if (orderItem.Quantity > 0) {
            		if (orderItem.OrderId == null) {
                    	orderItem.OrderId = orderRecord.Id;
                	}
                	orderItemsToUpsert.add(orderItem);
            	} else if (orderItem.Id != null) {
                	orderItemsToDelete.add(orderItem);
            	}
        	}
       		upsert orderItemsToUpsert;
       		delete orderItemsToDelete;
        } catch (Exception ex) {
            Database.rollback(sp);
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE));
        }
		
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
		standardSetController.first();
        PopulateOrderItems();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
		standardSetController.next();
        PopulateOrderItems();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
		standardSetController.previous();
        PopulateOrderItems();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
		standardSetController.last();
        PopulateOrderItems();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer) Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
    	List<SelectOption> optionList = new List<SelectOption>();
    	optionList.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
    
    	for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            optionList.add(new SelectOption(entry.getValue(), entry.getLabel()));
    	}
        
    	return optionList;
	}

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}