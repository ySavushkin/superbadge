public without sharing class ChartHelper {

    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<ChartData> chartDataList = new List<ChartData>();
        for(AggregateResult aggregateResultInstance : [
            SELECT SUM(Quantity_Remaining__c) remainingQuantity, Family
            FROM Product2
            WHERE IsActive = True
            GROUP BY Family
        ]) {
            chartDataList.add(new ChartData(String.valueOf(aggregateResultInstance.get('Family')), Integer.valueOf(aggregateResultInstance.get('remainingQuantity'))));
        }
        return chartDataList;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}