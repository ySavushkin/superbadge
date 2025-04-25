public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('Test ' + Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
		List<Product2> needsAnnouncement = new List<Product2>();
		Map<String, Inventory_Setting__mdt> stringToInventorySettingMetadata = new Map<String, Inventory_Setting__mdt>();

        for(Inventory_Setting__mdt inventorySetting : [
            SELECT MasterLabel, Low_Quantity_Alert__c FROM Inventory_Setting__mdt
        ]) {
            stringToInventorySettingMetadata.put(inventorySetting.MasterLabel, inventorySetting);
        }

        for(Product2 productInstance : newList){
            if(productInstance.Quantity_Remaining__c <= stringToInventorySettingMetadata.get(productInstance.Family).Low_Quantity_Alert__c) {
                needsAnnouncement.add(productInstance);
            }
        }

        PostAlerts(needsAnnouncement);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();

        for ( Product2 p : productList ){
            ConnectApi.AnnouncementInput announcementInput = new ConnectApi.AnnouncementInput();
            announcementInput.expirationDate = Date.today().addDays(1);
            announcementInput.sendEmails = false;
            ConnectApi.MessageBodyInput bodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
            textInput.text = p.Name + ', ' + Constants.INVENTORY_LEVEL_LOW;
            bodyInput.messageSegments = new List<ConnectApi.TextSegmentInput>();
            bodyInput.messageSegments.add(textInput);
            announcementInput.body = bodyInput;
            announcementInput.parentId = COLLABORATION_GROUP[0].Id;
           	toPost.add(announcementInput);
        }

        AnnouncementQueueable announcementQueueable = new AnnouncementQueueable();
        announcementQueueable.toPost = toPost;

        System.enqueueJob(announcementQueueable);
    }
}