public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}
    
    public Product2Extension() {}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void addRows(){
        for ( Integer i=0; i < Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> getInventory(){
        return ChartHelper.getInventory();
    }

    public PageReference save(){
        Savepoint sp = Database.setSavepoint();

        try {
            List<Product2> productList = new List<Product2>();
            List<PricebookEntry> entryList = new List<PricebookEntry>();

            for (ProductWrapper wrapper : productsToInsert) {
                if (checkProductWrapperNullFields(wrapper)) {
                    productList.add(wrapper.productRecord);
    
                    PricebookEntry entry = wrapper.pricebookEntryRecord;
                    entry.IsActive = true;
                    entry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
    
                    entryList.add(entry);  
                }
            }

            insert productList; 
             
            for (Integer i = 0; i < entryList.size();i++){
                entryList[i].Product2Id = productList[i].id;
            }

            insert entryList;

            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, productsToInsert.size() + 'Inserted'));
            productsToInsert.clear();
            addRows();

        } catch (Exception e){
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }

        return null;
    }
    
    public List<SelectOption> getFamilyOptions(){
    	List<SelectOption> optionList = new List<SelectOption>();
    	optionList.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
    
    	for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            optionList.add(new SelectOption(entry.getValue(), entry.getLabel()));
    	}
        
    	return optionList;
	}

    public class ProductWrapper {
        public Product2 productRecord { get; set; }
        public PriceBookEntry pricebookEntryRecord { get; set; }
        
        public ProductWrapper() {
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PricebookEntry(Unitprice = 0.0);
        }
    }

    private Boolean checkProductWrapperNullFields(ProductWrapper wrapper) {
        return wrapper != null
            && wrapper.productRecord != null
            && wrapper.pricebookEntryRecord != null
            && wrapper.productRecord.Name != null
            && wrapper.productRecord.Family != null
            && wrapper.productRecord.Family != Constants.SELECT_ONE
            && wrapper.productRecord.Initial_Inventory__c != null
            && wrapper.pricebookEntryRecord.UnitPrice != null;
    }    
}